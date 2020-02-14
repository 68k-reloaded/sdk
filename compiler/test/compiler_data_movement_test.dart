import 'package:m68k_reloaded_compiler/src/bits.dart';
import 'package:m68k_reloaded_compiler/src/compiler.dart';
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
          expectedResult: CompiledStatement(
            [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].bits,
          ),
        ),
        'MOVEQ.L #2, D7': StatementWithExpectedResult(
          operation: Operation.moveq,
          size: Size.word,
          operands: [immediate(2), dx(7)],
          expectedResult: CompiledStatement(
            [0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0].bits,
          ),
        ),
        'MOVEQ.L #\$42, D3': StatementWithExpectedResult(
          operation: Operation.moveq,
          size: Size.longWord,
          operands: [immediate(0x42), dx(3)],
          expectedResult: CompiledStatement(
            [0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0].bits,
          ),
        ),
      }.forEach((name, stmt) {
        test(name, () => stmt.test());
      });
    });
  });
}
