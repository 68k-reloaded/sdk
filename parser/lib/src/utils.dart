import 'scanner/scanner.dart';

extension FancyList<T> on List<T> {
  T get firstOrNull => firstWhere((_) => true, orElse: () => null);

  T get secondOrNull => length >= 1 ? this[1] : null;
  T get second => secondOrNull ?? (throw StateError('No element.'));

  T get thirdOrNull => length >= 2 ? this[2] : null;
  T get third => thirdOrNull ?? (throw StateError('No element.'));

  T get lastOrNull => isEmpty ? null : last;
}

extension TokenList on List<Token> {
  Token get firstOrNullToken => firstOrNull ?? const NullToken();
  Token get secondOrNullToken => secondOrNull ?? const NullToken();
  Token get thirdOrNullToken => thirdOrNull ?? const NullToken();
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
}
