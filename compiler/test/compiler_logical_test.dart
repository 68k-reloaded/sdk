import 'package:kt_dart/kt.dart';
import 'package:m68k_reloaded_compiler/compiler.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:test/test.dart';

import 'statement_utils.dart';

void main() {
  group('Compiler compiles single logical statement', () {
    group('NOT:', () {
      <String, StatementWithExpectedResult>{
        'NOT.B D0': StatementWithExpectedResult(
          operation: Operation.not,
          size: Size.byte,
          operands: [dx(0)],
          expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        ),
        'NOT.W D0': StatementWithExpectedResult(
          operation: Operation.not,
          size: Size.word,
          operands: [dx(0)],
          expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0],
        ),
        'NOT.L D0': StatementWithExpectedResult(
          operation: Operation.not,
          size: Size.longWord,
          operands: [dx(0)],
          expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0],
        ),
        'NOT.W A1': StatementWithExpectedResult(
          operation: Operation.not,
          size: Size.word,
          operands: [ax(1)],
          expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
        ),
        'NOT.B -(A5)': StatementWithExpectedResult(
          operation: Operation.not,
          size: Size.byte,
          operands: [axIndWithPreDec(5)],
          expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1],
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
