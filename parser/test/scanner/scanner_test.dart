import 'package:test/test.dart';

import '../../lib/src/error.dart';
import '../../lib/src/scanner/scanner.dart';

void main() {
  group('Scanner scans', () {
    ErrorCollector errorCollector;
    setUp(() {
      errorCollector = ErrorCollector();
    });

    Token createToken(
      TokenType type,
      String lexeme, {
      dynamic literal = null,
      int line = 1,
    }) =>
        Token(type: type, line: line, lexeme: lexeme, literal: literal);

    void expectScannedTokens(
      String source,
      List<Token> expected, {
      int lineCount = 1,
    }) {
      expect(
        Scanner.scan(
          source: source,
          errorCollector: errorCollector,
        ),
        equals([
          ...expected,
          createToken(TokenType.eof, '', line: lineCount),
        ]),
      );
      expect(errorCollector.errors.asList(), isEmpty);
    }

    test('empty String', () {
      expectScannedTokens('', []);
    });
    test('whitespace', () {
      expectScannedTokens(' \t', []);
    });
    test('empty lines', () {
      expectScannedTokens('\n\r\n', [], lineCount: 3);
    });
    test('with correct line counting', () {
      expectScannedTokens(
        '*1\n*2\r*3\r\n*4',
        [
          createToken(TokenType.comment, '*1', line: 1, literal: '1'),
          createToken(TokenType.comment, '*2', line: 2, literal: '2'),
          createToken(TokenType.comment, '*3', line: 3, literal: '3'),
          createToken(TokenType.comment, '*4', line: 4, literal: '4'),
        ],
        lineCount: 4,
      );
    });

    group('single token:', () {
      <String, TokenType>{
        '(': TokenType.leftParen,
        ')': TokenType.rightParen,
        ',': TokenType.comma,
        '.': TokenType.dot,
        '-': TokenType.minus,
        '+': TokenType.plus,
        '#': TokenType.numberSign,
        ':': TokenType.colon,
      }.forEach(
        (token, type) => test(_enumToString(type), () {
          expectScannedTokens(token, [createToken(type, token)]);
        }),
      );
    });

    group('comment:', () {
      test('empty', () {
        expectScannedTokens('*', [
          createToken(TokenType.comment, '*', literal: ''),
        ]);
      });
      test('simple', () {
        expectScannedTokens('*comment...', [
          createToken(TokenType.comment, '*comment...', literal: 'comment...'),
        ]);
      });
      test('unicode', () {
        final unicode =
            'äöüß é¡™£¢∞§¶•ªº–≠製漢語 ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็❤️🇺🇸🇷🇺🇸 Ṱ̺̺̕o͞ ̷i̲̬͇̪͙n̝̗͕v̟̜̘̦͟o̶̙̰̠kè͚̮̺̪̹̱̤ ᴉlɐ';
        expectScannedTokens('*$unicode', [
          createToken(TokenType.comment, '*$unicode', literal: unicode),
        ]);
      });

      <String, String>{
        'space': ' ',
        'tab': '\t',
      }.forEach((name, char) {
        test('with whitespace ($name)', () {
          final comment = '${char}comment...';
          expectScannedTokens('*$comment', [
            createToken(TokenType.comment, '*$comment', literal: comment),
          ]);
        });
      });
    });

    group('identifier:', () {
      [
        'i',
        'id',
        '_id',
        'id123',
        'D0',
        'D7',
        'A0',
        'A7',
        'Loremipsumdolorsitametconsecteturadipiscingelit_Maurisvitaeerosblanditipsumviverraposuereetanibh_Curabiturnislmetuslaciniautmagnaultricieselementumtempormassa',
      ].forEach((identifier) {
        test('valid ($identifier)', () {
          expectScannedTokens(identifier, [
            createToken(TokenType.identifier, identifier, literal: identifier),
          ]);
        });
      });
    });

    group('number:', () {
      <String, int>{
        '-1234567890': -1234567890,
        '-12': -12,
        '-1': -1,
        '0': 0,
        '1': 1,
        '2': 2,
        '12': 12,
        '1234567890': 1234567890,
        '\$-1234567890': -0x1234567890,
        '\$-12': -0x12,
        '\$-1': -0x1,
        '\$0': 0x0,
        '\$1': 0x1,
        '\$2': 0x2,
        '\$12': 0x12,
        '\$1234567890': 0x1234567890,
      }.forEach((raw, expected) {
        test('valid ($raw)', () {
          expectScannedTokens(raw, [
            createToken(TokenType.number, raw, literal: expected),
          ]);
        });
      });
    });

    group('line:', () {
      <String, List<Token>>{
        'label:': [
          createToken(TokenType.identifier, 'label', literal: 'label'),
          createToken(TokenType.colon, ':'),
        ],
        'ADD D0, D1': [
          createToken(TokenType.identifier, 'ADD', literal: 'ADD'),
          createToken(TokenType.identifier, 'D0', literal: 'D0'),
          createToken(TokenType.comma, ','),
          createToken(TokenType.identifier, 'D1', literal: 'D1'),
        ],
        'ADD.B D0, D1': [
          createToken(TokenType.identifier, 'ADD', literal: 'ADD'),
          createToken(TokenType.dot, '.'),
          createToken(TokenType.identifier, 'B', literal: 'B'),
          createToken(TokenType.identifier, 'D0', literal: 'D0'),
          createToken(TokenType.comma, ','),
          createToken(TokenType.identifier, 'D1', literal: 'D1'),
        ],
        ' ADD        D0,D1': [
          createToken(TokenType.identifier, 'ADD', literal: 'ADD'),
          createToken(TokenType.identifier, 'D0', literal: 'D0'),
          createToken(TokenType.comma, ','),
          createToken(TokenType.identifier, 'D1', literal: 'D1'),
        ],
        'label: ADD D0, D1': [
          createToken(TokenType.identifier, 'label', literal: 'label'),
          createToken(TokenType.colon, ':'),
          createToken(TokenType.identifier, 'ADD', literal: 'ADD'),
          createToken(TokenType.identifier, 'D0', literal: 'D0'),
          createToken(TokenType.comma, ','),
          createToken(TokenType.identifier, 'D1', literal: 'D1'),
        ],
        'MOVE.B #42,D1': [
          createToken(TokenType.identifier, 'MOVE', literal: 'MOVE'),
          createToken(TokenType.dot, '.'),
          createToken(TokenType.identifier, 'B', literal: 'B'),
          createToken(TokenType.numberSign, '#'),
          createToken(TokenType.number, '42', literal: 42),
          createToken(TokenType.comma, ','),
          createToken(TokenType.identifier, 'D1', literal: 'D1'),
        ],
        'MOVE.W (A0),D3': [
          createToken(TokenType.identifier, 'MOVE', literal: 'MOVE'),
          createToken(TokenType.dot, '.'),
          createToken(TokenType.identifier, 'W', literal: 'W'),
          createToken(TokenType.leftParen, '('),
          createToken(TokenType.identifier, 'A0', literal: 'A0'),
          createToken(TokenType.rightParen, ')'),
          createToken(TokenType.comma, ','),
          createToken(TokenType.identifier, 'D3', literal: 'D3'),
        ],
        'MOVE.W (123, A0), (A1)- * comment': [
          createToken(TokenType.identifier, 'MOVE', literal: 'MOVE'),
          createToken(TokenType.dot, '.'),
          createToken(TokenType.identifier, 'W', literal: 'W'),
          createToken(TokenType.leftParen, '('),
          createToken(TokenType.number, '123', literal: 123),
          createToken(TokenType.comma, ','),
          createToken(TokenType.identifier, 'A0', literal: 'A0'),
          createToken(TokenType.rightParen, ')'),
          createToken(TokenType.comma, ','),
          createToken(TokenType.leftParen, '('),
          createToken(TokenType.identifier, 'A1', literal: 'A1'),
          createToken(TokenType.rightParen, ')'),
          createToken(TokenType.minus, '-'),
          createToken(TokenType.comment, '* comment', literal: ' comment'),
        ],
      }.forEach((raw, expected) {
        test('"$raw"', () {
          expectScannedTokens(raw, expected);
        });
      });
    });

    tearDown(() {
      errorCollector = null;
    });
  });
}

String _enumToString(dynamic value) {
  assert(value != null);

  final string = value.toString();
  return string.substring(string.indexOf('.') + 1);
}
