import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../error.dart';
import '../scanner/scanner.dart';
import 'statements.dart';

export 'statements.dart';

class ParserException implements Exception {
  ParserException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Parser {
  Parser(this.errorCollector);

  ErrorCollector errorCollector;

  int line = 0;

  bool _startsWith(List<Token> tokens, List<TokenType> types) {
    int cursor = 0;
    while (cursor < tokens.length && tokens[cursor].type == types[cursor]) {
      cursor++;
    }
    return cursor == types.length;
  }

  void tryAndCatchError(void Function() callback) {
    try {
      callback();
    } on ParserException catch (error) {
      errorCollector.add(Error(
        line: line,
        message: error.message,
      ));
    }
  }

  Program parse({
    @required List<Token> tokens,
  }) {
    assert(tokens != null);
    assert(errorCollector != null);

    final labels = <Label, int>{};
    final statements = <Statement>[];

    final tokensByLine = groupBy<Token, int>(
      tokens,
      (Token token) => token.line,
    );
    final maxLine = tokensByLine.keys.reduce((a, b) => a + b);

    final labelsWaitingForCode = <Label, int>{};

    for (var line = 0; line < maxLine; line++) {
      final lineTokens = tokensByLine[line] ?? [];

      if (_startsWith(lineTokens, [TokenType.identifier, TokenType.colon])) {
        labelsWaitingForCode[Label(lineTokens.first.literal)] = line;
      } else if (_startsWith(
          lineTokens, [TokenType.dot, TokenType.identifier, TokenType.colon])) {
        labelsWaitingForCode[Label('.${lineTokens[1].literal}')] = line;
      } else if (_startsWith(tokens, [TokenType.comment])) {
        // This is a comment line. It's impossible to have anything after the
        // comment, because the comment comments out the line.
        assert(tokens.length == 1);
        statements.add(CommentStatement(
          line: line,
          comment: tokens.single.literal,
        ));
      } else {
        // This is an operation or a directive.
        labels.addAll({
          for (final label in labelsWaitingForCode.keys)
            label: statements.length,
        });

        tryAndCatchError(() {
          statements.add(_parseStatement(lineTokens));
        });
      }
    }

    // Once we parsed the file, there should be no labels waiting for code.
    for (final label in labelsWaitingForCode.keys) {
      errorCollector.add(Error(
        line: labelsWaitingForCode[label],
        message: "There should be code after labels, but label $label isn't "
            "followed by any statements.",
      ));
    }

    return Program(labelsToIndex: labels, statements: statements);
  }

  Statement _parseStatement(List<Token> tokens) {
    if (!_startsWith(tokens, [TokenType.identifier])) {
      throw ParserException('Identifier expected at the start of a statement.');
    }
    final name = tokens.removeAt(0);

    SizeStatement size;

    if (_startsWith(tokens, [TokenType.dot])) {
      tokens.removeAt(0);
      tryAndCatchError(() {
        _parseSizeStatement(tokens.removeAt(0));
      });
    }

    final operandTokens = <List<Token>>[];
    int start = 0;
    int cursor = 0;
    for (; cursor < tokens.length; cursor++) {
      if (tokens[cursor].isComma) {
        operandTokens.add(tokens.sublist(start, cursor));
        start = cursor + 1;
      }
    }

    final operands = <OperandStatement>[];

    for (final operandTokens in operandTokens) {
      tryAndCatchError(() {
        operands.add(_parseOperandStatement(operandTokens));
      });
    }

    //return Statement
  }

  SizeStatement _parseSizeStatement(Token token) {
    if (token.type != TokenType.identifier) {
      throw ParserException('Size expected here.');
    }
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
    return SizeStatement(line: line, size: size);
  }

  OperandStatement _parseOperandStatement(List<Token> tokens) {
    return OperandStatement(
      line: line,
      operand: tokens.map((token) => token.lexeme).join(),
      type: null,
    );
  }
}
