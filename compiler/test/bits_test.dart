import 'package:kt_dart/kt.dart';
import 'package:m68k_reloaded_compiler/src/bits.dart';
import 'package:test/test.dart';

void main() {
  group('Bits', () {
    group('created correctly', () {
      group('from List', () {
        <List<int>>[
          [],
          [0],
          [1],
          [0, 0, 0, 0, 0],
          [0, 1, 0, 1, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        ].forEach((bits) {
          test(bits.toString(), () => expect(Bits(bits).bits, equals(bits)));
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
              Bits.fromInt(length, value).bits,
              equals(expectedBits),
            ),
          );
        });
      });
      group('from byte', () {
        <int, List>{
          0x00: [0, 0, 0, 0, 0, 0, 0, 0],
          0x01: [0, 0, 0, 0, 0, 0, 0, 1],
          0x11: [0, 0, 0, 1, 0, 0, 0, 1],
          0x42: [0, 1, 0, 0, 0, 0, 1, 0],
          0x57: [0, 1, 0, 1, 0, 1, 1, 1],
          0xF0: [1, 1, 1, 1, 0, 0, 0, 0],
          0xFF: [1, 1, 1, 1, 1, 1, 1, 1],
        }.forEach((value, expectedBits) {
          test(
            '0x${value.toRadixString(16)}',
            () => expect(Bits.byte(value).bits, equals(expectedBits)),
          );
        });
      });
    });

    group('equals', () {
      group('on equal bits', () {
        <List<int>>[
          [],
          [0],
          [1],
          [0, 1],
          [0, 0, 0, 0],
          [1, 1, 1, 1, 1, 1, 1, 1],
        ].forEach((list) {
          test(list.toString(), () => expect(Bits(list), equals(Bits(list))));
        });
      });
    });
  });
}
