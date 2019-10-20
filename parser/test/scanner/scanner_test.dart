import 'package:test/test.dart';

import '../../lib/src/error.dart';
import '../../lib/src/scanner/scanner.dart';

void main() {
  group('Scanner scans', () {
    ErrorCollector errorCollector;
    setUp(() {
      errorCollector = ErrorCollector();
    });

    void checkEndsWithEof(List<Token> tokens) =>
        expect(tokens.last.isEof, isTrue);
    void checkForSingleContentToken(List<Token> tokens, TokenType type) {
      expect(tokens, hasLength(2));
      expect(tokens.first.type, equals(type));
      checkEndsWithEof(tokens);
    }

    void checkNoErrors() => expect(errorCollector.errors.asList(), isEmpty);

    List<Token> scan(String source) =>
        Scanner.scan(source: source, errorCollector: errorCollector);

    test('empty String', () {
      final tokens = scan('');
      expect(tokens, hasLength(1));
      checkEndsWithEof(tokens);
      checkNoErrors();
    });
    test('whitespace', () {
      final tokens = scan(' \t');
      expect(tokens, hasLength(1));
      checkEndsWithEof(tokens);
      checkNoErrors();
    });
    test('empty lines', () {
      final tokens = scan('\n\r\n');
      expect(tokens, hasLength(1));
      checkEndsWithEof(tokens);
      checkNoErrors();
    });
    test('with correct line counting', () {
      final tokens = scan('*1\n*2\r*3\r\n*4');
      expect(tokens, hasLength(5));
      expect(tokens[0].line, equals(1));
      expect(tokens[1].line, equals(2));
      expect(tokens[2].line, equals(3));
      expect(tokens[3].line, equals(4));
      checkEndsWithEof(tokens);
      checkNoErrors();
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
          final tokens = scan(token);
          checkForSingleContentToken(tokens, type);
          checkNoErrors();
        }),
      );
    });

    group('comment:', () {
      test('empty', () {
        final tokens = scan('*');
        checkForSingleContentToken(tokens, TokenType.comment);
        expect(tokens.first.literal, isA<String>());
        expect(tokens.first.literal, isEmpty);
        checkNoErrors();
      });
      test('simple', () {
        final tokens = scan('*comment...');
        checkForSingleContentToken(tokens, TokenType.comment);
        expect(tokens.first.literal, isA<String>());
        expect(tokens.first.literal, equals('comment...'));
        checkNoErrors();
      });
      test('unicode', () {
        final unicode =
            'äöüß é¡™£¢∞§¶•ªº–≠製漢語 ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็❤️🇺🇸🇷🇺🇸 Ṱ̺̺̕o͞ ̷i̲̬͇̪͙n̝̗͕v̟̜̘̦͟o̶̙̰̠kè͚̮̺̪̹̱̤ ᴉlɐ';
        final tokens = scan('*$unicode');
        checkForSingleContentToken(tokens, TokenType.comment);
        expect(tokens.first.literal, isA<String>());
        expect(tokens.first.literal, equals(unicode));
        checkNoErrors();
      });

      <String, String>{
        'space': ' ',
        'tab': '\t',
      }.forEach((name, char) {
        test('with whitespace ($name)', () {
          final tokens = scan('*${char}comment...');
          checkForSingleContentToken(tokens, TokenType.comment);
          expect(tokens.first.literal, isA<String>());
          expect(tokens.first.literal, equals('${char}comment...'));
          checkNoErrors();
        });
      });
    });

    group('identifier:', () {
      [
        'i',
        'id',
        '_id',
        'id123',
        'Loremipsumdolorsitametconsecteturadipiscingelit_Maurisvitaeerosblanditipsumviverraposuereetanibh_Curabiturnislmetuslaciniautmagnaultricieselementumtempormassa',
      ].forEach((identifier) {
        test('valid ($identifier)', () {
          final tokens = scan(identifier);
          checkForSingleContentToken(tokens, TokenType.identifier);
          expect(tokens.first.literal, isA<String>());
          expect(tokens.first.literal, equals(identifier));
          checkNoErrors();
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
          final tokens = scan(raw);
          checkForSingleContentToken(tokens, TokenType.number);
          expect(tokens.first.literal, isA<int>());
          expect(tokens.first.literal, equals(expected));
          checkNoErrors();
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
