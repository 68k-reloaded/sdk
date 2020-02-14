import 'dart:typed_data';

import 'package:kt_dart/kt.dart';
import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'compiler.dart';
import 'statement_extensions.dart';

final KtMap<Operation, StatementCompiler> dataMovementCompilers = KtMap.from({
  Operation.moveq: _compileMoveq,
});

final _moveqBits = [0, 1, 1, 1].bits;
Uint8List _compileMoveq(OperationStatement statement) {
  assert(statement.operation == Operation.moveq);
  assert(statement.operands.length == 2);

  final immediate = statement.operands.first;
  assert(immediate is ImmediateOperandStatement);

  final register = statement.operands[1];
  assert(register is DxOperandStatement);

  final registerBits = register.compiledRegister;
  final dataBits = (immediate as ImmediateOperandStatement).compiledByteBits;

  final bits = _moveqBits + registerBits + [0].bits + dataBits;
  bits.assertWordLength();
  return bits.asUint8List;
}
