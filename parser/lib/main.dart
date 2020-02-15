import 'src/error.dart';
import 'src/parser/parser.dart';
import 'src/scanner/scanner.dart';

void main() {
  // parse('');
  // parse('move.w d1, d2');
  parse('''
* hey
   * ho
drawPaddle:
 MOVEM.L D0,-(SP)
 clr.L   D2        * this does something
 MOVE.W  D1, D2
 CLR.L   D4
 MOVE.W  D1, D4
 CLR.L   D1
 MOVE.W  D0, D1
 CLR.L   D3
 MOVE.W  D0, D3

 MOVE.B  #87, D0
 SUBI.W  #0, D1
 SUBI.W  #0, D2
 ADDI.W  #0, D3
 ADDI.W  #0, D4 - invalid_code
 TRAP    #15
''');
}

void parse(String source) {
  final errorCollector = ErrorCollector();
  final program = source.scanned(errorCollector).parsed(errorCollector);

  print('Errors:');
  errorCollector.dump(source);

  print('\nReconstructed program:');
  program.statements
      .forEach((statement) => print(statement?.toAlignedString()));
}
