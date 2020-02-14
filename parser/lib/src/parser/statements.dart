import 'package:data_classes/data_classes.dart';

import '../location.dart';
import '../utils.dart';

part 'operation.dart';

/// A complete [Program] that contains all the information necessary to run it.
class Program {
  Program(this.statements) : assert(statements != null);

  /// All the statements of the program, including [Label]s, actual code
  /// instructions as well as comments.
  final List<Statement> statements;
}

/// A [Statement] in the [Program]. Corresponds to a [Label], actual code or a
/// comment.
abstract class Statement {
  Statement({@required this.location}) : assert(location != null);

  /// The location in the original source code that this statement corresponds
  /// to.
  final Location location;

  /// Using [toAlignedString], statements can be turned into a string that is
  /// easier to read because of uniform padding after instruction codes.
  ///
  /// For example, by calling the normal [toString] on statements, you might
  /// get the following output:
  ///
  /// ```m68k
  /// movem.l d0, -(sp)
  /// clr.l d2
  /// mov.w d1, d4
  /// ```
  ///
  /// Using [toAlignedString], the output is much easier to read:
  ///
  /// ```m68k
  /// movem.l  d0, -(sp)
  /// clr.l    d2
  /// mov.w    d1, d4
  /// ```
  String toAlignedString() => toString();
}

/// A label that points to a statement in the code.
class Label extends Statement {
  Label({@required Location location, @required this.name})
      : assert(name != null),
        super(location: location);

  final String name;

  bool get isLocal => name.startsWith('.');
  bool get isGlobal => !isLocal;

  String toString() => name;

  @override
  operator ==(Object other) =>
      other is Label && location == other.location && name == other.name;
  @override
  int get hashCode => hashList([runtimeType, location, name]);
}

/// An annotation for making it easier for so-called "humans" to read the
/// source code.
class Comment extends Statement {
  Comment({@required Location location, @required this.comment})
      : assert(comment != null),
        super(location: location);

  final String comment;

  String toString() => '* $comment';

  @override
  operator ==(Object other) =>
      other is Comment &&
      location == other.location &&
      comment == other.comment;
  @override
  int get hashCode => hashList([runtimeType, location, comment]);
}

/// An actual [Operation] that represents a command that the CPU can execute.
class Operation extends Statement {
  final OperationType type;
  final Size size;
  final List<Operand> operands;

  Operation({
    @required Location location,
    @required this.type,
    @required this.size,
    @required this.operands,
  })  : assert(type != null),
        assert(size != null),
        assert(operands != null),
        super(location: location);

  String toString() => '$type.${size.toShortString()} '
      '${operands.join(', ')}';
  String toAlignedString() =>
      '${'${type.toString()}.${size.toShortString()}'.padRight(8)} '
      '${operands.join(', ')}';

  @override
  operator ==(Object other) =>
      other is Operation &&
      location == other.location &&
      type == other.type &&
      size == other.size &&
      operands.deeplyEquals(other.operands);
  @override
  int get hashCode => hashList([runtimeType, location, type, size, operands]);
}

/// Each [Operation] can have a [Size] associated with it.
class Size extends Statement {
  Size(this.value, {@required Location location})
      : assert(value != null),
        super(location: location);

  final SizeValue value;

  String toString() => value.toReadableString();
  String toShortString() => value.toShortString();

  @override
  operator ==(Object other) =>
      other is Size && location == other.location && value == other.value;
  @override
  int get hashCode => hashList([runtimeType, location, value]);
}

/// An [Operand] given as an argument to an [Operation]. Can be something like
/// a [Register] or an [Immediate] value.
abstract class Operand extends Statement {
  Operand({@required Location location}) : super(location: location);
}

/// A reference to a [Register] that can store a value.
abstract class Register extends Statement {
  Register({@required Location location}) : super(location: location);

  bool get isPc => this is PcRegister;
  bool get isAx => this is AxRegister;
  bool get isDx => this is DxRegister;
}

/// The [Register] of the program counter.
class PcRegister extends Register {
  PcRegister({@required Location location}) : super(location: location);

  String toString() => 'PC';

  @override
  operator ==(Object other) => other is PcRegister;
  @override
  int get hashCode => hashList([runtimeType, location]);
}

/// A [Register] with an [index]. Either [AxRegister] or [DxRegister].
abstract class IndexedRegister extends Register {
  IndexedRegister({@required Location location, @required this.index})
      : assert(index != null),
        assert(index >= 0),
        assert(index < 8),
        super(location: location);

  final int index;

  String toString() => 'X$index';
}

/// An address register: Ax
/// A7 refers to the stack pointer (SP).
class AxRegister extends IndexedRegister {
  AxRegister({@required Location location, @required int index})
      : super(location: location, index: index);
  AxRegister.sp({@required Location location})
      : this(location: location, index: 7);

  bool get isSp => index == 7;

  String toString() => isSp ? 'SP' : 'A$index';

  @override
  operator ==(Object other) =>
      other is AxRegister && location == other.location && index == other.index;
  @override
  int get hashCode => hashList([runtimeType, location, index]);
}

/// A data register: Dx
class DxRegister extends IndexedRegister {
  DxRegister({@required Location location, @required int index})
      : super(location: location, index: index);

  String toString() => 'D$index';

  @override
  operator ==(Object other) =>
      other is DxRegister && location == other.location && index == other.index;
  @override
  int get hashCode => hashList([runtimeType, location, index]);
}

/// An indirect address register operand: (Ax)
class AxIndOperand extends Operand {
  AxIndOperand({@required Location location, @required this.register})
      : assert(register != null),
        super(location: location);

  final AxRegister register;

  String toString() => '($register)';

  @override
  operator ==(Object other) =>
      other is AxIndOperand &&
      location == other.location &&
      register == other.register;
  @override
  int get hashCode => hashList([runtimeType, location, register]);
}

/// An indirect address register operand with post increment: (Ax)+
class AxIndWithPostIncOperand extends Operand {
  AxIndWithPostIncOperand({
    @required Location location,
    @required this.register,
  })  : assert(register != null),
        super(location: location);

  final AxRegister register;

  String toString() => '($register)+';

  @override
  operator ==(Object other) =>
      other is AxIndWithPostIncOperand &&
      location == other.location &&
      register == other.register;
  @override
  int get hashCode => hashList([runtimeType, location, register]);
}

/// An indirect address register operand with pre decrement: -(Ax)
class AxIndWithPreDecOperand extends Operand {
  AxIndWithPreDecOperand({
    @required Location location,
    @required this.register,
  })  : assert(register != null),
        super(location: location);

  final AxRegister register;

  String toString() => '-($register)';

  @override
  operator ==(Object other) =>
      other is AxIndWithPreDecOperand &&
      location == other.location &&
      register == other.register;
  @override
  int get hashCode => hashList([runtimeType, location, register]);
}

/// An indirect register operand with displacement: (d, Ax) or (d, PC)
class IndWithDisplacementOperand extends Operand {
  IndWithDisplacementOperand({
    @required Location location,
    @required this.register,
    @required this.displacement,
  })  : assert(register != null),
        assert(displacement != null),
        super(location: location);

  final Register register;
  final int displacement;

  String toString() => '($displacement, $register)';

  @override
  operator ==(Object other) =>
      other is IndWithDisplacementOperand &&
      location == other.location &&
      register == other.register;
  @override
  int get hashCode => hashList([runtimeType, location, register]);
}

/// An indirect register operand with an index: (d, An, Xn) or (d, PC, Xn)
class IndWithIndexOperand extends Operand {
  IndWithIndexOperand({
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

  final Register register;
  final int displacement;
  final IndexedRegister index;
  final Size indexSize;

  String toString() => '($displacement, $register, $index$indexSize)';

  @override
  operator ==(Object other) =>
      other is IndWithIndexOperand &&
      location == other.location &&
      register == other.register;
  @override
  int get hashCode => hashList([runtimeType, location, register]);
}

/// An absolute word operand: (xxx).W
class AbsoluteWordOperand extends Operand {
  AbsoluteWordOperand({@required Location location, @required this.value})
      : assert(value != null),
        super(location: location);

  final int value;

  String toString() => '($value).W';

  @override
  operator ==(Object other) =>
      other is AbsoluteWordOperand &&
      location == other.location &&
      value == other.value;
  @override
  int get hashCode => hashList([runtimeType, location, value]);
}

/// An absolute long word: (xxx).L
class AbsoluteLongWordOperand extends Operand {
  AbsoluteLongWordOperand({
    @required Location location,
    @required this.value,
  })  : assert(value != null),
        super(location: location);

  final int value;

  String toString() => '($value).L';

  @override
  operator ==(Object other) =>
      other is AbsoluteLongWordOperand &&
      location == other.location &&
      value == other.value;
  @override
  int get hashCode => hashList([runtimeType, location, value]);
}

/// An immediate operand: #xxx
class ImmediateOperand extends Operand {
  ImmediateOperand({
    @required Location location,
    @required this.value,
  })  : assert(value != null),
        super(location: location);

  final int value;

  String toString() => '#$value';

  @override
  operator ==(Object other) =>
      other is ImmediateOperand &&
      location == other.location &&
      value == other.value;
  @override
  int get hashCode => hashList([runtimeType, location, value]);
}

/// A CCR operand.
class CcrOperand extends Operand {
  CcrOperand({@required Location location}) : super(location: location);

  String toString() => 'CCR';

  @override
  operator ==(Object other) =>
      other is CcrOperand && location == other.location;
  @override
  int get hashCode => hashList([runtimeType, location]);
}

/// An SR operand.
class SrOperand extends Operand {
  SrOperand({@required Location location}) : super(location: location);

  String toString() => 'SR';

  @override
  operator ==(Object other) => other is SrOperand && location == other.location;
  @override
  int get hashCode => hashList([runtimeType, location]);
}

class AddressOperand extends Operand {
  AddressOperand({@required Location location}) : super(location: location);

  String toString() => '[address operand]';

  @override
  operator ==(Object other) =>
      other is AddressOperand && location == other.location;
  @override
  int get hashCode => hashList([runtimeType, location]);
}

class UspOperand extends Operand {
  UspOperand({@required Location location}) : super(location: location);

  String toString() => 'USP';

  @override
  operator ==(Object other) =>
      other is UspOperand && location == other.location;
  @override
  int get hashCode => hashList([runtimeType, location]);
}
