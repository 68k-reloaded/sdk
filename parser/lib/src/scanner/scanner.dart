import 'package:meta/meta.dart';

import '../error.dart';
import 'token.dart';

export 'token.dart';

class Scanner {
  Scanner._();

  static const _singleCharTokens = {
    '(': TokenType.leftParen,
    ')': TokenType.rightParen,
    ',': TokenType.comma,
    '.': TokenType.dot,
    '-': TokenType.minus,
    '+': TokenType.plus,
    '#': TokenType.numberSign,
    ':': TokenType.colon,
  };

  static List<Token> scan({
    @required String source,
    @required ErrorCollector errorCollector,
  }) {
    assert(source != null);
    assert(errorCollector != null);

    final state = _ScannerState(source);
    while (!state.isAtEnd) {
      state.start = state.current;
      _scanToken(state: state, errorCollector: errorCollector);
    }

    state.addToken(TokenType.eof);
    return state.tokens;
  }

  static bool _isDecimalDigit(String c) => '1234567890'.contains(c);
  static bool _isHexDigit(String c) => '1234567890ABCDEFabcdef'.contains(c);

  static bool _isLetterDigitUnderscore(String c) =>
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'.contains(c) ||
      _isDecimalDigit(c);

  static void _parseToken<T>({
    @required _ScannerState state,
    @required TokenType type,
    @required bool Function(String char) selector,
    dynamic Function(String raw) mapper = it,
  }) {
    assert(state != null);
    final raw = state.advanceWhile(selector);
    state.addToken(TokenType.number, mapper(raw));
  }

  static void _parseDecimalNumber(_ScannerState state) => _parseToken(
        state: state,
        type: TokenType.number,
        selector: _isDecimalDigit,
        mapper: (raw) => int.parse(raw),
      );
  static void _parseHexNumber(_ScannerState state) => _parseToken(
        state: state,
        type: TokenType.number,
        selector: _isHexDigit,
        mapper: (raw) => int.parse(raw, radix: 16),
      );
  static void _parseComment(_ScannerState state) => _parseToken(
        state: state,
        type: TokenType.comment,
        selector: (c) => c != '\n',
      );
  static void _parseIdentifier(_ScannerState state) => _parseToken(
        state: state,
        type: TokenType.identifier,
        selector: _isLetterDigitUnderscore,
      );

  static void _scanToken({
    @required _ScannerState state,
    @required ErrorCollector errorCollector,
  }) {
    assert(state != null);
    assert(errorCollector != null);

    final c = state.advance();

    if (_singleCharTokens.containsKey(c)) {
      state.addToken(_singleCharTokens[c]);
      return;
    }

    // Numbers
    if (_isDecimalDigit(c)) {
      _parseDecimalNumber(state);
      return;
    } else if (c == '\$') {
      _parseHexNumber(state);
      return;
    }

    // Comment
    if (c == '*') {
      _parseComment(state);
      return;
    }

    // Whitespace
    if (' \t\r'.contains(c)) {
      return;
    } else if (c == '\n') {
      state.line++;
      return;
    }

    // Identifier
    if (_isLetterDigitUnderscore(c)) {
      _parseIdentifier(state);
      return;
    }

    errorCollector.add(Error(
      line: state.line,
      message: 'Unexpected character $c.',
    ));
  }
}

class _ScannerState {
  _ScannerState(this.source) : assert(source != null);

  final String source;

  int start = 0;
  int current = 0;
  int line = 1;
  final tokens = <Token>[];

  bool get isAtEnd => current >= source.length;
  String peek() => isAtEnd ? '\0' : source[current];
  String get currentLexeme => source.substring(start, current);

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
      lexeme: currentLexeme,
      literal: literal,
    ));
  }
}

T it<T>(T value) => value;
