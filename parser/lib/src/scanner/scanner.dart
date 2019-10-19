import 'package:meta/meta.dart';

import '../error.dart';
import 'token.dart';

export 'token.dart';

class Scanner {
  Scanner({
    @required this.source,
    @required this.errorCollector,
  })  : assert(source != null),
        assert(errorCollector != null);

  final String source;
  final tokens = <Token>[];
  final ErrorCollector errorCollector;

  // The current state.
  int _start = 0;
  int _current = 0;
  int _line = 1;

  bool get _isAtEnd => _current >= source.length;

  void scanTokens() {
    while (!_isAtEnd) {
      _start = _current;
      _scanToken();
    }

    tokens.add(Token(type: TokenType.EOF, line: _line));
  }

  String _advance() => source[_current++];

  String _advanceWhile(bool Function(String char) predicate) {
    while (predicate(_peek())) {
      _advance();
    }
    return source.substring(_start, _current);
  }

  String _peek() => _isAtEnd ? '\0' : source[_current];

  void _scanToken() {
    final c = _advance();
    const singleCharTokens = {
      '(': TokenType.LEFT_PAREN,
      ')': TokenType.RIGHT_PAREN,
      ',': TokenType.COMMA,
      '.': TokenType.DOT,
      '-': TokenType.MINUS,
      '+': TokenType.PLUS,
      '#': TokenType.NUMBER_SIGN,
      ':': TokenType.COLON,
    };

    if (singleCharTokens.containsKey(c)) {
      _addToken(singleCharTokens[c]);
      return;
    }

    if (_isDecimalDigit(c)) {
      _parseDecimalNumber();
      return;
    }

    if (c == '\$') {
      _parseHexNumber();
      return;
    }

    if (c == '*') {
      _parseComment();
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
      _parseIdentifier();
      return;
    }

    errorCollector.add(Error(
      line: _line,
      message: 'Unexpected character $c.',
    ));
  }

  void _addToken(TokenType type, [dynamic literal]) {
    tokens.add(Token(
      type: type,
      line: _line,
      lexeme: source.substring(_start, _current),
      literal: literal,
    ));
  }

  bool _isDecimalDigit(String c) => '1234567890'.contains(c);
  bool _isHexDigit(String c) => '1234567890ABCDEFabcdef'.contains(c);

  bool _isLetterDigitUnderscore(String c) =>
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'.contains(c) ||
      _isDecimalDigit(c);

  void _parseDecimalNumber() {
    final number = _advanceWhile(_isDecimalDigit);
    _addToken(TokenType.NUMBER, int.parse(number));
  }

  void _parseHexNumber() {
    final number = _advanceWhile(_isHexDigit);
    _addToken(TokenType.NUMBER, int.parse(number, radix: 16));
  }

  void _parseComment() {
    final comment = _advanceWhile((c) => c != '\n');
    _addToken(TokenType.COMMENT, comment);
  }

  void _parseIdentifier() {
    final identifier = _advanceWhile(_isLetterDigitUnderscore);
    _addToken(TokenType.IDENTIFIER, identifier);
  }
}
