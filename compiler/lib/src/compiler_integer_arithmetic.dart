import 'package:m68k_reloaded_compiler/src/utils.dart';
import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'compiler.dart';
import 'statement_extensions.dart';
import 'operand_extensions.dart';

final integerArithmeticCompilers = {
  OperationType.add: _compileAdd,
  OperationType.cmpi: _compileCmpi,
};

final _addBits = [1, 1, 0, 1].bits;
CompiledStatement _compileAdd(Operation statement) {
  assert(statement.type == OperationType.add);
  assert(statement.operands.length == 2);

  final source = statement.operands.first;
  final destination = statement.operands.second;

  final isDirectionEaDnDn = destination.type == OperandType.dx;
  final isDirectionDnEaEa = source.type == OperandType.dx &&
      operandTypesAxIndAbs.contains(destination.type);
  assert(isDirectionEaDnDn || isDirectionDnEaEa);
  assert(!(isDirectionEaDnDn && isDirectionDnEaEa));

  final direction =
      isDirectionEaDnDn ? DirectionDnEa.eaDnDn : DirectionDnEa.dnEaEa;

  final dx =
      (direction == DirectionDnEa.eaDnDn ? destination : source) as DxRegister;
  final xx = direction == DirectionDnEa.eaDnDn ? source : destination;

  final dxBits = dx.compiledBits;
  final directionBits = direction.compiled;
  final sizeBits = statement.compiledSizeZeroBased;
  final xxModeBits = xx.compiledMode;
  final xxRegisterBits = xx.compiledRegister;
  return CompiledStatement(
    _addBits + dxBits + directionBits + sizeBits + xxModeBits + xxRegisterBits,
    immediateOrSourceExtensions:
        xx is ImmediateOperand ? xx.compiledValue(statement.size.value) : null,
  );
}

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
