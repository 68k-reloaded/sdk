import 'package:m68k_reloaded_parser/src/error.dart';
import 'package:m68k_reloaded_parser/src/location.dart';
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
      expectParsedStatements(
        '* this is an empty program',
        [
          CommentStatement(
            location: Location(line: 1, col: 1),
            comment: 'this is an empty program',
          ),
        ],
      );
    });

    test('simple statements', () {
      expectParsedStatements(
        'move.w d1, d2',
        [
          OperationStatement(
            location: Location(line: 1, col: 1),
            operation: Operation.move,
            size: SizeStatement(
              location: Location(line: 1, col: 6),
              size: Size.word,
            ),
            operands: [
              DxOperandStatement(
                location: Location(line: 1, col: 8),
                register: DxRegisterStatement(
                  location: Location(line: 1, col: 8),
                  index: 1,
                ),
              ),
              DxOperandStatement(
                location: Location(line: 1, col: 12),
                register: DxRegisterStatement(
                  location: Location(line: 1, col: 12),
                  index: 2,
                ),
              ),
            ],
          ),
        ],
      );
    });

    tearDown(() {
      errorCollector = null;
    });
  });
}
