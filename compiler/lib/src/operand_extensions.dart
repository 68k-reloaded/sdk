import 'package:m68k_reloaded_parser/parser.dart';

import 'bits.dart';

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

extension SizeBits on Size {
  Bits get compiledZeroBased => {
        Size.byte: [0, 0].bits,
        Size.word: [0, 1].bits,
        Size.longWord: [1, 0].bits,
      }[this];
  Bits get compiledOneBased => {
        Size.byte: [0, 1].bits,
        Size.word: [1, 0].bits,
        Size.longWord: [1, 1].bits,
      }[this];
  Bits get compiledSingleBit {
    assert(this != Size.byte);
    return {
      Size.word: [0].bits,
      Size.longWord: [1].bits,
    }[this];
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
