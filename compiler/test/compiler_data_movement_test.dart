import 'package:kt_dart/kt.dart';
import 'package:m68k_reloaded_compiler/compiler.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:test/test.dart';

import 'statement_utils.dart';

void main() {
  group('Compiler compiles single data movement statement', () {
    group('MOVEQ:', () {
      <String, StatementWithExpectedResult>{
        'MOVEQ.L #0, D0': StatementWithExpectedResult(
          operation: Operation.moveq,
          size: Size.longWord,
          operands: [immediate(0), dx(0)],
          expectedResult: [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        ),
        'MOVEQ.L #2, D7': StatementWithExpectedResult(
          operation: Operation.moveq,
          size: Size.word,
          operands: [immediate(2), dx(7)],
          expectedResult: [0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0],
        ),
        'MOVEQ.L #\$42, D3': StatementWithExpectedResult(
          operation: Operation.moveq,
          size: Size.longWord,
          operands: [immediate(0x42), dx(3)],
          expectedResult: [0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0],
        ),
      }.forEach((name, stmt) {
        test(name, () {
          final program = Program(
            statements: KtList.of(stmt.statement),
            labelsToIndex: {},
          );
          final compiled = Compiler.compile(program);
          expect(compiled, equals(stmt.expectedResult));
        });
      });
    });
  });
}
