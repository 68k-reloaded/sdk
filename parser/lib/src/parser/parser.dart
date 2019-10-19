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

abstract class Parser {
  Parser._();

  static Program parse({
    @required List<Token> tokens,
    @required ErrorCollector errorCollector,
  }) {
    assert(tokens != null);
    assert(errorCollector != null);

    final labels = <Label, int>{};
    final statements = <Statement>[];

    int line = 0;

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

    SizeStatement parseSizeStatement(Token token) {
      if (!token.isIdentifier) {
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

    OperandStatement parseOperandStatement(List<Token> tokens) {
      return OperandStatement(
        line: line,
        operand: tokens.map((token) => token.lexeme).join(),
        type: null,
      );
    }

    Statement parseOperationOrDirective(List<Token> tokens) {
      if (!tokens.first.isIdentifier) {
        throw ParserException(
            'Identifier expected at the start of a statement.');
      }
      final name = tokens.removeAt(0);

      SizeStatement size;
      if (tokens.first.isDot) {
        tokens.removeAt(0);
        tryAndCatchError(() {
          size = parseSizeStatement(tokens.removeAt(0));
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
          operands.add(parseOperandStatement(operandTokens));
        });
      }

      return OperationStatement(
        line: line,
        operation:
            null, // Use the [name] and [operands] to find the correct operation.
        size: size,
        operands: operands,
      );
    }

    final tokensByLine = groupBy<Token, int>(
      tokens,
      (Token token) => token.line,
    );

    final labelsWaitingForCode = <Label, int>{};

    tokensByLine.forEach((line, tokens) {
      // Global label line.
      if (tokens.first.isIdentifier && tokens[1].isColon) {
        labelsWaitingForCode[Label(tokens.first.literal)] = line;
        tokens.removeRange(0, 2);
      }

      // Local label line.
      if (tokens.first.isDot && tokens[1].isIdentifier && tokens[2].isColon) {
        labelsWaitingForCode[Label('.${tokens[1].literal}')] = line;
        tokens.removeRange(0, 3);
      }

      // Comment at the end of the line.
      String comment;
      if (tokens.last.isComment) {
        comment = tokens.last.literal;
        tokens.removeLast();
      }

      if (tokens.isEmpty) {
        if (comment != null) {
          statements.add(CommentStatement(line: line, comment: comment));
        }
      }

      // This is an operation or a directive.
      labels.addAll({
        for (final label in labelsWaitingForCode.keys) label: statements.length,
      });
      tryAndCatchError(() {
        statements.add(parseOperationOrDirective(tokens));
      });
    });

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
}
