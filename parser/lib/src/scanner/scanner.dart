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

    int _start = 0;
    int _current = 0;
    int _line = 1;

    bool isAtEnd() => _current >= source.length;
    String peek() => isAtEnd() ? '\0' : source[_current];
    String advance() => source[_current++];
    String advanceWhile(bool Function(String char) predicate) {
      while (predicate(peek())) {
        advance();
      }
      return source.substring(_start, _current);
    }

    void addToken(TokenType type, [dynamic literal]) {
      tokens.add(Token(
        type: type,
        line: _line,
        lexeme: source.substring(_start, _current),
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

      if (_isDecimalDigit(c)) {
        parseDecimalNumber();
        return;
      }

      if (c == '\$') {
        parseHexNumber();
        return;
      }

      if (c == '*') {
        parseComment();
        return;
      }

      if (' \t\r'.contains(c)) {
        return;
      }

      if (c == '\n') {
        _line++;
        return;
      }

      if (_isLetterDigitUnderscore(c)) {
        parseIdentifier();
        return;
      }

      errorCollector.add(Error(
        line: _line,
        message: 'Unexpected character $c.',
      ));
    }

    while (!isAtEnd()) {
      _start = _current;
      scanToken();
    }
    tokens.add(Token(type: TokenType.eof, line: _line));

    return tokens;
  }

  static bool _isDecimalDigit(String c) => '1234567890'.contains(c);
  static bool _isHexDigit(String c) => '1234567890ABCDEFabcdef'.contains(c);

  static bool _isLetterDigitUnderscore(String c) =>
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'.contains(c) ||
      _isDecimalDigit(c);
}
