import 'package:kt_dart/collection.dart';
import 'package:meta/meta.dart';

import 'location.dart';

class Error {
  final Location location;
  final String message;

  Error({@required this.location, @required this.message})
      : assert(location != null),
        assert(message != null);

  String toString() => 'Error at $location: $message';
}

class ErrorCollector {
  final KtMutableList<Error> _errors = KtMutableList.empty();

  KtList<Error> get errors => _errors;
  bool get hasError => _errors.isNotEmpty();
  bool get hasNoError => _errors.isEmpty();

  void add(Error error) {
    assert(error != null);
    print(error);
    _errors.add(error);
  }
}
