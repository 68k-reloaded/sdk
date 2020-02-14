import 'package:m68k_reloaded_parser/parser.dart';

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
