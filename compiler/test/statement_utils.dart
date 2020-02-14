import 'package:m68k_reloaded_compiler/compiler.dart';
import 'package:m68k_reloaded_compiler/src/compiler.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

class StatementWithExpectedResult {
  StatementWithExpectedResult({
    @required OperationType type,
    @required SizeValue size,
    @required List<Operand> operands,
    @required this.expectedResult,
  })  : assert(type != null),
        assert(size != null),
        assert(operands != null),
        assert(expectedResult != null),
        statement = Operation(
          location: Location.invalid,
          type: type,
          size: Size(
            size,
            location: Location.invalid,
          ),
          operands: operands,
        ),
        assert(expectedResult != null);

  final Statement statement;
  final CompiledStatement expectedResult;

  void test() {
    expect(Compiler.compileOperation(statement), equals(expectedResult));
  }
}

DxRegister dx(int index) {
  return DxRegister(
    location: Location.invalid,
    index: index,
  );
}

AxRegister ax(int index) {
  return AxRegister(
    location: Location.invalid,
    index: index,
  );
}

AxIndOperand axInd(int index) {
  return AxIndOperand(
    location: Location.invalid,
    register: AxRegister(
      location: Location.invalid,
      index: index,
    ),
  );
}

AxIndWithPostIncOperand axIndWithPostInc(int index) {
  return AxIndWithPostIncOperand(
    location: Location.invalid,
    register: AxRegister(
      location: Location.invalid,
      index: index,
    ),
  );
}

AxIndWithPreDecOperand axIndWithPreDec(int index) {
  return AxIndWithPreDecOperand(
    location: Location.invalid,
    register: AxRegister(
      location: Location.invalid,
      index: index,
    ),
  );
}

ImmediateOperand immediate(int value) {
  return ImmediateOperand(
    location: Location.invalid,
    value: value,
  );
}
