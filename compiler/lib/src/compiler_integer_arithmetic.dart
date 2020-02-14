import 'package:m68k_reloaded_compiler/src/utils.dart';
import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'compiler.dart';
import 'statement_extensions.dart';
import 'operand_extensions.dart';

final integerArithmeticCompilers = {
  OperationType.cmpi: _compileCmpi,
};

final _cmpiBits = [0, 0, 0, 0, 1, 1, 0, 0].bits;
CompiledStatement _compileCmpi(Operation statement) {
  assert(statement.type == OperationType.cmpi);
  assert(statement.operands.length == 2);

  final data = statement.operands.first;
  assert(data.type == OperandType.immediate);

  final destination = statement.operands.second;
  assert(operandTypesNoAxPcImm.contains(destination.type));

  final sizeBits = statement.compiledSizeZeroBased;
  final destModeBits = destination.compiledMode;
  final destRegisterBits = destination.compiledRegister;
  return CompiledStatement(
    _cmpiBits + sizeBits + destModeBits + destRegisterBits,
    immediateOrSourceExtensions:
        (data as ImmediateOperand).compiledValue(statement.size.value),
  );
}
