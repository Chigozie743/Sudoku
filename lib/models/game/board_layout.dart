///////////////////////////////////////////////////////////////////////////////////////////////////
/// BOARD LAYOUT — HOW MANY TILES (BOXES) AND HOW MANY CELLS IN EACH
///////////////////////////////////////////////////////////////////////////////////////////////////
// Rules: every tile holds 1..digits once, and no digit repeats in a row or column.
// A single 3×3 tile has digits 1–9; 2×2 tiles of 2×2 make a 4×4 board with digits 1–4;
// 3×3 tiles of 3×3 make the classic 9×9 board.
class BoardLayout {
  const BoardLayout({
    required this.boxesAcross,
    required this.boxesDown,
    required this.boxWidth,
    required this.boxHeight,
  });

  final int boxesAcross;
  final int boxesDown;
  final int boxWidth;
  final int boxHeight;

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// DERIVED SIZES
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  int get digits => boxWidth * boxHeight;
  int get columns => boxesAcross * boxWidth;
  int get rows => boxesDown * boxHeight;
  int get cellCount => columns * rows;

  /// True when every row and column holds every digit, so a puzzle can have exactly one answer.
  /// A lone 3×3 tile can't: its empty cells take the missing digits in any order.
  bool get supportsUniqueSolution => rows == digits && columns == digits;

  int rowOf(int index) => index ~/ columns;
  int columnOf(int index) => index % columns;
  int boxOf(int index) =>
      (rowOf(index) ~/ boxHeight) * boxesAcross + columnOf(index) ~/ boxWidth;

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// CELLS THAT SHARE A ROW, COLUMN OR TILE WITH [index] (NOT INCLUDING ITSELF)
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  List<int> peersOf(int index) => (_peerCache[_key] ??= _buildPeers())[index];

  static final Map<String, List<List<int>>> _peerCache = {};

  String get _key => '$boxesAcross.$boxesDown.$boxWidth.$boxHeight';

  List<List<int>> _buildPeers() => List.generate(cellCount, (index) {
    final row = rowOf(index);
    final column = columnOf(index);
    final box = boxOf(index);
    return [
      for (var other = 0; other < cellCount; other++)
        if (other != index &&
            (rowOf(other) == row ||
                columnOf(other) == column ||
                boxOf(other) == box))
          other,
    ];
  });

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// SHORT LABEL, E.G. "1 TILE · 3×3" OR "2×2 TILES · 2×2"
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  String get label {
    final tiles = boxesAcross * boxesDown == 1
        ? '1 tile'
        : '$boxesAcross×$boxesDown tiles';
    return '$tiles · $boxWidth×$boxHeight each';
  }
}
