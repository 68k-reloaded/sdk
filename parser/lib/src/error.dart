import 'package:kt_dart/collection.dart';
import 'package:meta/meta.dart';

class Error {
  final int line;
  final String message;

  Error({@required this.line, @required this.message})
      : assert(line != null),
        assert(message != null);
}

class ErrorCollector {
  final KtMutableList<Error> _errors = KtMutableList.empty();

  KtList<Error> get errors => _errors;
  bool get hasError => _errors.isNotEmpty();
  bool get hasNoError => _errors.isEmpty();

  void add(Error error) {
    assert(error != null);
    _errors.add(error);
  }
}

String iterableToString(Iterable<Object> items) {
  if (items.isEmpty) {
    return '';
  } else if (items.length == 1) {
    return items.single.toString();
  } else {
    return '${items.take(items.length - 1).join(', ')} and ${items.last}';
  }
}
