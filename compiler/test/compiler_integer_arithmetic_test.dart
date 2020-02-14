import 'package:m68k_reloaded_compiler/src/bits.dart';
import 'package:m68k_reloaded_compiler/src/compiler.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:test/test.dart';

import 'statement_utils.dart';

void main() {
  group('Compiler compiles single integer arithmetic statement', () {
    group('CMPI:', () {
      <String, StatementWithExpectedResult>{
        'CMPI.W #0, D0': StatementWithExpectedResult(
          type: OperationType.cmpi,
          size: SizeValue.word,
          operands: [immediate(0), dx(0)],
          expectedResult: CompiledStatement(
            [0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0].bits,
            immediateOrSourceExtensions: [Bits.word(0x00)],
          ),
        ),
        'CMPI.B #1, D2': StatementWithExpectedResult(
          type: OperationType.cmpi,
          size: SizeValue.byte,
          operands: [immediate(1), dx(0)],
          expectedResult: CompiledStatement(
            [0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0].bits,
            immediateOrSourceExtensions: [Bits.word(0x01)],
          ),
        ),
        'CMPI.L #\$42, A5': StatementWithExpectedResult(
          type: OperationType.cmpi,
          size: SizeValue.word,
          operands: [immediate(1), dx(0)],
          expectedResult: CompiledStatement(
            [0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1].bits,
            immediateOrSourceExtensions: [
              Bits.word(0x0000),
              Bits.word(0x0042),
            ],
          ),
        ),
      }.forEach((name, stmt) {
        test(name, () => stmt.test());
      });
    });
  });
}
