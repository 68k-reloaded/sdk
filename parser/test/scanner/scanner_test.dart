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
      final singleTokens = {
        '(': TokenType.leftParen,
        ')': TokenType.rightParen,
        ',': TokenType.comma,
        '.': TokenType.dot,
        '-': TokenType.minus,
        '+': TokenType.plus,
        '#': TokenType.numberSign,
        ':': TokenType.colon,
      };
      singleTokens.forEach(
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

      final whitespace = {'space': ' ', 'tab': '\t'};
      whitespace.forEach((name, char) {
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
      final shouldWork = {
        'single char': 'i',
        'short': 'id',
        'long':
            'Loremipsumdolorsitametconsecteturadipiscingelit_Maurisvitaeerosblanditipsumviverraposuereetanibh_Curabiturnislmetuslaciniautmagnaultricieselementumtempormassa_Sedaliqueteliturnanonauctornuncfeugiata_Maurissedsemperarcueurutrumlorem_Etiamutaugueeuipsummollisconsecteturnecsuscipiteros_Curabiturpellentesqueturpisaugueetcursusnuncsagittisat_Aeneanconguevestibulumenimnonpellentesque_Fuscelobortisexaquamplaceratsollicitudinimperdietarcuvehicula_Fuscepulvinarcommodoodio_Integergravidaportarisusegetsemper_Utpellentesquejustoatdignissimornare_Praesentsagittisnequevitaemetuspulvinaraliquam_Nullaeuvulputateenimidposuerelectus_Namsemperligulanibhvelviverraerategestasac',
      };
      shouldWork.forEach((name, identifier) {
        test(name, () {
          final tokens = scan(identifier);
          checkForSingleContentToken(tokens, TokenType.identifier);
          expect(tokens.first.literal, isA<String>());
          expect(tokens.first.literal, equals(identifier));
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
