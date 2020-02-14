import 'package:data_classes/data_classes.dart';
import 'package:meta/meta.dart';

import '../location.dart';

enum TokenType {
  // Single-character tokens.
  leftParen,
  rightParen,
  comma,
  dot,
  minus,
  plus,
  numberSign, // #
  colon,

  // Literals.
  comment,
  identifier,
  string,
  number,
}

class Token {
  final TokenType type;
  final Location location;
  final String lexeme;
  final dynamic literal;

  bool get isLeftParen => type == TokenType.leftParen;
  bool get isRightParen => type == TokenType.rightParen;
  bool get isComma => type == TokenType.comma;
  bool get isDot => type == TokenType.dot;
  bool get isMinus => type == TokenType.minus;
  bool get isPlus => type == TokenType.plus;
  bool get isNumberSign => type == TokenType.numberSign;
  bool get isColon => type == TokenType.colon;
  bool get isComment => type == TokenType.comment;
  bool get isIdentifier => type == TokenType.identifier;
  bool get isString => type == TokenType.string;
  bool get isNumber => type == TokenType.number;

  const Token({
    @required this.type,
    @required this.location,
    this.lexeme,
    this.literal,
  }) : assert(location != null);

  String toString() {
    return '${type.toString().substring('TokenType.'.length)} at $location: "$lexeme" (Literal: $literal)';
  }

  bool operator ==(Object other) =>
      other is Token &&
      type == other.type &&
      location == other.location &&
      lexeme == other.lexeme &&
      literal == other.literal;
  int get hashCode => hashList([type, location, lexeme, literal]);
}

class NullToken extends Token {
  const NullToken()
      : super(
          type: null, // We match no type.
          location: const Location.invalid(),
        );
}
