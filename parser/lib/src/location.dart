import 'package:data_classes/data_classes.dart';
import 'package:meta/meta.dart';

@immutable
class Location {
  final int line;
  final int col;
  final int length;

  const Location({
    @required this.line,
    @required this.col,
    @required this.length,
  })  : assert(line != null),
        assert(col != null),
        assert(length != null);

  static const invalid = Location(line: 0, col: 0, length: 0);

  Location withLength(int length) =>
      Location(line: line, col: col, length: length);
  Location inLineAbove() => Location(line: line - 1, col: col, length: length);

  @override
  String toString() => '$line:$col';

  bool operator ==(Object other) =>
      other is Location && line == other.line && col == other.col;
  int get hashCode => hashList([line, col]);
}
