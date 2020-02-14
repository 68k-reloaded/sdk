import 'dart:typed_data';

import 'package:kt_dart/collection.dart';
import 'package:meta/meta.dart';

/// A list of bits, interpreted as big-endian.
@immutable
class Bits {
  static const lengthByte = 8;
  static const lengthWord = 16;

  Bits(KtList<int> this.bits)
      : assert(bits != null),
        assert(bits.all((b) => b == 0 || b == 1));
  Bits.from(Iterable<int> bits) : this(KtList.from(bits));
  Bits.combine(List<Bits> bits)
      : this(KtList.from(bits).flatMap((b) => b.bits));
  Bits.fromInt(int length, int number)
      : this.from(List.generate(length, (i) => (number >> i) & 0x1).reversed);

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

  void assertByteLength() => assertLength(lengthByte);
  void assertWordLength() => assertLength(lengthWord);
}

extension BitList on List<int> {
  Bits get bits => Bits.from(this);
}
