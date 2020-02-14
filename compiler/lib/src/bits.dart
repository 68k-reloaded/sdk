import 'dart:typed_data';

import 'package:kt_dart/collection.dart';
import 'package:meta/meta.dart';

/// A list of bits, interpreted as big-endian.
@immutable
class Bits {
  static const byteLength = 8;
  static const byteMin = 0;
  static const byteMax = 1 << byteLength - 1;
  static const wordLength = 16;
  static const wordMin = 0;
  static const wordMax = 1 << wordLength - 1;

  Bits(KtList<int> this.bits)
      : assert(bits != null),
        assert(bits.all((b) => b == 0 || b == 1));
  Bits.from(Iterable<int> bits) : this(KtList.from(bits));
  Bits.combine(List<Bits> bits)
      : this(KtList.from(bits).flatMap((b) => b.bits));
  Bits.fromInt(int length, int value)
      : this.from(List.generate(length, (i) => (value >> i) & 0x1).reversed);

  factory Bits.byte(int value) {
    assert(byteMin <= value, 'Byte value must be >=$byteMin, was: $value');
    assert(value <= byteMax, 'Byte value must be <=$byteMax, was: $value');
    return Bits.fromInt(byteLength, value);
  }

  static final zero = Bits.from([0]);
  static final one = Bits.from([1]);

  final KtList<int> bits;

  int get combined => _combine(bits);
  static int _combine(KtList<int> bits) =>
      bits.fold(0, (byte, bit) => (byte << 1) + bit);

  Bits operator +(Bits other) => Bits(bits + other.bits);

  Uint8List get asUint8List {
    assert(bits.size % 8 == 0);
    return Uint8List.fromList(
        bits.chunked(8).map((b) => _combine(bits)).asList());
  }

  // assertions
  void assertLength(int expectedLength) {
    assert(bits.size == expectedLength,
        'Expected $expectedLength bits, got: ${bits.size}');
  }

  void assertByteLength() => assertLength(byteLength);
  void assertWordLength() => assertLength(wordLength);
}

extension BitList on List<int> {
  Bits get bits => Bits.from(this);
}
