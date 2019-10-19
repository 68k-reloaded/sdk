import 'package:data_classes/data_classes.dart';

class Program {
  final Map<Label, int> labelsToIndex;
  final List<Statement> statements;

  Program({@required this.labelsToIndex, @required this.statements})
      : assert(labelsToIndex != null),
        assert(statements != null);
}

class Label {
  Label(this.name);

  final String name;

  bool get isLocal => name.startsWith('.');
  bool get isGlobal => !isLocal;

  String toString() => name;
}

abstract class Statement {
  int get line;
}

class CommentStatement implements Statement {
  CommentStatement({@required this.line, @required this.comment})
      : assert(line != null),
        assert(comment != null);

  final int line;
  final String comment;

  String toString() => 'Comment: "$comment"';
}

enum Size { byte, word, longWord }

const _sizesB = {Size.byte};
const _sizesBWL = {Size.byte, Size.word, Size.longWord};

enum OperandType {
  dx,
  ax,
  axInd,
  axIndWithPostInc,
  axIndWithPreDec,
  axIndWithDisplacement,
  axIndWithIndex,
  absoluteWord,
  absoluteLongWord,
  pcIndWithDisplacement,
  pcIndWithIndex,
  immediate,
}

class Operation {
  final String code;
  final Set<Size> sizes;
  final List<Set<OperandType>> operandTypes;

  const Operation({
    @required this.code,
    @required this.sizes,
    @required this.operandTypes,
  })  : assert(code != null),
        assert(sizes != null),
        assert(operandTypes != null);
}

const operations = {
  Operation(
    code: 'ADD',
    sizes: _sizesBWL,
    operandTypes: [
      {
        OperandType.dx,
        OperandType.ax,
        OperandType.axInd,
        OperandType.axIndWithPostInc,
        OperandType.axIndWithPreDec,
        OperandType.axIndWithDisplacement,
        OperandType.axIndWithIndex,
        OperandType.absoluteWord,
        OperandType.absoluteLongWord,
        OperandType.pcIndWithDisplacement,
        OperandType.pcIndWithIndex,
        OperandType.immediate,
      },
      {OperandType.dx}
    ],
  ),
};

class OperationStatement implements Statement {
  final int line;
  final Operation operation;
  final SizeStatement size;
  final List<OperandStatement> operands;

  OperationStatement({
    @required this.line,
    @required this.operation,
    @required this.size,
    @required this.operands,
  })  : assert(line != null),
        assert(operation != null),
        assert(size != null),
        assert(operands != null);
}

class SizeStatement implements Statement {
  SizeStatement({@required this.line, @required this.size})
      : assert(line != null),
        assert(size != null);

  final int line;
  final Size size;
}

class OperandStatement implements Statement {
  OperandStatement({
    @required this.line,
    @required this.type,
    @required this.operand,
  })  : assert(line != null),
        assert(type != null),
        assert(operand != null);

  final int line;
  final OperandType type;
  final String operand;
}
