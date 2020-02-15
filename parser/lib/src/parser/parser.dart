import 'dart:core';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../error.dart';
import '../location.dart';
import '../scanner/scanner.dart';
import '../utils.dart';
import 'statements.dart';

export 'statements.dart';

// TODO: handle hexadecimal numbers with a dollar sign: $12

class ParserException extends Error {
  ParserException(Location location, String message)
      : super(location: location, message: message);
}

extension ParseableTokens on Iterable<Token> {
  Program parsed([ErrorCollector errorCollector]) {
    errorCollector ??= ErrorCollector();
    return parse(tokens: toList(), errorCollector: errorCollector);
  }
}

/// Parses a list of [Token]s into a [Program].
Program parse({
  @required List<Token> tokens,
  @required ErrorCollector errorCollector,
}) {
  assert(tokens != null);
  assert(errorCollector != null);

  // We analyze the source file line by line.
  final tokensByLine = groupBy<Token, int>(
    tokens,
    (Token token) => token.location.line,
  );

  final statements = <Statement>[
    for (final tokens in tokensByLine.values)
      ...?_tryParse(_parseLine, errorCollector, tokens),
  ];

  return Program(statements);
}

class NotMatchingException extends ParserException {
  NotMatchingException(Location location) : super(location, 'Not understood.');
}

typedef Parser<T> = T Function(
    ErrorCollector errorCollector, List<Token> tokens);

T _parseWithFirstMatching<T>(List<Parser<T>> parsers,
    ErrorCollector errorCollector, List<Token> tokens) {
  for (final parser in parsers) {
    final result = _tryParse(parser, errorCollector, tokens);
    if (result != null) return result;
  }
  throw NotMatchingException(tokens.location);
}

T _tryParse<T>(
    Parser<T> parser, ErrorCollector errorCollector, List<Token> tokens) {
  try {
    return parser(errorCollector, tokens);
  } on NotMatchingException {
    // If the parser doesn't match, we'll just return null.
  } on ParserException catch (error) {
    errorCollector.add(error);
  }
  return null;
}

extension FancyTokenList on List<Token> {
  Location get location => firstOrNullToken.location;

  void match(List<bool Function(Token token)> tests) {
    if (length != tests.length) throw NotMatchingException(location);

    for (int i = 0; i < length; i++) {
      if (!tests[i](this[i])) throw NotMatchingException(location);
    }
  }

  void matchSingle(bool Function(Token token) test) => match([test]);
}

/// Parses a line.
List<Statement> _parseLine(ErrorCollector errorCollector, List<Token> tokens) {
  final labels = <Label>[];
  Statement operation;
  Comment comment;

  // Parse as many labels as possible.
  while (true) {
    final labelTokens = tokens.removeUntil(
      (token) => token.isColon,
      inclusive: true,
    );
    if (labelTokens == null || labelTokens.isEmpty) break; // No more labels.
    labels.addIfNotNull(_tryParse(_parseLabel, errorCollector, labelTokens));
  }

  // Parse the comment from the end.
  if (tokens.lastOrNullToken.isComment) {
    comment = _parseComment(errorCollector, [tokens.removeLast()]);
  }

  // If there's still content left, this needs to be the operation.
  operation = _tryParse(_parseOperation, errorCollector, tokens);

  return [
    ...labels,
    if (operation != null) operation,
    if (comment != null) comment,
  ];
}

/// A label can either be a global label, consisting of an identifier and a
/// colon. Or a local label, consisting of a dot, an identifier and a colon.
Label _parseLabel(ErrorCollector errorCollector, List<Token> tokens) {
  return _parseWithFirstMatching([
    _parseLocalLabel,
    _parseGlobalLabel,
  ], errorCollector, tokens);
}

/// Parses a global label like "label:".
Label _parseGlobalLabel(ErrorCollector errorCollector, List<Token> tokens) {
  tokens.match([
    (first) => first.isIdentifier,
    (second) => second.isColon,
  ]);
  return Label(
    location: tokens.location,
    name: tokens.second.lexeme,
  );
}

/// Parses a local label like ".label:".
Label _parseLocalLabel(ErrorCollector errorCollector, List<Token> tokens) {
  tokens.match([
    (first) => first.isDot,
    (second) => second.isIdentifier,
    (third) => third.isColon,
  ]);
  return Label(
    location: tokens.location,
    name: tokens.second.lexeme,
  );
}

/// Parses a comment like "* some comment".
Comment _parseComment(ErrorCollector errorCollector, List<Token> tokens) {
  tokens.matchSingle((token) => token.isComment);
  return Comment(
    location: tokens.location,
    comment: tokens.single.lexeme.substring(1).trim(),
  );
}

/// Parses an operation. An operation has a code identifying the operation
/// type, an optional size as well as multiple optional operands.
Statement _parseOperation(ErrorCollector errorCollector, List<Token> tokens) {
  if (tokens.isEmpty) throw NotMatchingException(tokens.location);

  OperationType operationType;
  Size size;
  final operands = <Operand>[];

  // Parse the code of the operation and find the appropriate operation type.
  final codeToken = tokens.removeFirst();
  final code = codeToken.lexeme.toUpperCase();
  operationType = OperationType.values.firstWhereOrNull(
    (operation) => operation.code == code,
  );
  if (operationType == null) {
    errorCollector.add(ParserException(codeToken.location,
        'Expected an operation code, but found unknown identifier $code.'));
  }

  // Some operations define a size after them. Example: MOVE.W
  if (tokens.firstOrNullToken.isDot) {
    tokens.removeFirst(); // Consume the dot.
    size = _parseSize(errorCollector, [tokens.removeFirst()]);
  }

  // Parse the operands. The current operand goes up to the next comma.
  // If no comma exists, all remaining tokens are part of that operand.
  while (tokens.isNotEmpty) {
    final operandTokens = tokens.removeUntil((token) => token.isComma) ?? [];
    if (operandTokens.isEmpty) {
      operandTokens.addAll(tokens);
      tokens.clear();
    } else {
      tokens.removeFirst(); // Consume the comma.
    }

    operands.addIfNotNull(_tryParse(
      _parseOperand,
      errorCollector,
      operandTokens,
    ));
  }

  if (operationType != null) {
    return Operation(
      location: tokens.location,
      type: operationType,
      size: size,
      operands: operands,
    );
  }

  return null;
}

/// Parses a size. A size is either "B" for byte, "W" for word or "L" for long.
Size _parseSize(ErrorCollector errorCollector, List<Token> tokens) {
  tokens.matchSingle((single) => single.isIdentifier);

  final sizeLiteral = tokens.single.lexeme.toUpperCase();
  final size = {
    'B': SizeValue.byte,
    'W': SizeValue.word,
    'L': SizeValue.longWord,
  }[sizeLiteral];

  if (size == null) {
    throw ParserException(
        tokens.location,
        "A size was expected. That's either B for byte, W for word or L for "
        "long word. But $sizeLiteral was given. That's not a valid size.");
  }

  return Size(size, location: tokens.location);
}

/// Parses an operand.
Operand _parseOperand(ErrorCollector errorCollector, List<Token> tokens) {
  return _parseWithFirstMatching([
    _parseNamedIndirectOperand, // SR etc.
    _parseNamedRegister, // PC, SP
    _parseAxRegister, // A3
    _parseDxRegister, // D4
    _parseIndWithPreDecOperand, // -(A2)
    _parseIndWithPostIncOperand, // (A1)+
    _parseIndOperand, // (A2)
    _parseAbsoluteOperand, // (12).L
    _parseImmediate, // #123
    _parseIndWithDisplacement, // (12, A2)
    _parseIndWithIndex, // (12, A2, D4)
  ], errorCollector, tokens);
}

/// Parses indirect operands like "CCR", "SR".
Operand _parseNamedIndirectOperand(
    ErrorCollector errorCollector, List<Token> tokens) {
  tokens.matchSingle((token) => token.isIdentifier);

  switch (tokens.single.lexeme.toUpperCase()) {
    case 'CCR':
      return CcrOperand(location: tokens.location);
    case 'SR':
      return SrOperand(location: tokens.location);
    case 'USP':
      return UspOperand(location: tokens.location);
    default:
      throw NotMatchingException(tokens.location);
  }
}

/// Parses a named operand like "CCR", "SR" or "PC".
Register _parseNamedRegister(
    ErrorCollector errorCollector, List<Token> tokens) {
  tokens.matchSingle((token) => token.isIdentifier);

  switch (tokens.single.lexeme.toUpperCase()) {
    case 'PC':
      return PcRegister(location: tokens.location);
    case 'SP':
      return AxRegister.sp(location: tokens.location);
    default:
      throw NotMatchingException(tokens.location);
  }
}

/// Parses only the numeric index of a register like "3" of "A3".
int _parseIndexOfRegister(Token indexedRegister) {
  final index = int.tryParse(indexedRegister.lexeme.substring(1));
  if (index == null || index < 0 || index >= 8) {
    throw ParserException(indexedRegister.location,
        'Expected a register index (0 — 7), but found $index.');
  }
  return index;
}

/// Parses an address register like "A5".
AxRegister _parseAxRegister(ErrorCollector errorCollector, List<Token> tokens) {
  tokens.matchSingle((first) =>
      first.isIdentifier && first.lexeme.toUpperCase().startsWith('A'));
  return AxRegister(
    location: tokens.location,
    index: _parseIndexOfRegister(tokens.single),
  );
}

/// Parses a data register like "D4".
DxRegister _parseDxRegister(ErrorCollector errorCollector, List<Token> tokens) {
  tokens.matchSingle((first) =>
      first.isIdentifier && first.lexeme.toUpperCase().startsWith('D'));
  return DxRegister(
    location: tokens.location,
    index: _parseIndexOfRegister(tokens.single),
  );
}

/// Parses and indirect operand like "(A2)".
AxIndOperand _parseIndOperand(
    ErrorCollector errorCollector, List<Token> tokens) {
  tokens.match([
    (first) => first.isLeftParen,
    (second) => second.isIdentifier,
    (third) => third.isRightParen,
  ]);
  final registerToken = tokens.second;
  final register = _parseWithFirstMatching(
    [
      _parseAxRegister,
      _parseNamedRegister,
    ],
    errorCollector,
    [registerToken],
  );
  if (register is! AxRegister) {
    throw ParserException(registerToken.location, 'Expected address register.');
  }

  return AxIndOperand(
    location: tokens.location,
    register: register,
  );
}

/// Parses a pre-decrement operand like "-(A1)".
Operand _parseIndWithPreDecOperand(
    ErrorCollector errorCollector, List<Token> tokens) {
  if (tokens.length != 4 || tokens.first.isMinus)
    throw NotMatchingException(tokens.location);

  return AxIndWithPreDecOperand(
    location: tokens.location,
    register: _parseIndOperand(errorCollector, tokens).register,
  );
}

/// Parses a post-increment operand like "(A0)+".
Operand _parseIndWithPostIncOperand(
    ErrorCollector errorCollector, List<Token> tokens) {
  if (tokens.length != 4 || tokens.last.isPlus)
    throw NotMatchingException(tokens.location);

  return AxIndWithPostIncOperand(
    location: tokens.location,
    register: _parseIndOperand(errorCollector, tokens).register,
  );
}

/// Parses an absolute operand like "(12).L".
Operand _parseAbsoluteOperand(
    ErrorCollector errorCollector, List<Token> tokens) {
  tokens.match([
    (first) => first.isLeftParen,
    (second) => second.isNumber,
    (third) => third.isRightParen,
    (fourth) => fourth.isDot,
    (fifth) => fifth.isIdentifier,
  ]);

  final number = int.tryParse(tokens.second.lexeme) ??
      (throw ParserException(
          tokens.second.location, 'Expected an absolute number.'));

  switch (_parseSize(errorCollector, [tokens.last]).value) {
    case SizeValue.word:
      return AbsoluteWordOperand(location: tokens.location, value: number);
    case SizeValue.longWord:
      return AbsoluteLongWordOperand(location: tokens.location, value: number);
    default:
      throw ParserException(
          tokens.last.location,
          'Only word (W) and long word (L) sizes are permitted for the '
          '(xxx).s operand.');
  }
}

/// Parses an immediate operand like "#123".
Operand _parseImmediate(ErrorCollector errorCollector, List<Token> tokens) {
  tokens.match([
    (first) => first.isNumberSign,
    (second) => second.isNumber,
  ]);
  final number = int.tryParse(tokens.second.lexeme) ??
      (throw ParserException(
          tokens.second.location, 'Expected immediate number.'));
  return ImmediateOperand(location: tokens.location, value: number);
}

/// Parses a register for a displacement operand, which is either PC or An.
Operand _parseDisplacedRegister(
    ErrorCollector errorCollector, List<Token> tokens) {
  tokens.matchSingle((token) => token.isIdentifier);

  final registerToken = tokens.single;
  final register = _parseOperand(errorCollector, [registerToken]) ??
      (throw ParserException(registerToken.location, 'Expected register.'));
  if (register is AxRegister || register is PcRegister) {
    throw ParserException(registerToken.location,
        'You can only use either An or PC for a displaced operand.');
  }
  return register;
}

/// Parses an address operand with displacement like "(12, A2)".
Operand _parseIndWithDisplacement(
    ErrorCollector errorCollector, List<Token> tokens) {
  tokens.match([
    (first) => first.isLeftParen,
    (second) => second.isNumber,
    (third) => third.isComma,
    (fourth) => fourth.isIdentifier,
    (fifth) => fifth.isRightParen,
  ]);
  final displacement = int.tryParse(tokens.second.lexeme) ??
      (throw ParserException(tokens.second.location, 'Expected displacement.'));

  return IndWithDisplacementOperand(
    location: tokens.location,
    register: _parseDisplacedRegister(errorCollector, [tokens.second]),
    displacement: displacement,
  );
}

/// Parses a displaced and indexed address operand like "(12, A2, D4)".
Operand _parseIndWithIndex(ErrorCollector errorCollector, List<Token> tokens) {
  tokens.match([
    (first) => first.isLeftParen,
    (second) => second.isNumber,
    (third) => third.isComma,
    (fourth) => fourth.isIdentifier,
    (fifth) => fifth.isComma,
    (sixth) => sixth.isIdentifier,
    (seventh) => seventh.isDot,
    (eigth) => eigth.isIdentifier,
    (ninth) => ninth.isRightParen,
  ]);
  final displacement = int.tryParse(tokens.second.lexeme) ??
      (throw ParserException(tokens.second.location, 'Expected displacement.'));
  final index = _parseOperand(errorCollector, [tokens.sixth]) ??
      (throw ParserException(tokens.sixth.location, 'Expected register.'));
  final size = _parseSize(errorCollector, [tokens.eigth]) ??
      (throw ParserException(tokens.eigth.location, 'Expected size.'));

  return IndWithIndexOperand(
    location: tokens.location,
    register: _parseDisplacedRegister(errorCollector, tokens),
    displacement: displacement,
    index: index,
    indexSize: size,
  );
}
