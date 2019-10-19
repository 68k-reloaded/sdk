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
