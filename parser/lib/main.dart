import 'src/error.dart';
import 'src/parser/parser.dart';
import 'src/scanner/scanner.dart';

void main() {
  // parse('');
  parse('''
* hey
   * ho
drawPaddle:
 MOVEM.L D0,-(SP)
 clr.L   D2        * this does something
 MOVE.W  D1,D2
 CLR.L   D4
 MOVE.W  D1,D4
 CLR.L   D1
 MOVE.W  D0,D1
 CLR.L   D3
 MOVE.W  D0,D3

 MOVE.B  #87,D0
 SUBI.W  #0,D1
 SUBI.W  #0,D2
 ADDI.W  #0,D3
 ADDI.W  #0,D4
 TRAP    #15
''');
}

void parse(String source) {
  final errorCollector = ErrorCollector();

  final tokens = Scanner.scan(
    source: source,
    errorCollector: errorCollector,
  );
  // tokens.forEach(print);

  final program = Parser.parse(
    tokens: tokens,
    errorCollector: errorCollector,
  );
  program.statements
      .forEach((statement) => print(statement?.toAlignedString()));
}
