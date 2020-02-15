import 'package:meta/meta.dart';

import 'location.dart';

class Error {
  final Location location;
  final String message;

  Error({@required this.location, @required this.message})
      : assert(location != null),
        assert(message != null);

  String toString() => 'Error at $location: $message';
  String toHelpfulString(String source) {
    final buffer = StringBuffer();
    final lines = source.split('\n');

    void writeLineAt(Location location) {
      if (location.line <= 0 || location.line > lines.length) return;
      final lineNumber = location.line;
      final line = lines[lineNumber - 1];
      buffer.writeln('${lineNumber.toString().padLeft(4)} | $line');
    }

    void writeErrorHighlight(Location location) {
      buffer.writeln([
        for (int i = 0; i < 4 + 3; i++) ' ',
        for (int i = 0; i < location.col - 1; i++) ' ',
        for (int i = 0; i < location.length; i++) '^',
      ].join());
    }

    writeLineAt(location.inLineAbove().inLineAbove());
    writeLineAt(location.inLineAbove());
    writeLineAt(location);
    writeErrorHighlight(location);
    buffer.writeln(toString());
    return buffer.toString();
  }
}

class ErrorCollector {
  final _errors = <Error>[];

  List<Error> get errors => _errors;
  bool get hasError => _errors.isNotEmpty;
  bool get hasNoError => _errors.isEmpty;

  void add(Error error) {
    assert(error != null);
    _errors.add(error);
  }

  void dump(String source) {
    for (final error in errors) {
      print(error.toHelpfulString(source));
    }
  }
}
