import 'package:meta/meta.dart';

import '../error.dart';
import '../location.dart';
import 'token.dart';

export 'token.dart';

extension ScannableTokens on String {
  List<Token> scanned([ErrorCollector errorCollector]) {
    errorCollector ??= ErrorCollector();
    return scan(source: this, errorCollector: errorCollector);
  }
}

const _singleCharTokens = {
  '(': TokenType.leftParen,
  ')': TokenType.rightParen,
  ',': TokenType.comma,
  '.': TokenType.dot,
  '+': TokenType.plus,
  '#': TokenType.numberSign,
  ':': TokenType.colon,
};
const _newline = ['\r', '\n'];
const _whitespace = [' ', '\t'];

List<Token> scan({
  @required String source,
  @required ErrorCollector errorCollector,
}) {
  assert(source != null);
  assert(errorCollector != null);

  final state = _ScannerState(source);
  while (!state.isAtEnd) {
    _scanNextToken(state: state, errorCollector: errorCollector);
  }

  return state.tokens;
}

void _scanNextToken({
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
  if (_isDecimalDigit(c) || (c == '-' && _isDecimalDigit(state.peek()))) {
    _parseDecimalNumber(state);
    return;
  } else if (c == '\$') {
    _parseHexNumber(state);
    return;
  } else if (c == '-') {
    state.addToken(TokenType.minus);
    return;
  }

  // Comment
  if (c == '*') {
    _parseComment(state);
    return;
  }

  // Whitespace
  if (_whitespace.contains(c)) {
    state.col++;
    state.start = state.current;
    return;
  } else if (_newline.contains(c)) {
    if (c == '\r' && state.peek() == '\n') {
      state.advance();
    }
    state.line++;
    state.start = state.current;
    state.col = 1;
    return;
  }

  // Identifier
  if (_isLetterDigitUnderscore(c)) {
    _parseIdentifier(state);
    return;
  }

  errorCollector.add(Error(
    location: state.location.withLength(1),
    message: 'Unexpected character $c.',
  ));
}

bool _isDecimalDigit(String c) => '1234567890'.contains(c);
bool _isHexDigit(String c) => '1234567890ABCDEFabcdef'.contains(c);

bool _isLetterDigitUnderscore(String c) =>
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'.contains(c) ||
    _isDecimalDigit(c);

void _parseToken<T>({
  @required _ScannerState state,
  @required TokenType type,
  @required bool Function(String char) selector,
}) {
  assert(state != null);
  state.advanceWhile(selector);
  state.addToken(type);
}

void _parseDecimalNumber(_ScannerState state) => _parseToken(
      state: state,
      type: TokenType.number,
      selector: _isDecimalDigit,
    );
void _parseHexNumber(_ScannerState state) {
  assert(state != null);

  if (state.peek() == '-') state.advance();
  _parseToken(
    state: state,
    type: TokenType.number,
    selector: _isHexDigit,
  );
}

void _parseComment(_ScannerState state) => _parseToken(
      state: state,
      type: TokenType.comment,
      selector: (c) => !_newline.contains(c),
    );
void _parseIdentifier(_ScannerState state) => _parseToken(
      state: state,
      type: TokenType.identifier,
      selector: _isLetterDigitUnderscore,
    );

class _ScannerState {
  _ScannerState(this.source) : assert(source != null);

  final String source;

  int start = 0;
  int line = 1;
  int col = 1;
  Location get location => Location(line: line, col: col, length: 0);
  int current = 0;
  final tokens = <Token>[];

  bool get isAtEnd => current >= source.length;
  String peek() => isAtEnd ? '\x00' : source[current];
  String get currentLexeme => source.substring(start, current);

  String advance() => source[current++];

  String advanceWhile(bool Function(String char) predicate) {
    while (predicate(peek()) && !isAtEnd) {
      advance();
    }
    return source.substring(start, current);
  }

  void addToken(TokenType type) {
    tokens.add(Token(
      type: type,
      location: location.withLength(currentLexeme.length),
      lexeme: currentLexeme,
    ));
    col += current - start;
    start = current;
  }
}
