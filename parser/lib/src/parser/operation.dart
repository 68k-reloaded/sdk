part of 'statements.dart';

enum Size { byte, word, longWord }

String sizeToString(Size size) {
  assert(size != null);
  return {
    Size.byte: 'byte',
    Size.word: 'word',
    Size.longWord: 'long word',
  }[size];
}

const _sizesB = {Size.byte};
const _sizesBW = {Size.byte, Size.word};
const _sizesBL = {Size.byte, Size.longWord};
const _sizesW = {Size.word};
const _sizesWL = {Size.word, Size.longWord};
const _sizesL = {Size.longWord};
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
  ccr,
  sr,
  address,
  usp,
}

String operandTypeToString(OperandType type) {
  assert(type != null);
  return {
    OperandType.dx: 'data register mode',
    OperandType.ax: 'address register mode',
    OperandType.axInd: 'address register indirect mode',
    OperandType.axIndWithPostInc:
        'address register indirect with postincrement mode',
    OperandType.axIndWithPreDec:
        'address register indirect with predecrement mode',
    OperandType.axIndWithDisplacement:
        'address register indirect with displacement mode',
    OperandType.axIndWithIndex: 'address register indirect with index mode',
    OperandType.absoluteWord: 'absolute word addressing mode',
    OperandType.absoluteLongWord: 'absolute long word addressing mode',
    OperandType.pcIndWithDisplacement:
        'program counter indirect with displacement mode',
    OperandType.pcIndWithIndex: 'program counter indirect with index mode',
    OperandType.immediate: 'immediate data mode',
    OperandType.ccr: 'condition code register mode',
    OperandType.sr: 'status register mode',
    OperandType.address: 'address mode',
    OperandType.usp: 'user stack pointer mode',
  }[type];
}

String operandTypeToStringShort(OperandType type) {
  assert(type != null);
  return {
    OperandType.dx: 'Dn',
    OperandType.ax: 'An',
    OperandType.axInd: '(An)',
    OperandType.axIndWithPostInc: '(An)+',
    OperandType.axIndWithPreDec: '-(An)',
    OperandType.axIndWithDisplacement: '(d, An)',
    OperandType.axIndWithIndex: '(d, An, Xn.s)',
    OperandType.absoluteWord: '(xxx).W',
    OperandType.absoluteLongWord: '(xxx).L',
    OperandType.pcIndWithDisplacement: '(d, PC)',
    OperandType.pcIndWithIndex: '(d, PC, Xn.s)',
    OperandType.immediate: '#xxx',
    OperandType.ccr: 'CCR',
    OperandType.sr: 'SR',
    OperandType.address: 'address',
    OperandType.usp: 'USP',
  }[type];
}

// All means without CCR and SR
const _typesAll = {
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
const _typesNoAx = {
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
const _typesNoAxImm = {
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
const _typesNoAxPcImm = {
  OperandType.dx,
  OperandType.axInd,
  OperandType.axIndWithPostInc,
  OperandType.axIndWithPreDec,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
};
const _typesNoPcImm = {
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
const _typesDxImm = {
  OperandType.dx,
  OperandType.immediate,
};
const _typesRx = {
  OperandType.dx,
  OperandType.ax,
};
const _typesAxIndAbs = {
  OperandType.axInd,
  OperandType.axIndWithPostInc,
  OperandType.axIndWithPreDec,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
};
const _typesAxAbsPcNoAxPrePost = {
  OperandType.ax,
  OperandType.axInd,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
  OperandType.pcIndWithDisplacement,
  OperandType.pcIndWithIndex,
};
const _typesAxIndAbsPcNoAxPrePost = {
  OperandType.axInd,
  OperandType.axIndWithDisplacement,
  OperandType.axIndWithIndex,
  OperandType.absoluteWord,
  OperandType.absoluteLongWord,
  OperandType.pcIndWithDisplacement,
  OperandType.pcIndWithIndex,
};

class Operation {
  final String code;
  final Set<OperationConfiguration> configurations;

  const Operation({
    this.code,
    this.configurations,
  })  : assert(code != null),
        assert(configurations != null);

  static const conditionCodes = [
    'T',
    'F',
    'HI',
    'LS',
    'HS',
    'CC',
    'LO',
    'CS',
    'NE',
    'EQ',
    'VC',
    'VS',
    'PL',
    'MI',
    'GE',
    'GE',
    'LT',
    'GT',
    'LE',
  ];

  static Operation abcd = Operation(
    code: 'ABCD',
    configurations: {
      OperationConfiguration(
        sizes: _sizesB,
        operandTypes: [
          {OperandType.dx},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesB,
        operandTypes: [
          {OperandType.axIndWithPreDec},
          {OperandType.axIndWithPreDec},
        ],
      ),
    },
  );
  static Operation add = Operation(
    code: 'ADD',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          _typesAll,
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.dx},
          _typesNoPcImm,
        ],
      ),
    },
  );
  static Operation adda = Operation(
    code: 'ADDA',
    configurations: {
      OperationConfiguration(
        sizes: _sizesWL,
        operandTypes: [
          _typesAll,
          {OperandType.ax},
        ],
      ),
    },
  );
  static Operation addi = Operation(
    code: 'ADDI',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          _typesNoAxPcImm,
        ],
      ),
    },
  );
  static Operation addq = Operation(
    code: 'ADDQ',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          _typesNoPcImm,
        ],
      ),
    },
  );
  static Operation addx = Operation(
    code: 'ADDX',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.dx},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.axIndWithPreDec},
          {OperandType.axIndWithPreDec},
        ],
      ),
    },
  );
  static Operation and = Operation(
    code: 'AND',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          _typesNoAx,
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.dx},
          _typesNoAxPcImm,
        ],
      ),
    },
  );
  static Operation andi = Operation(
    code: 'ANDI',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          _typesNoAxPcImm,
        ],
      ),
      OperationConfiguration(
        sizes: _sizesB,
        operandTypes: [
          {OperandType.immediate},
          {OperandType.ccr},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          {OperandType.immediate},
          {OperandType.sr},
        ],
      ),
    },
  );
  static Operation asl = Operation(
    code: 'ASL',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.dx},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesAxIndAbs,
        ],
      ),
    },
  );
  static Operation asr = Operation(
    code: 'ASR',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.dx},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesAxIndAbs,
        ],
      ),
    },
  );
  static List<Operation> bcc = conditionCodes.map((cc) => Operation(
        code: 'B$cc',
        configurations: {
          OperationConfiguration(
            sizes: _sizesBW,
            operandTypes: [
              {OperandType.address},
            ],
          ),
        },
      ));
  static Operation bchg = Operation(
    code: 'BCHG',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBL,
        operandTypes: [
          {OperandType.dx},
          _typesNoAxPcImm,
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBL,
        operandTypes: [
          {OperandType.immediate},
          _typesNoAxPcImm,
        ],
      ),
    },
  );
  static Operation bclr = Operation(
    code: 'BCLR',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBL,
        operandTypes: [
          {OperandType.dx},
          _typesNoAxPcImm,
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBL,
        operandTypes: [
          {OperandType.immediate},
          _typesNoAxPcImm,
        ],
      ),
    },
  );
  static Operation bra = Operation(
    code: 'BRA',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBW,
        operandTypes: [
          {OperandType.address},
        ],
      ),
    },
  );
  static Operation bset = Operation(
    code: 'BSET',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBL,
        operandTypes: [
          {OperandType.dx},
          _typesNoAxPcImm,
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBL,
        operandTypes: [
          {OperandType.immediate},
          _typesNoAxPcImm,
        ],
      ),
    },
  );
  static Operation bsr = Operation(
    code: 'BSR',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBW,
        operandTypes: [
          {OperandType.address},
        ],
      ),
    },
  );
  static Operation btst = Operation(
    code: 'BTST',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBL,
        operandTypes: [
          {OperandType.dx},
          _typesNoAxImm,
        ],
      ),
    },
  );
  static Operation chk = Operation(
    code: 'CHK',
    configurations: {
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesNoAx,
          {OperandType.dx},
        ],
      ),
    },
  );
  static Operation clr = Operation(
    code: 'CLR',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          _typesNoAxPcImm,
        ],
      ),
    },
  );
  static Operation cmp = Operation(
    code: 'CMP',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          _typesAll,
          {OperandType.dx},
        ],
      ),
    },
  );
  static Operation cmpa = Operation(
    code: 'CMPA',
    configurations: {
      OperationConfiguration(
        sizes: _sizesWL,
        operandTypes: [
          _typesAll,
          {OperandType.ax},
        ],
      ),
    },
  );
  static Operation cmpi = Operation(
    code: 'CMPI',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          _typesNoAxPcImm,
        ],
      ),
    },
  );
  static Operation cmpm = Operation(
    code: 'CMPM',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.axIndWithPostInc},
          {OperandType.axIndWithPostInc},
        ],
      ),
    },
  );
  static List<Operation> dbcc = conditionCodes.map((cc) => Operation(
        code: 'DB$cc',
        configurations: {
          OperationConfiguration(
            sizes: _sizesW,
            operandTypes: [
              {OperandType.dx},
              {OperandType.address},
            ],
          ),
        },
      ));
  static Operation divs = Operation(
    code: 'DIVS',
    configurations: {
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesNoAx,
          {OperandType.dx},
        ],
      ),
    },
  );
  static Operation divu = Operation(
    code: 'DIVU',
    configurations: {
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesNoAx,
          {OperandType.dx},
        ],
      ),
    },
  );
  static Operation eor = Operation(
    code: 'EOR',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          _typesDxImm,
          _typesNoAxPcImm,
        ],
      ),
    },
  );
  static Operation eori = Operation(
    code: 'EORI',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          _typesNoAxPcImm,
        ],
      ),
      OperationConfiguration(
        sizes: _sizesB,
        operandTypes: [
          {OperandType.immediate},
          {OperandType.ccr},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          {OperandType.immediate},
          {OperandType.sr},
        ],
      ),
    },
  );
  static Operation exg = Operation(
    code: 'EXG',
    configurations: {
      OperationConfiguration(
        sizes: _sizesL,
        operandTypes: [
          _typesRx,
          _typesRx,
        ],
      ),
    },
  );
  static Operation ext = Operation(
    code: 'EXT',
    configurations: {
      OperationConfiguration(
        sizes: _sizesWL,
        operandTypes: [
          {OperandType.dx},
        ],
      ),
    },
  );
  static Operation illegal = Operation(
    code: 'ILLEGAL',
    configurations: {
      OperationConfiguration(),
    },
  );
  static Operation jmp = Operation(
    code: 'JMP',
    configurations: {
      OperationConfiguration(
        operandTypes: [
          _typesAxIndAbsPcNoAxPrePost,
        ],
      ),
    },
  );
  static Operation jsr = Operation(
    code: 'JSR',
    configurations: {
      OperationConfiguration(
        operandTypes: [
          _typesAxIndAbsPcNoAxPrePost,
        ],
      ),
    },
  );
  static Operation lea = Operation(
    code: 'LEA',
    configurations: {
      OperationConfiguration(
        sizes: _sizesL,
        operandTypes: [
          _typesAxAbsPcNoAxPrePost,
          {OperandType.ax},
        ],
      ),
    },
  );
  static Operation link = Operation(
    code: 'LINK',
    configurations: {
      OperationConfiguration(
        operandTypes: [
          {OperandType.ax},
          {OperandType.immediate},
        ],
      ),
    },
  );
  static Operation lsl = Operation(
    code: 'LSL',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.dx},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesAxIndAbs,
        ],
      ),
    },
  );
  static Operation lsr = Operation(
    code: 'LSR',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.dx},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          {OperandType.immediate},
          {OperandType.dx},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesAxIndAbs,
        ],
      ),
    },
  );
  static Operation move = Operation(
    code: 'MOVE',
    configurations: {
      OperationConfiguration(
        sizes: _sizesBWL,
        operandTypes: [
          _typesAll,
          _typesNoAxPcImm,
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesNoAx,
          {OperandType.ccr},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          _typesNoAx,
          {OperandType.sr},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesW,
        operandTypes: [
          {OperandType.sr},
          _typesNoAxPcImm,
        ],
      ),
      OperationConfiguration(
        sizes: _sizesL,
        operandTypes: [
          {OperandType.usp},
          {OperandType.ax},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesL,
        operandTypes: [
          {OperandType.ax},
          {OperandType.usp},
        ],
      ),
    },
  );
  static Operation movea = Operation(
    code: 'MOVEA',
    configurations: {
      OperationConfiguration(
        sizes: _sizesWL,
        operandTypes: [
          _typesAll,
          {OperandType.ax},
        ],
      ),
    },
  );
  static Operation movep = Operation(
    code: 'MOVEP',
    configurations: {
      OperationConfiguration(
        sizes: _sizesWL,
        operandTypes: [
          {OperandType.dx},
          {OperandType.axIndWithDisplacement},
        ],
      ),
      OperationConfiguration(
        sizes: _sizesWL,
        operandTypes: [
          {OperandType.axIndWithDisplacement},
          {OperandType.dx},
        ],
      ),
    },
  );
  static List<Operation> values = [
    abcd,
    add,
    adda,
    addi,
    addq,
    addx,
    and,
    andi,
    asl,
    asr,
    ...bcc,
    bchg,
    bclr,
    bra,
    bset,
    bsr,
    btst,
    chk,
    clr,
    cmp,
    cmpa,
    cmpi,
    cmpm,
    ...dbcc,
    divs,
    divu,
    eor,
    eori,
    exg,
    ext,
    illegal,
    jmp,
    jsr,
    lea,
    link,
    lsl,
    lsr,
    move,
    movea,
    movep,
  ];
}

class OperationConfiguration {
  final Set<Size> sizes;
  final List<Set<OperandType>> operandTypes;

  const OperationConfiguration({
    this.sizes = const {},
    this.operandTypes = const [],
  })  : assert(sizes != null),
        assert(operandTypes != null);
}
