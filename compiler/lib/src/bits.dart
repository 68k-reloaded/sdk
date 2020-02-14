import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A list of bits, interpreted as big-endian.
@immutable
class Bits {
  static const byteLength = 8;
  static const byteMin = 0;
  static const byteMax = (1 << byteLength) - 1;
  static const wordLength = 16;
  static const wordMin = 0;
  static const wordMax = (1 << wordLength) - 1;

  Bits(Iterable<int> bits)
      : assert(bits != null),
        assert(bits.every((b) => b == 0 || b == 1)),
        this.bits = bits.toList(growable: false);
  Bits.combine(List<Bits> bits) : this(bits.expand((b) => b.bits));
  Bits.fromInt(int length, int value)
      : this(List.generate(length, (i) => (value >> i) & 0x1).reversed);

  factory Bits.byte(int value) {
    assert(byteMin <= value, 'Byte value must be >=$byteMin, was: $value');
    assert(value <= byteMax, 'Byte value must be <=$byteMax, was: $value');
    return Bits.fromInt(byteLength, value);
  }
  factory Bits.word(int value) {
    assert(wordMin <= value, 'Word value must be >=$wordMin, was: $value');
    assert(value <= wordMax, 'Word value must be <=$wordMax, was: $value');
    return Bits.fromInt(wordLength, value);
  }

  static final zero = Bits([0]);
  static final one = Bits([1]);

  final List<int> bits;

  bool get hasByteLength => bits.length == byteLength;
  bool get hasWordLength => bits.length == wordLength;

  int get combined => _combine(bits);
  static int _combine(List<int> bits) =>
      bits.fold(0, (byte, bit) => (byte << 1) + bit);
  Uint8List get asUint8List {
    assert(bits.length % byteLength == 0);

    final length = bits.length ~/ byteLength;
    final result = Uint8List(length);
    for (var i = 0; i < length; i++) {
      result[i] = _combine(bits.sublist(i * byteLength, (i + 1) * byteLength));
    }
    return result;
  }

  Bits operator +(Bits other) => Bits(bits + other.bits);

  @override
  String toString() => bits.join();
  String toRadixString(int radix) => combined.toRadixString(radix);
  String toHexString() => toRadixString(16);

  bool operator ==(Object other) => other is Bits && bits == other.bits;
  int get hashCode => bits.hashCode;
}

extension BitList on List<int> {
  Bits get bits => Bits(this);
}

/* 
@immutable
abstract class FixedUInt {
  FixedUInt(this.value, int bitLength)
      : assert(value != null),
        assert(bitLength != null),
        assert(value >= 0),
        assert(value.bitLength <= bitLength);

  final int value;

  List<Byte> get asBytes;
}

@immutable
class Byte extends FixedUInt {
  Byte(int value) : super(value, bitLength);

  static const bitLength = 8;
  Byte.fromBits(Bits bits)
      : assert(bits != null),
        this(bits.combined);

  @override
  List<Byte> get asBytes => [this];
}
@immutable
class Word extends FixedUInt {
  Word(int value) : super(value, bitLength);

  static const bitLength = 16;
  Word.fromBits(Bits bits)
      : assert(bits != null),
        this(bits.combined);
}
 */
