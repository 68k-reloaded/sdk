import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'compiler.dart';
import 'utils.dart';

final dataMovementCompilers = {
  OperationType.move: _compileMove,
  OperationType.moveq: _compileMoveq,
};

final _moveBits = [0, 0].bits;
CompiledStatement _compileMove(Operation statement) {
  assert(statement.type == OperationType.move);
  assert(statement.operands.length == 2);

  final source = statement.operands.first;
  final destination = statement.operands.second;

  assert(
      destination.type != OperandType.ccr, 'MOVE to CCR is not yet supported');
  assert(source.type != OperandType.sr, 'MOVE from SR is not yet supported');
  assert(destination.type != OperandType.sr, 'MOVE to SR is not yet supported');
  assert(source.type != OperandType.usp, 'MOVE from SR is not yet supported');
  assert(
      destination.type != OperandType.usp, 'MOVE to SR is not yet supported');

  assert(operandTypesAll.contains(source.type));
  assert(operandTypesNoAxPcImm.contains(destination.type));

  final sizeBits = statement.compiledSizeOneBased;
  final destRegisterBits = destination.compiledRegister;
  final destModeBits = destination.compiledMode;
  final srcModeBits = source.compiledMode;
  final srcRegisterBits = source.compiledRegister;
  return CompiledStatement(
    _moveBits +
        sizeBits +
        destRegisterBits +
        destModeBits +
        srcModeBits +
        srcRegisterBits,
    immediateOrSourceExtensions: source is ImmediateOperand
        ? source.compiledValue(statement.size.value)
        : [],
  );
}

final _moveqBits = [0, 1, 1, 1].bits;
CompiledStatement _compileMoveq(Operation statement) {
  assert(statement.type == OperationType.moveq);
  assert(statement.operands.length == 2);

  final immediate = statement.operands.first as ImmediateOperand;
  final destination = statement.operands.second as DxRegister;

  final registerBits = destination.compiledRegister;
  final dataBits = immediate.compiledByteBits;
  return CompiledStatement(_moveqBits + registerBits + [0].bits + dataBits);
}
