import 'dart:typed_data';

import 'package:kt_dart/kt.dart';
import 'package:m68k_reloaded_compiler/src/compiler_logical.dart';
import 'package:m68k_reloaded_parser/parser.dart';

class Compiler {
  static final _operationCompilers = logicalCompilers;

  Compiler._();

  static Uint8List compile(Program program) {
    assert(program != null);

    final statementCode = program.statements.map((s) {
      if (s is OperationStatement) {
        return _operationCompilers[s.operation](s);
      }

      assert(false, 'Unsupported statement: $s');
      return null;
    }).flatMap((b) => b.toList(growable: false).kt);
    return Uint8List.fromList(statementCode.asList());
  }
}

typedef StatementCompiler = Uint8List Function(OperationStatement);
