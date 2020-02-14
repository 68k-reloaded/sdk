part of 'statements.dart';

enum SizeValue { byte, word, longWord }

extension SizeToString on SizeValue {
  String toReadableString() {
    return {
      SizeValue.byte: 'byte',
      SizeValue.word: 'word',
      SizeValue.longWord: 'long word',
    }[this];
  }

  String toShortString() {
    return {
      SizeValue.byte: 'B',
      SizeValue.word: 'W',
      SizeValue.longWord: 'L',
    }[this];
  }
}

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

extension OperandTypeToString on OperandType {
  String toDescriptiveString() {
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
    }[this];
  }

  String toShortString() {
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
    }[this];
  }
}

class OperationType {
  const OperationType(this.code) : assert(code != null);

  final String code;

  String toString() => code;

  static const conditionCodes = <String>[
    ...['T', 'F', 'HI', 'LS', 'HS', 'CC', 'LO', 'CS', 'NE', 'EQ'],
    ...['VC', 'VS', 'PL', 'MI', 'GE', 'GE', 'LT', 'GT', 'LE'],
  ];

  static final values = <OperationType>[
    ...dataMovement,
    ...integerArithmetic,
    ...logical,
    ...shiftRotate,
    ...bitManipulation,
    ...bitField,
    ...binaryCodedDecimal,
    ...programControl,
    ...systemControl,
  ];

  // Data Movement
  // TODO: MOVEM, PEA, UNLK
  static const dataMovement = <OperationType>[
    exg,
    lea,
    link,
    ...[move, movea, movep, moveq],
  ];
  static const exg = OperationType('EXG');
  static const lea = OperationType('LEA');
  static const link = OperationType('LINK');
  static const move = OperationType('MOVE');
  static const movea = OperationType('MOVEA');
  static const movep = OperationType('MOVEP');
  static const moveq = OperationType('MOVEQ');

  // Integer Arithmetic
  // TODO: MULS, MULU, NEG, NEGX, SUB, SUBA, SUBI, SUBX
  static const integerArithmetic = <OperationType>[
    ...[add, adda, addi, addq, addx],
    clr,
    ...[cmp, cmpa, cmpi, cmpm],
    ...[divs, divu],
    ext
  ];
  static const add = OperationType('ADD');
  static const adda = OperationType('ADDA');
  static const addi = OperationType('ADDI');
  static const addq = OperationType('ADDQ');
  static const addx = OperationType('ADDX');
  static const clr = OperationType('CLR');
  static const cmp = OperationType('CMP');
  static const cmpa = OperationType('CMPA');
  static const cmpi = OperationType('CMPI');
  static const cmpm = OperationType('CMPM');
  static const divs = OperationType('DIVS');
  static const divu = OperationType('DIVU');
  static const ext = OperationType('EXT');
  static const subq = OperationType('SUBQ');

  // Logical
  // TODO: OR, ORI
  static const logical = <OperationType>[
    ...[and, andi],
    ...[eor, eori],
  ];
  static const and = OperationType('AND');
  static const andi = OperationType('ANDI');
  static const eor = OperationType('EOR');
  static const eori = OperationType('EORI');
  static const not = OperationType('NOT');

  // Shift and Rotate
  // TODO: ROL, ROR, ROXL, ROXR, SWAP
  static const shiftRotate = <OperationType>[
    ...[asl, asr],
    ...[lsl, lsr],
  ];
  static const asl = OperationType('ASL');
  static const asr = OperationType('ASR');
  static const lsl = OperationType('LSL');
  static const lsr = OperationType('LSR');

  // Bit Manipulation
  static const bitManipulation = <OperationType>[
    ...[bchg, bclr, bset, btst],
  ];
  static const bchg = OperationType('BCHG');
  static const bclr = OperationType('BCLR');
  static const bset = OperationType('BSET');
  static const btst = OperationType('BTST');

  // Bit Field
  // TODO: BFCHG, BFCLR, BFEXTS, BFEXTU, BFFFO, BFINS, BFSET, BFTST
  static const bitField = <OperationType>[];

  // Binary-Coded Decimal
  // TODO: NBCD, PACK, SBCD, UNPK
  static const binaryCodedDecimal = <OperationType>[
    ...[abcd],
  ];
  static const abcd = OperationType('ABCD');

  // Program Control
  // TODO: Scc, NOP, RTR, RTS, TST
  static final programControl = <OperationType>[
    // Integer Conditional
    ...bcc,
    ...dbcc,
    // Unconditional
    ...[bra, bsr],
    ...[jmp, jsr],
  ];
  static final dbcc =
      conditionCodes.map((cc) => OperationType('DB$cc')).toList();
  static final bcc = conditionCodes.map((cc) => OperationType('B$cc')).toList();
  static const bra = OperationType('BRA');
  static const bsr = OperationType('BSR');
  static const jmp = OperationType('JMP');
  static const jsr = OperationType('JSR');

  // System Control
  // ANDI, EORI, ORI, MOVE to SR; MOVE from SR; MOVE USP are in their respective categories
  // TODO: RESET, RTE, STOP, TRAP, TRAPV
  static const systemControl = <OperationType>[
    // Privileged
    // Trap Generating
    chk,
    illegal,
  ];
  static const chk = OperationType('CHK');
  static const illegal = OperationType('ILLEGAL');
}

class OperationConfiguration {
  final Set<SizeValue> sizes;
  final List<Set<OperandType>> operandTypes;

  const OperationConfiguration({
    this.sizes = const {},
    this.operandTypes = const [],
  })  : assert(sizes != null),
        assert(operandTypes != null);

  String toString() {
    return 'OperationConfiguration with sizes ${sizes.toReadableString()} '
        'and operand types ${operandTypes.toReadableString()}';
  }
}
