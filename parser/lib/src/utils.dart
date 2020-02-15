import '../parser.dart';
import 'scanner/scanner.dart';

extension FancyList<T> on List<T> {
  T get firstOrNull => firstWhere((_) => true, orElse: () => null);

  T get secondOrNull => length >= 1 ? this[1] : null;
  T get second => secondOrNull ?? (throw StateError('No element.'));

  T get thirdOrNull => length >= 2 ? this[2] : null;
  T get third => thirdOrNull ?? (throw StateError('No element.'));

  T get fourthOrNull => length >= 3 ? this[3] : null;
  T get fourth => thirdOrNull ?? (throw StateError('No element.'));

  T get sixthOrNull => length >= 3 ? this[3] : null;
  T get sixth => thirdOrNull ?? (throw StateError('No element.'));

  T get eigthOrNull => length >= 3 ? this[3] : null;
  T get eigth => thirdOrNull ?? (throw StateError('No element.'));

  T get lastOrNull => isEmpty ? null : last;

  void addIfNotNull(T object) {
    if (object != null) {
      add(object);
    }
  }

  List<T> removeFirstN(int n) {
    final removed = sublist(0, n);
    removeRange(0, n);
    return removed;
  }

  T removeFirst() => removeAt(0);
  List<T> removeFirstTwo() => removeFirstN(2);
  List<T> removeFirstThree() => removeFirstN(3);

  List<T> removeUntil(
    bool Function(T item) test, {
    bool inclusive = false,
  }) {
    final index = this.indexWhere(test) + (inclusive ? 1 : 0);
    return index == -1 ? null : removeFirstN(index);
  }
}

extension TokenList on List<Token> {
  Token get firstOrNullToken => firstOrNull ?? const NullToken();
  Token get secondOrNullToken => secondOrNull ?? const NullToken();
  Token get thirdOrNullToken => thirdOrNull ?? const NullToken();
  Token get fourthOrNullToken => fourthOrNull ?? const NullToken();
  Token get sixthOrNullToken => fourthOrNull ?? const NullToken();
  Token get eigthOrNullToken => fourthOrNull ?? const NullToken();
  Token get lastOrNullToken => lastOrNull ?? const NullToken();
}

extension FancyIterable<T> on Iterable<T> {
  String toReadableString() {
    if (isEmpty) {
      return '';
    } else if (length == 1) {
      return single.toString();
    } else {
      return '${take(length - 1).join(', ')} and $last';
    }
  }

  T firstWhereOrNull(bool Function(T obj) predicate) =>
      firstWhere(predicate, orElse: () => null);

  T get firstWhereNotNull => firstWhereOrNull((obj) => obj != null);

  deeplyEquals(Iterable<T> other) {
    if (length != other.length) {
      return false;
    }
    final a = iterator;
    final b = other.iterator;

    do {
      if (a.current != b.current) return false;
    } while (a.moveNext() && b.moveNext());

    return true;
  }
}
