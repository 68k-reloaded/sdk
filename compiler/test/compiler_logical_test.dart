import 'dart:typed_data';

import 'package:kt_dart/kt.dart';
import 'package:m68k_reloaded_compiler/compiler.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:m68k_reloaded_compiler/src/bits.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group('Compiler compiles', () {
    group('single logical statement:', () {
      group('NOT:', () {
        <String, StatementWithExpectedResult>{
          'NOT.B D0': StatementWithExpectedResult(
            operation: Operation.not,
            size: Size.byte,
            operands: [_dx(0)],
            expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          ),
          'NOT.W D0': StatementWithExpectedResult(
            operation: Operation.not,
            size: Size.word,
            operands: [_dx(0)],
            expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0],
          ),
          'NOT.L D0': StatementWithExpectedResult(
            operation: Operation.not,
            size: Size.longWord,
            operands: [_dx(0)],
            expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0],
          ),
          'NOT.W A1': StatementWithExpectedResult(
            operation: Operation.not,
            size: Size.word,
            operands: [_ax(1)],
            expectedResult: [0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
          ),
          'NOT.B -(A5)': StatementWithExpectedResult(
            operation: Operation.not,
            size: Size.byte,
            operands: [_axIndWithPreDec(5)],
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
  });
}

class StatementWithExpectedResult {
  StatementWithExpectedResult({
    @required Operation operation,
    @required Size size,
    @required List<OperandStatement> operands,
    @required List<int> expectedResult,
  })  : assert(operation != null),
        assert(size != null),
        assert(operands != null),
        assert(expectedResult != null),
        statement = OperationStatement(
          location: Location.invalid,
          operation: operation,
          size: SizeStatement(
            location: Location.invalid,
            size: size,
          ),
          operands: operands,
        ),
        this.expectedResult = expectedResult.bits.asUint8List;

  final Statement statement;
  final Uint8List expectedResult;
}

DxOperandStatement _dx(int index) {
  return DxOperandStatement(
    location: Location.invalid,
    register: DxRegisterStatement(
      location: Location.invalid,
      index: index,
    ),
  );
}

AxOperandStatement _ax(int index) {
  return AxOperandStatement(
    location: Location.invalid,
    register: AxRegisterStatement(
      location: Location.invalid,
      index: index,
    ),
  );
}

AxIndWithPreDecOperandStatement _axIndWithPreDec(int index) {
  return AxIndWithPreDecOperandStatement(
    location: Location.invalid,
    register: AxRegisterStatement(
      location: Location.invalid,
      index: index,
    ),
  );
}
