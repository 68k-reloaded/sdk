import 'package:meta/meta.dart';

import '../error.dart';
import 'token.dart';

export 'token.dart';

class Scanner {
  Scanner._();

  static List<Token> scan({
    @required String source,
    @required ErrorCollector errorCollector,
  }) {
    assert(source != null);
    assert(errorCollector != null);
    final tokens = <Token>[];

    int start = 0;
    int current = 0;
    int line = 1;

    bool isAtEnd() => current >= source.length;
    String peek() => isAtEnd() ? '\0' : source[current];
    String advance() => source[current++];
    String advanceWhile(bool Function(String char) predicate) {
      while (predicate(peek())) {
        advance();
      }
      return source.substring(start, current);
    }

    void addToken(TokenType type, [dynamic literal]) {
      tokens.add(Token(
        type: type,
        line: line,
        lexeme: source.substring(start, current),
        literal: literal,
      ));
    }

    void parseDecimalNumber() {
      final number = advanceWhile(_isDecimalDigit);
      addToken(TokenType.number, int.parse(number));
    }

    void parseHexNumber() {
      final number = advanceWhile(_isHexDigit);
      addToken(TokenType.number, int.parse(number, radix: 16));
    }

    void parseComment() {
      final comment = advanceWhile((c) => c != '\n');
      addToken(TokenType.comment, comment);
    }

    void parseIdentifier() {
      final identifier = advanceWhile(_isLetterDigitUnderscore);
      addToken(TokenType.identifier, identifier);
    }

    void scanToken() {
      final c = advance();

      const singleCharTokens = {
        '(': TokenType.leftParen,
        ')': TokenType.rightParen,
        ',': TokenType.comma,
        '.': TokenType.dot,
        '-': TokenType.minus,
        '+': TokenType.plus,
        '#': TokenType.numberSign,
        ':': TokenType.colon,
      };
      if (singleCharTokens.containsKey(c)) {
        addToken(singleCharTokens[c]);
        return;
      }

      // Numbers
      if (_isDecimalDigit(c)) {
        parseDecimalNumber();
        return;
      }
      if (c == '\$') {
        parseHexNumber();
        return;
      }

      // Comment
      if (c == '*') {
        parseComment();
        return;
      }

      // Whitespace
      if (' \t\r'.contains(c)) {
        return;
      }
      if (c == '\n') {
        line++;
        return;
      }

      // Identifier
      if (_isLetterDigitUnderscore(c)) {
        parseIdentifier();
        return;
      }

      errorCollector.add(Error(
        line: line,
        message: 'Unexpected character $c.',
      ));
    }

    while (!isAtEnd()) {
      start = current;
      scanToken();
    }
    tokens.add(Token(type: TokenType.eof, line: line));

    return tokens;
  }

  static bool _isDecimalDigit(String c) => '1234567890'.contains(c);
  static bool _isHexDigit(String c) => '1234567890ABCDEFabcdef'.contains(c);

  static bool _isLetterDigitUnderscore(String c) =>
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'.contains(c) ||
      _isDecimalDigit(c);
}
