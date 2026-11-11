import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// SUDOKU SOLVER — BACKTRACKING OVER ANY BOARD LAYOUT
///////////////////////////////////////////////////////////////////////////////////////////////////
class SudokuSolver {
  const SudokuSolver(this.layout);

  final BoardLayout layout;

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// CAN [value] GO AT [index] WITHOUT REPEATING IN ITS ROW, COLUMN OR TILE
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  bool fits(List<int> board, int index, int value) {
    for (final peer in layout.peersOf(index)) {
      if (board[peer] == value) return false;
    }
    return true;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// ONE COMPLETE SOLUTION, OR NULL WHEN THE BOARD CANNOT BE FINISHED
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  List<int>? solve(List<int> board, {Random? random}) {
    final work = List<int>.of(board);
    return _search(work, random, (_) => true) ? work : null;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// COUNT SOLUTIONS, STOPPING AT [limit]
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  int countSolutions(List<int> board, {int limit = 2}) {
    var count = 0;
    _search(List<int>.of(board), null, (_) => ++count >= limit);
    return count;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// DEPTH-FIRST SEARCH, ALWAYS BRANCHING ON THE CELL WITH THE FEWEST CANDIDATES
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // [onSolved] returns true to stop searching.
  bool _search(
    List<int> board,
    Random? random,
    bool Function(List<int>) onSolved,
  ) {
    var bestIndex = -1;
    List<int>? bestCandidates;
    for (var index = 0; index < board.length; index++) {
      if (board[index] != 0) continue;
      final candidates = [
        for (var value = 1; value <= layout.digits; value++)
          if (fits(board, index, value)) value,
      ];
      if (candidates.isEmpty) return false;
      if (bestCandidates == null || candidates.length < bestCandidates.length) {
        bestIndex = index;
        bestCandidates = candidates;
        if (candidates.length == 1) break;
      }
    }
    if (bestCandidates == null) return onSolved(board);

    if (random != null) bestCandidates.shuffle(random);
    for (final value in bestCandidates) {
      board[bestIndex] = value;
      if (_search(board, random, onSolved)) return true;
    }
    board[bestIndex] = 0;
    return false;
  }
}
