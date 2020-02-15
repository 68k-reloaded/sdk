import 'package:m68k_reloaded_compiler/src/bits.dart';
import 'package:m68k_reloaded_compiler/src/compiler.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:test/test.dart';

import 'statement_utils.dart';

void main() {
  group('Compiler compiles single data movement statement', () {
    group('MOVE:', () {
      <String, StatementWithExpectedResult>{
        'MOVE.B #0, D1': StatementWithExpectedResult(
          type: OperationType.move,
          size: SizeValue.byte,
          operands: [immediate(0), dx(1)],
          expectedResult: CompiledStatement(
            [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0].bits,
            immediateOrSourceExtensions: [Bits.word(0x0000)],
          ),
        ),
        'MOVE.W #1, D2': StatementWithExpectedResult(
          type: OperationType.move,
          size: SizeValue.word,
          operands: [immediate(1), dx(2)],
          expectedResult: CompiledStatement(
            [0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0].bits,
            immediateOrSourceExtensions: [Bits.word(0x0001)],
          ),
        ),
        'MOVE.W D2, D3': StatementWithExpectedResult(
          type: OperationType.move,
          size: SizeValue.word,
          operands: [dx(2), dx(3)],
          expectedResult: CompiledStatement(
            [0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0].bits,
          ),
        ),
        'MOVE.L #\$10004042, D3': StatementWithExpectedResult(
          type: OperationType.move,
          size: SizeValue.longWord,
          operands: [immediate(0x10004042), dx(3)],
          expectedResult: CompiledStatement(
            [0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0].bits,
            immediateOrSourceExtensions: [
              Bits.word(0x1000),
              Bits.word(0x4042),
            ],
          ),
        ),
      }.forEach((name, stmt) {
        test(name, () => stmt.test());
      });
    });
    group('MOVEQ:', () {
      <String, StatementWithExpectedResult>{
        'MOVEQ.L #0, D0': StatementWithExpectedResult(
          type: OperationType.moveq,
          size: SizeValue.longWord,
          operands: [immediate(0), dx(0)],
          expectedResult: CompiledStatement(
            [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].bits,
          ),
        ),
        'MOVEQ.L #2, D7': StatementWithExpectedResult(
          type: OperationType.moveq,
          size: SizeValue.longWord,
          operands: [immediate(2), dx(7)],
          expectedResult: CompiledStatement(
            [0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0].bits,
          ),
        ),
        'MOVEQ.L #\$42, D3': StatementWithExpectedResult(
          type: OperationType.moveq,
          size: SizeValue.longWord,
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
