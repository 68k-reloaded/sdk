import 'package:data_classes/data_classes.dart';
import 'package:kt_dart/kt.dart';

import '../location.dart';

part 'operation.dart';

class Program {
  final Map<LabelStatement, int> labelsToIndex;
  final List<Statement> statements;

  Program({@required this.labelsToIndex, @required this.statements})
      : assert(labelsToIndex != null),
        assert(statements != null);
}

abstract class Statement {
  Statement({@required this.location}) : assert(location != null);

  final Location location;
}

class LabelStatement extends Statement {
  LabelStatement({@required Location location, @required this.name})
      : assert(name != null),
        super(location: location);

  final String name;

  bool get isLocal => name.startsWith('.');
  bool get isGlobal => !isLocal;

  String toString() => name;
}

class CommentStatement extends Statement {
  CommentStatement({@required Location location, @required this.comment})
      : assert(comment != null),
        super(location: location);

  final String comment;

  String toString() => 'Comment: "$comment"';
}

class OperationStatement extends Statement {
  final Operation operation;
  final SizeStatement size;
  final List<OperandStatement> operands;

  OperationStatement({
    @required Location location,
    @required this.operation,
    @required this.size,
    @required this.operands,
  })  : assert(operation != null),
        assert(size != null),
        assert(operands != null),
        super(location: location);

  String toString() => '$operation.$size $operands';
}

class SizeStatement extends Statement {
  SizeStatement({@required Location location, @required this.size})
      : assert(size != null),
        super(location: location);

  final Size size;

  String toString() => '$size';
}

abstract class RegisterStatement extends Statement {
  RegisterStatement({@required Location location}) : super(location: location);

  bool get isPc => this is PcRegisterStatement;
  bool get isAx => this is AxRegisterStatement;
  bool get isDx => this is DxRegisterStatement;
}

class PcRegisterStatement extends RegisterStatement {
  PcRegisterStatement({@required Location location})
      : super(location: location);

  String toString() => 'PC';
}

abstract class IndexedRegisterStatement extends RegisterStatement {
  IndexedRegisterStatement({@required Location location, @required this.index})
      : assert(index != null),
        assert(index >= 0),
        assert(index < 8),
        super(location: location);

  final index;

  String toString() => 'X$index';
}

class AxRegisterStatement extends IndexedRegisterStatement {
  AxRegisterStatement({@required Location location, @required int index})
      : super(location: location, index: index);

  String toString() => 'A$index';
}

class DxRegisterStatement extends IndexedRegisterStatement {
  DxRegisterStatement({@required Location location, @required int index})
      : super(location: location, index: index);

  String toString() => 'D$index';
}

class OperandStatement extends Statement {
  OperandStatement({@required Location location}) : super(location: location);

  OperandType get type {
    if (this is DxOperandStatement) {
      return OperandType.dx;
    }
    if (this is AxOperandStatement) {
      return OperandType.ax;
    }
    if (this is AxIndOperandStatement) {
      return OperandType.axInd;
    }
    if (this is AxIndWithPostIncOperandStatement) {
      return OperandType.axIndWithPostInc;
    }
    if (this is AxIndWithPreDecOperandStatement) {
      return OperandType.axIndWithPreDec;
    }
    if (this is AxIndWithDisplacementOperandStatement) {
      return OperandType.axIndWithDisplacement;
    }
    if (this is AxIndWithIndexOperandStatement) {
      return OperandType.axIndWithIndex;
    }
    if (this is AbsoluteWordOperandStatement) {
      return OperandType.absoluteWord;
    }
    if (this is AbsoluteLongWordOperandStatement) {
      return OperandType.absoluteLongWord;
    }
    if (this is PcIndWithDisplacementOperandStatement) {
      return OperandType.pcIndWithDisplacement;
    }
    if (this is PcIndWithIndexOperandStatement) {
      return OperandType.pcIndWithIndex;
    }
    if (this is ImmediateOperandStatement) {
      return OperandType.immediate;
    }
    if (this is CcrOperandStatement) {
      return OperandType.ccr;
    }
    if (this is SrOperandStatement) {
      return OperandType.sr;
    }
    if (this is AddressOperandStatement) {
      return OperandType.address;
    }
    if (this is UspOperandStatement) {
      return OperandType.usp;
    }
    assert(false, 'Unhandled type $type');
    return null;
  }
}

class DxOperandStatement extends OperandStatement {
  DxOperandStatement({@required Location location, @required this.register})
      : assert(register != null),
        super(location: location);

  final DxRegisterStatement register;
}

class AxOperandStatement extends OperandStatement {
  AxOperandStatement({@required Location location, @required this.register})
      : assert(register != null),
        super(location: location);

  final AxRegisterStatement register;
}

class AxIndOperandStatement extends OperandStatement {
  AxIndOperandStatement({@required Location location, @required this.register})
      : assert(register != null),
        super(location: location);

  final AxRegisterStatement register;
}

class AxIndWithPostIncOperandStatement extends OperandStatement {
  AxIndWithPostIncOperandStatement({
    @required Location location,
    @required this.register,
  })  : assert(register != null),
        super(location: location);

  final AxRegisterStatement register;
}

class AxIndWithPreDecOperandStatement extends OperandStatement {
  AxIndWithPreDecOperandStatement({
    @required Location location,
    @required this.register,
  })  : assert(register != null),
        super(location: location);

  final AxRegisterStatement register;
}

class AxIndWithDisplacementOperandStatement extends OperandStatement {
  AxIndWithDisplacementOperandStatement({
    @required Location location,
    @required this.register,
    @required this.displacement,
  })  : assert(register != null),
        assert(displacement != null),
        super(location: location);

  final AxRegisterStatement register;
  final int displacement;
}

class AxIndWithIndexOperandStatement extends OperandStatement {
  AxIndWithIndexOperandStatement({
    @required Location location,
    @required this.register,
    @required this.displacement,
    @required this.index,
    @required this.indexSize,
  })  : assert(register != null),
        assert(displacement != null),
        assert(index != null),
        assert(indexSize != null),
        super(location: location);

  final AxRegisterStatement register;
  final int displacement;
  final IndexedRegisterStatement index;
  final SizeStatement indexSize;
}

class AbsoluteWordOperandStatement extends OperandStatement {
  AbsoluteWordOperandStatement(
      {@required Location location, @required this.value})
      : assert(value != null),
        super(location: location);

  final int value;
}

class AbsoluteLongWordOperandStatement extends OperandStatement {
  AbsoluteLongWordOperandStatement(
      {@required Location location, @required this.value})
      : assert(value != null),
        super(location: location);

  final int value;
}

class PcIndWithDisplacementOperandStatement extends OperandStatement {
  PcIndWithDisplacementOperandStatement({
    @required Location location,
    @required this.displacement,
  })  : assert(displacement != null),
        super(location: location);

  final int displacement;
}

class PcIndWithIndexOperandStatement extends OperandStatement {
  PcIndWithIndexOperandStatement({
    @required Location location,
    @required this.displacement,
    @required this.index,
    @required this.indexSize,
  })  : assert(displacement != null),
        assert(index != null),
        assert(indexSize != null),
        super(location: location);

  final int displacement;
  final IndexedRegisterStatement index;
  final SizeStatement indexSize;
}

class ImmediateOperandStatement extends OperandStatement {
  ImmediateOperandStatement({@required Location location, @required this.value})
      : assert(value != null),
        super(location: location);

  final int value;
}

class CcrOperandStatement extends OperandStatement {
  CcrOperandStatement({@required Location location})
      : super(location: location);
}

class SrOperandStatement extends OperandStatement {
  SrOperandStatement({@required Location location}) : super(location: location);
}

class AddressOperandStatement extends OperandStatement {
  AddressOperandStatement({@required Location location})
      : super(location: location);
}

class UspOperandStatement extends OperandStatement {
  UspOperandStatement({@required Location location})
      : super(location: location);
}
