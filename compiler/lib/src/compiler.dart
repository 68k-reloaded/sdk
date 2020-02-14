import 'dart:typed_data';

import 'package:data_classes/data_classes.dart';
import 'package:m68k_reloaded_compiler/src/compiler_logical.dart';
import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'compiler_data_movement.dart';

class Compiler {
  static final _operationCompilers = {
    ...dataMovementCompilers,
    ...logicalCompilers,
  };

  Compiler._();

  static Uint16List compile(Program program) {
    assert(program != null);

    final statementCode = program.statements.map((s) {
      if (s is Operation) {
        return compileOperation(s);
      }

      assert(false, 'Unsupported statement: $s');
      return null;
    }).expand((b) => b.asUint16List);
    return Uint16List.fromList(statementCode);
  }

  static CompiledStatement compileOperation(Operation operation) {
    return _operationCompilers[operation.type](operation);
  }
}

class CompiledStatement {
  CompiledStatement(
    this.operationWord, {
    this.operandSpecifiers = const [],
    this.immediateOrSourceExtensions = const [],
    this.destinationExtensions = const [],
  })  : assert(operationWord != null),
        assert(operationWord.hasWordLength),
        assert(operandSpecifiers != null),
        assert(operandSpecifiers.length <= 2),
        assert(operandSpecifiers.every((s) => s.hasWordLength)),
        assert(immediateOrSourceExtensions != null),
        assert(immediateOrSourceExtensions.length <= 6),
        assert(immediateOrSourceExtensions.every((s) => s.hasWordLength)),
        assert(destinationExtensions != null),
        assert(destinationExtensions.length <= 6),
        assert(destinationExtensions.every((s) => s.hasWordLength));

  final Bits operationWord;
  final List<Bits> operandSpecifiers;
  final List<Bits> immediateOrSourceExtensions;
  final List<Bits> destinationExtensions;

  Uint16List get asUint16List {
    final length = 1 +
        operandSpecifiers.length +
        immediateOrSourceExtensions.length +
        destinationExtensions.length;
    final result = Uint16List(length);

    var i = 0;
    result[i++] = operationWord.combined;
    for (final opSpec in operandSpecifiers) result[i++] = opSpec.combined;
    for (final immSrcExt in immediateOrSourceExtensions)
      result[i++] = immSrcExt.combined;
    for (final destExt in destinationExtensions) result[i++] = destExt.combined;

    return result;
  }

  @override
  String toString() => '0x${operationWord.toHexString()}'
      ' ${_bitsListToHexString(operandSpecifiers)}'
      ' ${_bitsListToHexString(immediateOrSourceExtensions)}'
      ' ${_bitsListToHexString(destinationExtensions)}';
  String _bitsListToHexString(List<Bits> bitsList) =>
      bitsList.isEmpty ? '-' : bitsList.map((b) => b.toHexString()).join();

  bool operator ==(Object other) =>
      other is CompiledStatement &&
      operationWord == other.operationWord &&
      operandSpecifiers == other.operandSpecifiers &&
      immediateOrSourceExtensions == other.immediateOrSourceExtensions &&
      destinationExtensions == other.destinationExtensions;
  int get hashCode => hashList([
        operationWord,
        operandSpecifiers,
        immediateOrSourceExtensions,
        destinationExtensions,
      ]);
}

typedef StatementCompiler = CompiledStatement Function(Operation operation);
