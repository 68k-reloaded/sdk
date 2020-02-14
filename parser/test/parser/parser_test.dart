import 'package:m68k_reloaded_parser/src/error.dart';
import 'package:m68k_reloaded_parser/src/parser/parser.dart';
import 'package:m68k_reloaded_parser/src/scanner/scanner.dart';
import 'package:test/test.dart';

void main() {
  group('Parser runs', () {
    ErrorCollector errorCollector;
    setUp(() {
      errorCollector = ErrorCollector();
    });

    void expectParsedStatements(
      String source,
      List<Statement> expected,
    ) {
      expect(
        Parser.parse(
          tokens: Scanner.scan(source: source, errorCollector: errorCollector),
          errorCollector: errorCollector,
        ).statements,
        equals(expected),
      );
      expect(errorCollector.errors.asList(), isEmpty);
    }

    test('empty program', () {
      expectParsedStatements('', []);
    });

    tearDown(() {
      errorCollector = null;
    });
  });
}
