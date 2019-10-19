import 'package:meta/meta.dart';

enum TokenType {
  // Single-character tokens.
  LEFT_PAREN,
  RIGHT_PAREN,
  COMMA,
  DOT,
  MINUS,
  PLUS,
  NUMBER_SIGN, // #
  COLON,

  // Literals.
  COMMENT,
  IDENTIFIER,
  STRING,
  NUMBER,

  EOF
}

class Token {
  final TokenType type;
  final int line;
  final String lexeme;
  final dynamic literal;

  Token({
    @required this.type,
    @required this.line,
    this.lexeme,
    this.literal,
  })  : assert(type != null),
        assert(line != null);

  String toString() {
    return '${type.toString().substring('TokenType.'.length)} at $line: "$lexeme" (Literal: $literal)';
  }
}
