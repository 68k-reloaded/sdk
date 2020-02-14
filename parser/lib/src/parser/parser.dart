import 'dart:core';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../error.dart';
import '../location.dart';
import '../scanner/scanner.dart';
import '../utils.dart';
import 'statements.dart';

export 'statements.dart';

class ParserException implements Exception {
  ParserException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class Parser {
  Parser._();

  static Program parse({
    @required List<Token> tokens,
    @required ErrorCollector errorCollector,
  }) {
    assert(tokens != null);
    assert(errorCollector != null);

    final labels = <LabelStatement, int>{};
    final statements = <Statement>[];

    final tokensByLine = groupBy<Token, int>(
      tokens,
      (Token token) => token.location.line,
    );

    final labelsWaitingForCode = <LabelStatement>{};

    tokensByLine.forEach((line, tokens) {
      // Global label line.
      if (tokens.firstOrNullToken.isIdentifier && tokens.secondOrNull.isColon) {
        labelsWaitingForCode.add(LabelStatement(
          location: tokens.first.location,
          name: tokens.first.literal,
        ));
        tokens.removeRange(0, 2);
      }

      // Local label line.
      if (tokens.firstOrNullToken.isDot &&
          tokens.secondOrNullToken.isIdentifier &&
          tokens.thirdOrNullToken.isColon) {
        labelsWaitingForCode.add(LabelStatement(
          location: tokens.first.location,
          name: '.${tokens.first.literal}',
        ));
        tokens.removeRange(0, 3);
      }

      // Pre-parse comments at the end of the line so that the only thing left
      // is a single operation or directive.
      Token comment;
      if (tokens.lastOrNullToken.isComment) {
        comment = tokens.last;
        tokens.removeLast();
      }

      // This is an operation or a directive. Let the labels point to the next
      // statement, which will be inserted at the end of the list.
      if (tokens.isNotEmpty) {
        final state = _LineParserState(tokens, errorCollector, line);
        state.tryOrRegisterError(() {
          final statement = parseOperationOrDirective(state);

          if (statement != null) {
            // A new statement got parsed. Labels that came before should point
            // to this statement.
            statements.add(statement);
            labels.addAll({
              for (final label in labelsWaitingForCode)
                label: statements.length,
            });
            labelsWaitingForCode.clear();
          }
        });
      }

      // If there was a comment after the optional statement, now is the time
      // to save it!
      if (comment != null) {
        statements.add(CommentStatement(
          location: comment.location,
          comment: (comment.literal as String).trim(),
        ));
      }
    });

    // Once we parsed the file, there should be no labels waiting for code.
    for (final label in labelsWaitingForCode) {
      errorCollector.add(Error(
        location: label.location,
        message: "There should be code after labels, but label $label isn't "
            "followed by any statements.",
      ));
    }

    return Program(labelsToIndex: labels, statements: statements);
  }

  static void parseLine(_LineParserState state) {
    // A line can contain some labels as well as an operation or directive.
    final labels = <LabelStatement>{};

    // Parse labels.
    while (state.peek2().isColon || state.peek3().isColon) {
      state.tryOrRegisterError(() {
        labels.add(parseLabel(state));
      });
    }

    if (state.peek()?.isIdentifier ?? false) {
      parseOperationOrDirective(state);
    }
  }

  static LabelStatement parseLabel(_LineParserState state) {
    final numberOfDots = state.advanceWhile((token) => token.isDot).length;
    if (numberOfDots >= 2) {
      state
        ..advanceWhile((token) => !token.isColon)
        ..advance();
      throw ParserException(
          'A line started with $numberOfDots dots.\nIf you tried to create a '
          'local label, consider using only one dot.');
    }

    final identifier =
        state.expect(TokenType.identifier, expected: 'a label identifier');
    assert(state.advance().isColon);

    return LabelStatement(
      location: identifier.location,
      name: identifier.literal,
    );
  }

  static Statement parseOperationOrDirective(_LineParserState state) {
    final identifier = state.expect(TokenType.identifier,
        expected: 'an operation or directive identifier');

    SizeStatement size;
    if (state.peek().isDot) {
      state.advance();
      state.tryOrRegisterError(() => size = parseSize(state));
    }

    final operands = <OperandStatement>[];
    while (true) {
      state.tryOrRegisterError(() {
        operands.add(parseOperand(state));
      });
      final isNextComma = state.peek()?.isComma ?? false;
      if (!isNextComma) break;
      state.expect(TokenType.comma,
          expected: 'a comma indicating more operands are coming');
    }

    // Now, we got the [identifier] of the operation as well as its [size] and
    // [operands]. It's time to see if there actually exists an operation or
    // directive which matches that signature!

    var operation = Operation.values.firstOrNull(
      (operation) => operation.code == identifier.literal,
    );

    if (operation != null) {
      state.tryOrRegisterError(() {
        ensureMatchingOperationConfigurationExists(
          operation,
          size.size,
          operands,
        );
      });

      return OperationStatement(
        location: identifier.location,
        operation: operation,
        size: size,
        operands: operands,
      );
    }

    // No matching operation was found. Maybe this is a directive?

    //return DirectiveStatement();

    state.errorCollector.add(Error(
      location: identifier.location,
      message: 'Unknown operation ${identifier.literal}.',
    ));

    // Although the operation is unknown, we still continue parsing the rest of
    // the program so that we can report all errors at once. So we just return
    // null here, causing this statement to simple be omitted in the resulting
    // statement list.
    return null;
  }

  static SizeStatement parseSize(_LineParserState state) {
    final token = state.expect(TokenType.identifier,
        expected: "a size (either B for byte, W for word or L for long word)");
    final name = token.literal.toString().toUpperCase();

    final size = {
      'B': Size.byte,
      'W': Size.word,
      'L': Size.longWord,
    }[name];
    if (size == null) {
      throw ParserException(
          "A size was expected. That's either B for byte, W for word or L for "
          "long word. But $name was given. That's not a valid size.");
    }
    return SizeStatement(location: token.location, size: size);
  }

  static OperandStatement parseOperand(_LineParserState state) {
    Token expect(TokenType type, {OperandType operandType, String expected}) {
      final expectedMessage = StringBuffer(expected);
      if (operandType != null) {
        expectedMessage.write(" for an ${operandType.toShortString()}"
            "operand ('${operandType.toDescriptiveString()}')");
      }
      return state.expect(type, expected: expectedMessage.toString());
    }

    RegisterStatement parseRegister(Token token) {
      final lexeme = token.lexeme;
      if (!token.isIdentifier) {
        throw ParserException('Expected register, but found $lexeme.');
      }
      if (lexeme == 'PC') {
        return PcRegisterStatement(location: token.location);
      }
      if (lexeme == 'SP') {
        return AxRegisterStatement(location: token.location, index: 7);
      }
      if (!lexeme.startsWith('A') && !lexeme.startsWith('D')) {
        throw ParserException('Expected register, but found $lexeme.');
      }

      final index = int.tryParse(lexeme.substring(1));
      if (index == null) {
        throw ParserException(
            'Expected a register index, but found ${lexeme.substring(1)}.');
      }
      if (lexeme.startsWith('A')) {
        return AxRegisterStatement(location: token.location, index: index);
      } else {
        assert(lexeme.startsWith('D'));
        return DxRegisterStatement(location: token.location, index: index);
      }
    }

    RegisterStatement expectRegister<T>(Token token) {
      final register = parseRegister(token);
      if (register is T) {
        return register;
      }
      throw ParserException(
          'Expected register of type $T, but actually found register of type '
          '${token.runtimeType}.');
    }

    final location = state.peek().location;

    // Dn, An, CCR, SR, USP or immediate with label.
    if (state.peek().isIdentifier) {
      final identifier = state.advance();
      final operand = {
        'CCR': CcrOperandStatement(location: location),
        'SR': SrOperandStatement(location: location),
        'USP': UspOperandStatement(location: location),
      }[identifier.lexeme];
      if (operand != null) {
        return operand;
      }

      final register = parseRegister(identifier);
      if (register?.isPc ?? false) {
        throw ParserException('Unexpected identifier ${identifier.lexeme}.');
      }
      if (register.isAx) {
        return AxOperandStatement(location: location, register: register);
      }
      if (register.isDx) {
        return DxOperandStatement(location: location, register: register);
      }
    }

    // #xxx
    if (state.peek().isNumberSign) {
      state.advance();
      final token = expect(
        TokenType.number,
        expected: 'a value',
        operandType: OperandType.immediate,
      );
      final data = int.tryParse(token.lexeme);
      if (data == null) {
        throw ParserException(
            'Immediate data was expected, but found ${token.lexeme}.');
      }
      return ImmediateOperandStatement(location: location, value: data);
    }

    // -(An)
    if (state.peek().isMinus) {
      state.advance();
      expect(
        TokenType.leftParen,
        expected: 'an opening parenthesis',
        operandType: OperandType.axIndWithPreDec,
      );
      final identifier = state.expect(TokenType.identifier,
          expected: 'An or SP for a predecrement -(An) or -(SP) operand');
      final register = expectRegister<AxRegisterStatement>(identifier);
      expect(
        TokenType.rightParen,
        expected: 'a closing parenthesis',
        operandType: OperandType.axIndWithPreDec,
      );
      return AxIndWithPreDecOperandStatement(
          location: location, register: register);
    }

    expect(TokenType.leftParen, expected: 'an operand');

    // (An) and (An)+
    if (state.peek().isIdentifier) {
      final identifier = state.advance();
      final register = expectRegister<AxRegisterStatement>(identifier);
      expect(TokenType.rightParen,
          expected: 'a closing parenthesis for an address register operand');
      if (state.peek().isPlus) {
        state.advance();
        return AxIndWithPostIncOperandStatement(
          location: location,
          register: register,
        );
      } else {
        return AxIndOperandStatement(location: location, register: register);
      }
    }

    final number = expect(TokenType.number,
        expected: 'a number for a displaced or absolute operand');

    // (xxx).W and (xxx).L
    if (state.peek().isRightParen) {
      expect(TokenType.dot, expected: 'a dot for an absolute (xxx).s operand');
      final size = parseSize(state);
      if (size.size == Size.byte) {
        throw ParserException(
            'Only word (W) or long word (L) sizes are permitted after (xxx).s '
            'operand.');
      }
      return {
        Size.word: AbsoluteWordOperandStatement(
          location: location,
          value: number.literal,
        ),
        Size.longWord: AbsoluteLongWordOperandStatement(
          location: location,
          value: number.literal,
        ),
      }[size.size];
    }

    // One of (d, An), (d, An, Xn.s), (d, PC), (d, PC, Xn.s)

    final displacement = number.literal;
    expect(TokenType.comma, expected: 'a comma after the displacement');
    final register = parseRegister(expect(TokenType.identifier,
        expected: 'either An or PC for a displaced operand'));
    if (register.isDx) {
      throw ParserException('Data register cannot be displaced.');
    }

    if (state.peek().isRightParen) {
      state.advance();
      return register.isPc
          ? PcIndWithDisplacementOperandStatement(
              location: location,
              displacement: displacement,
            )
          : AxIndWithDisplacementOperandStatement(
              location: location,
              displacement: displacement,
              register: register,
            );
    }

    // One of (d, An, Xn.s), (d, PC, Xn.s)

    final type =
        register.isPc ? OperandType.pcIndWithIndex : OperandType.axIndWithIndex;
    expect(TokenType.comma, expected: 'a comma', operandType: type);
    final index = parseRegister(state.advance());
    if (register.isPc) {
      throw ParserException('Expected index register.');
    }
    expect(TokenType.dot, expected: 'a dot', operandType: type);
    final size = parseSize(state);
    return register.isPc
        ? PcIndWithIndexOperandStatement(
            location: location,
            displacement: displacement,
            index: index,
            indexSize: size,
          )
        : AxIndWithIndexOperandStatement(
            location: location,
            register: register,
            displacement: displacement,
            index: index,
            indexSize: size,
          );
  }

  /// Makes sure that an operation configuration matches the given size and
  /// operands. Otherwise throws a [ParserException].
  static void ensureMatchingOperationConfigurationExists(
    Operation operation,
    Size size,
    List<OperandStatement> operands,
  ) {
    // The operation needs to support the given [size].
    Iterable<OperationConfiguration> matchingConfigs =
        operation.configurations.where((operation) {
      return operation.sizes.contains(size);
    }).toList();

    if (matchingConfigs.isEmpty) {
      final supportedSizes = operation.configurations
          .map((op) => op.sizes)
          .reduce((a, b) => a.union(b))
          .map((size) => size.toReadableString());
      throw ParserException("The operation $operation only supports the sizes "
          "${supportedSizes.toReadableString()}, but you tried to use it "
          "with the size ${size.toReadableString()}. That doesn't work.");
    }

    // The number of arguments has to match.
    matchingConfigs = matchingConfigs.where((config) {
      return config.operandTypes.length == operands.length;
    });

    if (matchingConfigs.isEmpty) {
      throw ParserException("The operation $operation does not support "
          "invocation with ${operands.length} operands.");
    }

    // The type of the operands has to match.
    matchingConfigs = matchingConfigs.where((configuration) {
      return IterableZip([configuration.operandTypes, operands])
          .every((operands) {
        final fittingTypes = operands.first as Set<OperandType>;
        final actualType = (operands.last as OperandStatement).type;
        return fittingTypes.contains(actualType);
      });
    }).toList();

    if (matchingConfigs.isEmpty) {
      final buffer = StringBuffer()
        ..write("You provided operands of the types ")
        ..write(operands
            .map((operand) => operand.type.toDescriptiveString())
            .toReadableString())
        ..write(". But the $operation operation on size "
            "${size.toReadableString()} doesn't accept operands of these "
            "types.");
      throw ParserException(buffer.toString());
    }

    // print('Here are all matching configurations for $operation with size '
    //     '${size.toReadableString()} and operand ${operands.toReadableString()}.');
    // matchingConfigs.forEach(print);

    assert(matchingConfigs.length == 1);
  }
}

class _LineParserState {
  _LineParserState(this.tokens, this.errorCollector, this.line)
      : assert(tokens != null),
        assert(errorCollector != null),
        assert(line != null);

  final List<Token> tokens;
  final ErrorCollector errorCollector;
  final int line;

  int start = 0;
  int current = 0;

  bool get isAtEnd => current >= tokens.length;
  bool get isNotAtEnd => !isAtEnd;
  Token peek() => isAtEnd ? null : tokens[current];
  Token peek2() => current + 1 >= tokens.length ? null : tokens[current + 1];
  Token peek3() => current + 2 >= tokens.length ? null : tokens[current + 2];

  Token advance() => isNotAtEnd ? tokens[current++] : const NullToken();
  List<Token> advanceWhile(bool Function(Token token) predicate) {
    while (predicate(peek()) && !isAtEnd) {
      advance();
    }
    return tokens.sublist(start, current);
  }

  /// Advances the cursor if the type matches the expected [type]. Otherwise
  /// throws a [ParserException] describing what was [expected].
  Token expect(TokenType type, {@required String expected}) {
    if (peek()?.type != type) {
      throw ParserException("Expected $expected, but found "
          "'${peek()?.lexeme ?? 'nothing'}' instead.");
    }
    return advance();
  }

  // Calls the given [callback]. Returns true if it runs successfully.
  // If it throws an error, collects it and returns false.
  bool tryOrRegisterError(void Function() callback) {
    try {
      callback();
      return true;
    } on ParserException catch (error) {
      errorCollector.add(Error(
        location: peek()?.location ?? Location.invalid(),
        message: error.message,
      ));
      return false;
    }
  }
}
