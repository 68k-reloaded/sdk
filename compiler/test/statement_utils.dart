import 'dart:typed_data';

import 'package:m68k_reloaded_compiler/src/bits.dart';
import 'package:m68k_reloaded_parser/parser.dart';
import 'package:meta/meta.dart';

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
