import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';
import 'operand_extensions.dart';

extension OperationBits on Operation {
  Bits get compiledSizeZeroBased => size.value.compiledZeroBased;
  Bits get compiledSizeOneBased => size.value.compiledOneBased;
  Bits get compiledSizeSingleBit => size.value.compiledSingleBit;
}

extension OperandBits on Operand {
  Bits get compiledMode => type.compiledMode;

  Bits get compiledRegister {
    if (type == OperandType.dx) return (this as DxRegister).compiledBits;
    if (type == OperandType.ax) return (this as AxRegister).compiledBits;

    if (type == OperandType.axInd)
      return (this as AxIndOperand).register.compiledBits;
    if (type == OperandType.axIndWithPostInc)
      return (this as AxIndWithPostIncOperand).register.compiledBits;
    if (type == OperandType.axIndWithPreDec)
      return (this as AxIndWithPreDecOperand).register.compiledBits;
    if (type == OperandType.axIndWithDisplacement)
      return (this as IndWithDisplacementOperand).register.compiledBits;
    if (type == OperandType.axIndWithIndex)
      return (this as IndWithIndexOperand).register.compiledBits;

    if (type == OperandType.absoluteWord) return [0, 0, 0].bits;
    if (type == OperandType.absoluteLongWord) return [0, 0, 1].bits;

    if (type == OperandType.pcIndWithDisplacement) return [0, 1, 0].bits;
    if (type == OperandType.pcIndWithIndex) return [0, 1, 1].bits;

    if (type == OperandType.immediate) return [1, 0, 0].bits;
    // if (this is CcrOperand) return ;
    // if (this is SrOperand) return ;
    // if (this is AddressOperand) return ;
    // if (this is UspOperand) return ;
    assert(false, 'Unhandled statement type: $type');
    return null;
  }
}

extension ImmediateOperandBits on ImmediateOperand {
  Bits get compiledByteBits => Bits.byte(value);
}

extension RegisterBits on Register {
  Bits get compiledBits {
    assert(this is IndexedRegister, 'TODO: PcRegister');

    return Bits.fromInt(3, (this as IndexedRegister).index);
  }
}
