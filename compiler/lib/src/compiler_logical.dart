import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'compiler.dart';
import 'utils.dart';

final logicalCompilers = {
  OperationType.not: _compileNot,
};

final _notBits = [0, 1, 0, 0, 0, 1, 1, 0].bits;
CompiledStatement _compileNot(Operation operation) {
  assert(operation.type == OperationType.not);
  assert(operation.operands.length == 1);
  final operand = operation.operands.first;

  final sizeBits = operation.compiledSizeZeroBased;
  final addressModeBits = operand.compiledMode;
  final addressRegisterBits = operand.compiledRegister;

  return CompiledStatement(
      _notBits + sizeBits + addressModeBits + addressRegisterBits);
}
