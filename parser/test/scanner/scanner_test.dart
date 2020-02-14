import 'package:test/test.dart';

import '../../lib/src/error.dart';
import '../../lib/src/location.dart';
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
      int col = 1,
      Location location = null,
    }) =>
        Token(
          type: type,
          location: location ?? Location(line: line, col: col),
          lexeme: lexeme,
          literal: literal,
        );

    void expectScannedTokens(
      String source,
      List<Token> expected,
      Location eofLocation,
    ) {
      expect(
        Scanner.scan(
          source: source,
          errorCollector: errorCollector,
        ),
        equals(expected),
      );
      expect(errorCollector.errors.asList(), isEmpty);
    }

    test('empty String', () {
      expectScannedTokens('', [], Location(line: 1, col: 1));
    });
    test('whitespace', () {
      expectScannedTokens(' \t', [], Location(line: 1, col: 3));
    });
    test('empty lines', () {
      expectScannedTokens('\n\r\n', [], Location(line: 3, col: 1));
    });
    test('with correct line counting', () {
      expectScannedTokens(
        '*1\n*2\r*3\r\n*4',
        [
          createToken(TokenType.comment, '*1',
              location: Location(line: 1, col: 1), literal: '1'),
          createToken(TokenType.comment, '*2',
              location: Location(line: 2, col: 1), literal: '2'),
          createToken(TokenType.comment, '*3',
              location: Location(line: 3, col: 1), literal: '3'),
          createToken(TokenType.comment, '*4',
              location: Location(line: 4, col: 1), literal: '4'),
        ],
        Location(line: 4, col: 3),
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
          expectScannedTokens(
            token,
            [createToken(type, token)],
            Location(line: 1, col: 2),
          );
        }),
      );
    });

    group('comment:', () {
      test('empty', () {
        expectScannedTokens(
          '*',
          [createToken(TokenType.comment, '*', literal: '')],
          Location(line: 1, col: 2),
        );
      });
      test('simple', () {
        expectScannedTokens(
          '*comment...',
          [
            createToken(TokenType.comment, '*comment...', literal: 'comment...')
          ],
          Location(line: 1, col: 12),
        );
      });
      test('unicode', () {
        final unicode =
            'äöüß é¡™£¢∞§¶•ªº–≠製漢語 ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็❤️🇺🇸🇷🇺🇸 Ṱ̺̺̕o͞ ̷i̲̬͇̪͙n̝̗͕v̟̜̘̦͟o̶̙̰̠kè͚̮̺̪̹̱̤ ᴉlɐ';
        expectScannedTokens(
          '*$unicode',
          [createToken(TokenType.comment, '*$unicode', literal: unicode)],
          Location(line: 1, col: 168),
        );
      });

      <String, String>{
        'space': ' ',
        'tab': '\t',
      }.forEach((name, char) {
        test('with whitespace ($name)', () {
          final comment = '${char}comment...';
          expectScannedTokens(
            '*$comment',
            [createToken(TokenType.comment, '*$comment', literal: comment)],
            Location(line: 1, col: 13),
          );
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
          expectScannedTokens(
            identifier,
            [
              createToken(TokenType.identifier, identifier, literal: identifier)
            ],
            Location(line: 1, col: identifier.length + 1),
          );
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
          expectScannedTokens(
            raw,
            [createToken(TokenType.number, raw, literal: expected)],
            Location(line: 1, col: raw.length + 1),
          );
        });
      });
    });

    group('line:', () {
      <String, List<Token>>{
        'label:': [
          createToken(TokenType.identifier, 'label', literal: 'label'),
          createToken(TokenType.colon, ':', col: 6),
        ],
        'ADD D0, D1': [
          createToken(TokenType.identifier, 'ADD', literal: 'ADD'),
          createToken(TokenType.identifier, 'D0', literal: 'D0', col: 5),
          createToken(TokenType.comma, ',', col: 7),
          createToken(TokenType.identifier, 'D1', literal: 'D1', col: 9),
        ],
        'ADD.B D0, D1': [
          createToken(TokenType.identifier, 'ADD', literal: 'ADD'),
          createToken(TokenType.dot, '.', col: 4),
          createToken(TokenType.identifier, 'B', literal: 'B', col: 5),
          createToken(TokenType.identifier, 'D0', literal: 'D0', col: 7),
          createToken(TokenType.comma, ',', col: 9),
          createToken(TokenType.identifier, 'D1', literal: 'D1', col: 11),
        ],
        ' ADD        D0,D1': [
          createToken(TokenType.identifier, 'ADD', literal: 'ADD', col: 2),
          createToken(TokenType.identifier, 'D0', literal: 'D0', col: 13),
          createToken(TokenType.comma, ',', col: 15),
          createToken(TokenType.identifier, 'D1', literal: 'D1', col: 16),
        ],
        'label: ADD D0, D1': [
          createToken(TokenType.identifier, 'label', literal: 'label'),
          createToken(TokenType.colon, ':', col: 6),
          createToken(TokenType.identifier, 'ADD', literal: 'ADD', col: 8),
          createToken(TokenType.identifier, 'D0', literal: 'D0', col: 12),
          createToken(TokenType.comma, ',', col: 14),
          createToken(TokenType.identifier, 'D1', literal: 'D1', col: 16),
        ],
        'MOVE.B #42,D1': [
          createToken(TokenType.identifier, 'MOVE', literal: 'MOVE'),
          createToken(TokenType.dot, '.', col: 5),
          createToken(TokenType.identifier, 'B', literal: 'B', col: 6),
          createToken(TokenType.numberSign, '#', col: 8),
          createToken(TokenType.number, '42', literal: 42, col: 9),
          createToken(TokenType.comma, ',', col: 11),
          createToken(TokenType.identifier, 'D1', literal: 'D1', col: 12),
        ],
        'MOVE.W (A0),D3': [
          createToken(TokenType.identifier, 'MOVE', literal: 'MOVE'),
          createToken(TokenType.dot, '.', col: 5),
          createToken(TokenType.identifier, 'W', literal: 'W', col: 6),
          createToken(TokenType.leftParen, '(', col: 8),
          createToken(TokenType.identifier, 'A0', literal: 'A0', col: 9),
          createToken(TokenType.rightParen, ')', col: 11),
          createToken(TokenType.comma, ',', col: 12),
          createToken(TokenType.identifier, 'D3', literal: 'D3', col: 13),
        ],
        'MOVE.W (123, A0), (A1)- * comment': [
          createToken(TokenType.identifier, 'MOVE', literal: 'MOVE'),
          createToken(TokenType.dot, '.', col: 5),
          createToken(TokenType.identifier, 'W', literal: 'W', col: 6),
          createToken(TokenType.leftParen, '(', col: 8),
          createToken(TokenType.number, '123', literal: 123, col: 9),
          createToken(TokenType.comma, ',', col: 12),
          createToken(TokenType.identifier, 'A0', literal: 'A0', col: 14),
          createToken(TokenType.rightParen, ')', col: 16),
          createToken(TokenType.comma, ',', col: 17),
          createToken(TokenType.leftParen, '(', col: 19),
          createToken(TokenType.identifier, 'A1', literal: 'A1', col: 20),
          createToken(TokenType.rightParen, ')', col: 22),
          createToken(TokenType.minus, '-', col: 23),
          createToken(TokenType.comment, '* comment',
              literal: ' comment', col: 25),
        ],
      }.forEach((raw, expected) {
        test('"$raw"', () {
          expectScannedTokens(
            raw,
            expected,
            Location(line: 1, col: raw.length + 1),
          );
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
