import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';

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

extension OperandTypeBits on OperandType {
  Bits get compiledMode => {
        OperandType.dx: [0, 0, 0],
        OperandType.ax: [0, 0, 1],
        OperandType.axInd: [0, 1, 0],
        OperandType.axIndWithPostInc: [0, 1, 1],
        OperandType.axIndWithPreDec: [1, 0, 0],
        OperandType.axIndWithDisplacement: [1, 0, 1],
        OperandType.axIndWithIndex: [1, 1, 0],
        OperandType.absoluteWord: [1, 1, 1],
        OperandType.absoluteLongWord: [1, 1, 1],
        OperandType.pcIndWithDisplacement: [1, 1, 1],
        OperandType.pcIndWithIndex: [1, 1, 1],
        OperandType.immediate: [1, 1, 1],
        // OperandType.ccr: [],
        // OperandType.sr: [],
        // OperandType.address: [],
        // OperandType.usp: [],
      }[this]
          .bits;
}

extension RegisterBits on Register {
  Bits get compiledBits {
    assert(this is IndexedRegister, 'TODO: PcRegister');

    return Bits.fromInt(3, (this as IndexedRegister).index);
  }
}

extension ImmediateOperandBits on ImmediateOperand {
  Bits get compiledByteBits => Bits.byte(value);
  List<Bits> compiledValue(SizeValue size) {
    if (size == SizeValue.byte) return [Bits.byte(0) + Bits.byte(value)];
    if (size == SizeValue.word) return [Bits.word(value)];
    if (size == SizeValue.longWord) {
      return [
        Bits.word(value >> Bits.wordLength),
        Bits.word(value & ((1 << Bits.wordLength) - 1)),
      ];
    }

    assert(false, 'Unknown size: $size');
    return null;
  }

  static const quickMin = 1;
  static const quickMax = 8;
  static const quickBits = 3;
  Bits get compiledQuick {
    assert(quickMin <= value);
    assert(value <= quickMax);

    return Bits.fromInt(quickBits, value == quickMax ? 0 : value);
  }
}

extension SizeValueBits on SizeValue {
  Bits get compiledZeroBased => {
        SizeValue.byte: [0, 0].bits,
        SizeValue.word: [0, 1].bits,
        SizeValue.longWord: [1, 0].bits,
      }[this];
  Bits get compiledOneBased => {
        SizeValue.byte: [0, 1].bits,
        SizeValue.word: [1, 0].bits,
        SizeValue.longWord: [1, 1].bits,
      }[this];
  Bits get compiledSingleBit {
    assert(this != SizeValue.byte);
    return {
      SizeValue.word: [0].bits,
      SizeValue.longWord: [1].bits,
    }[this];
  }
}

enum DirectionDnEa {
  eaDnDn,
  dnEaEa,
}

extension DirectionDnEaBits on DirectionDnEa {
  Bits get compiled => {
        DirectionDnEa.eaDnDn: Bits.zero,
        DirectionDnEa.dnEaEa: Bits.one,
      }[this];
}

const operandTypesAll = {
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
};
const operandTypesNoAx = {
  OperandType.dx,
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
};
const operandTypesNoAxImm = {
  OperandType.dx,
  OperandType.axInd,
  OperandType.axIndWithPostInc,
  OperandType.axIndWithPreDec,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
  OperandType.pcIndWithDisplacement,
  OperandType.pcIndWithIndex,
};
const operandTypesNoAxPcImm = {
  OperandType.dx,
  OperandType.axInd,
  OperandType.axIndWithPostInc,
  OperandType.axIndWithPreDec,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
};
const operandTypesNoPcImm = {
  OperandType.dx,
  OperandType.ax,
  OperandType.axInd,
  OperandType.axIndWithPostInc,
  OperandType.axIndWithPreDec,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
};
const operandTypesDxImm = {
  OperandType.dx,
  OperandType.immediate,
};
const operandTypesRx = {
  OperandType.dx,
  OperandType.ax,
};
const operandTypesAxIndAbs = {
  OperandType.axInd,
  OperandType.axIndWithPostInc,
  OperandType.axIndWithPreDec,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
};
const operandTypesAxAbsPcNoAxPrePost = {
  OperandType.ax,
  OperandType.axInd,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
  OperandType.pcIndWithDisplacement,
  OperandType.pcIndWithIndex,
};
const operandTypesAxIndAbsPcNoAxPrePost = {
  OperandType.axInd,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
  OperandType.pcIndWithDisplacement,
  OperandType.pcIndWithIndex,
};
