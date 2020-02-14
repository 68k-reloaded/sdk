import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'operand_extensions.dart';

extension OperationStatementBits on OperationStatement {
  Bits get compiledSizeZeroBased => size.size.compiledZeroBased;
  Bits get compiledSizeOneBased => size.size.compiledOneBased;
  Bits get compiledSizeSingleBit => size.size.compiledSingleBit;
}

extension OperandStatementBits on OperandStatement {
  Bits get compiledMode => type.compiledMode;

  Bits get compiledRegister {
    if (type == OperandType.dx)
      return (this as DxOperandStatement).register.compiledBits;
    if (type == OperandType.ax)
      return (this as AxOperandStatement).register.compiledBits;
    if (type == OperandType.axInd)
      return (this as AxIndOperandStatement).register.compiledBits;
    if (type == OperandType.axIndWithPostInc)
      return (this as AxIndWithPostIncOperandStatement).register.compiledBits;
    if (type == OperandType.axIndWithPreDec)
      return (this as AxIndWithPreDecOperandStatement).register.compiledBits;
    if (type == OperandType.axIndWithDisplacement)
      return (this as AxIndWithDisplacementOperandStatement)
          .register
          .compiledBits;
    if (type == OperandType.axIndWithIndex)
      return (this as AxIndWithIndexOperandStatement).register.compiledBits;
    if (this is AbsoluteWordOperandStatement) return [0, 0, 0].bits;
    if (this is AbsoluteLongWordOperandStatement) return [0, 0, 1].bits;
    if (this is PcIndWithDisplacementOperandStatement) return [0, 1, 0].bits;
    if (this is PcIndWithIndexOperandStatement) return [0, 1, 1].bits;
    if (this is ImmediateOperandStatement) return [1, 0, 0].bits;
    // if (this is CcrOperandStatement) return ;
    // if (this is SrOperandStatement) return ;
    // if (this is AddressOperandStatement) return ;
    // if (this is UspOperandStatement) return ;
    assert(false, 'Unhandled statement type: $type');
    return null;
  }
}

extension ImmediateOperandStatementBits on ImmediateOperandStatement {
  Bits get compiledByteBits => Bits.byte(value);
}

extension RegisterStatementBits on RegisterStatement {
  Bits get compiledBits {
    assert(this is IndexedRegisterStatement, 'TODO: PcRegisterStatement');

    return Bits.fromInt(3, (this as IndexedRegisterStatement).index);
  }
}
