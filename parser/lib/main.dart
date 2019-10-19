import 'src/error.dart';
import 'src/parser/parser.dart';
import 'src/scanner/scanner.dart';

void main() {
  parse('''
drawPaddle:
 MOVEM.L D0-D4,-(SP)
 CLR.L   D2
 MOVE.W  D1,D2
 CLR.L   D4
 MOVE.W  D1,D4
 CLR.L   D1
 MOVE.W  D0,D1
 CLR.L   D3
 MOVE.W  D0,D3

 MOVE.B  #87,D0
 SUBI.W  #PADDLE_RX,D1
 SUBI.W  #PADDLE_RY,D2
 ADDI.W  #PADDLE_RX,D3
 ADDI.W  #PADDLE_RY,D4
 TRAP    #15
''');
}

void parse(String source) {
  final errorCollector = ErrorCollector();
  final scanner = Scanner(source: source, errorCollector: errorCollector);

  scanner.scanTokens();

  scanner.tokens.forEach(print);
}
