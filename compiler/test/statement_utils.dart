import 'package:m68k_reloaded_compiler/compiler.dart';
import 'package:m68k_reloaded_compiler/src/compiler.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

class StatementWithExpectedResult {
  StatementWithExpectedResult({
    @required Operation operation,
    @required Size size,
    @required List<OperandStatement> operands,
    @required this.expectedResult,
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
        assert(expectedResult != null);

  final Statement statement;
  final CompiledStatement expectedResult;

  void test() {
    expect(Compiler.compileStatement(statement), equals(expectedResult));
  }
}

DxOperandStatement dx(int index) {
  return DxOperandStatement(
    location: Location.invalid,
    register: DxRegisterStatement(
      location: Location.invalid,
      index: index,
    ),
  );
}

AxOperandStatement ax(int index) {
  return AxOperandStatement(
    location: Location.invalid,
    register: AxRegisterStatement(
      location: Location.invalid,
      index: index,
    ),
  );
}

AxIndWithPreDecOperandStatement axIndWithPreDec(int index) {
  return AxIndWithPreDecOperandStatement(
    location: Location.invalid,
    register: AxRegisterStatement(
      location: Location.invalid,
      index: index,
    ),
  );
}

ImmediateOperandStatement immediate(int value) {
  return ImmediateOperandStatement(
    location: Location.invalid,
    value: value,
  );
}
