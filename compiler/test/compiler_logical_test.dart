import 'package:m68k_reloaded_compiler/src/bits.dart';
import 'package:m68k_reloaded_compiler/src/compiler.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:test/test.dart';

import 'statement_utils.dart';

void main() {
  group('Compiler compiles single logical statement', () {
    group('NOT:', () {
      <String, StatementWithExpectedResult>{
        'NOT.B D0': StatementWithExpectedResult(
          type: OperationType.not,
          size: SizeValue.byte,
          operands: [dx(0)],
          expectedResult: CompiledStatement(
            [0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0].bits,
          ),
        ),
        'NOT.W D0': StatementWithExpectedResult(
          type: OperationType.not,
          size: SizeValue.word,
          operands: [dx(0)],
          expectedResult: CompiledStatement(
            [0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0].bits,
          ),
        ),
        'NOT.L D0': StatementWithExpectedResult(
          type: OperationType.not,
          size: SizeValue.longWord,
          operands: [dx(0)],
          expectedResult: CompiledStatement(
            [0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0].bits,
          ),
        ),
        'NOT.W A1': StatementWithExpectedResult(
          type: OperationType.not,
          size: SizeValue.word,
          operands: [ax(1)],
          expectedResult: CompiledStatement(
            [0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1].bits,
          ),
        ),
        'NOT.B -(A5)': StatementWithExpectedResult(
          type: OperationType.not,
          size: SizeValue.byte,
          operands: [axIndWithPreDec(5)],
          expectedResult: CompiledStatement(
            [0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1].bits,
          ),
        ),
      }.forEach((name, stmt) {
        test(name, () => stmt.test());
      });
    });
  });
}
