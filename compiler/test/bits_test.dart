import 'package:kt_dart/kt.dart';
import 'package:m68k_reloaded_compiler/src/bits.dart';
import 'package:test/test.dart';

void main() {
  group('Bits', () {
    final exampleLists = <List<int>>[
      [],
      [0],
      [1],
      [0, 0, 0, 0, 0],
      [0, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ];

    group('created correctly', () {
      group('from KtList', () {
        exampleLists.forEach((bits) {
          test(
            bits.toString(),
            () => expect(Bits(KtList.from(bits)).bits.asList(), equals(bits)),
          );
        });
      });
      group('from List', () {
        exampleLists.forEach((bits) {
          test(
            bits.toString(),
            () => expect(Bits.from(bits).bits.asList(), equals(bits)),
          );
        });
      });
      group('from int', () {
        <KtPair<int, int>, List>{
          KtPair(0, 0): [],
          KtPair(1, 0): [0],
          KtPair(1, 1): [1],
          KtPair(2, 0): [0, 0],
          KtPair(4, 1): [0, 0, 0, 1],
          KtPair(16, 0): [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          KtPair(8, 0x11): [0, 0, 0, 1, 0, 0, 0, 1],
          KtPair(8, 0x42): [0, 1, 0, 0, 0, 0, 1, 0],
          KtPair(8, 0x57): [0, 1, 0, 1, 0, 1, 1, 1],
          KtPair(16, 0x4640): [0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0],
        }.forEach((lengthAndValue, expectedBits) {
          final length = lengthAndValue.first;
          final value = lengthAndValue.second;
          test(
            'Length: $length, value: 0x${value.toRadixString(16)}',
            () => expect(
              Bits.fromInt(length, value).bits.asList(),
              equals(expectedBits),
            ),
          );
        });
      });
    });
  });
}
