import 'package:m68k_reloaded_compiler/src/utils.dart';
import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'compiler.dart';
import 'statement_extensions.dart';

final dataMovementCompilers = {
  OperationType.move: _compileMove,
  OperationType.moveq: _compileMoveq,
};

final _moveqBits = [0, 1, 1, 1].bits;
CompiledStatement _compileMoveq(Operation statement) {
  assert(statement.type == OperationType.moveq);
  assert(statement.operands.length == 2);

  final immediate = statement.operands.first;
  assert(immediate is ImmediateOperand);

  final destination = statement.operands[1];
  assert(destination is DxRegister);

  final registerBits = destination.compiledRegister;
  final dataBits = (immediate as ImmediateOperand).compiledByteBits;

  return CompiledStatement(_moveqBits + registerBits + [0].bits + dataBits);
}
