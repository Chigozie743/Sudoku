import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// PUZZLE SOURCE IMPLEMENTATION — GENERATES BOARDS ON THE DEVICE
///////////////////////////////////////////////////////////////////////////////////////////////////
class PuzzleSourceImpl implements PuzzleSourceAbstract {
  PuzzleSourceImpl({Random? random}) : random = random ?? Random();

  final Random random;

  static const int _attempts = 20;

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// GENERATE — FILL A RANDOM SOLUTION, THEN CLEAR CELLS DOWN TO THE LEVEL'S CLUE COUNT
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  @override
  SudokuPuzzle generate(GameLevel level) {
    final layout = level.layout;
    final solver = SudokuSolver(layout);
    final target = level.clues.clamp(1, layout.cellCount);

    List<int>? best;
    for (var attempt = 0; attempt < _attempts; attempt++) {
      final board = solver.solve(
        List<int>.filled(layout.cellCount, 0),
        random: random,
      )!;
      final clues = _clear(board, target, solver, layout);
      if (best == null || _filled(clues) < _filled(best)) best = clues;
      if (_filled(best) <= target) break;
    }
    return SudokuPuzzle(layout: layout, clues: best!);
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// CLEAR CELLS IN RANDOM ORDER, KEEPING THE ANSWER UNIQUE WHERE THE LAYOUT ALLOWS IT
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  List<int> _clear(
    List<int> solution,
    int target,
    SudokuSolver solver,
    BoardLayout layout,
  ) {
    final board = List<int>.of(solution);
    final order = List<int>.generate(board.length, (i) => i)..shuffle(random);
    var filled = board.length;
    for (final index in order) {
      if (filled <= target) break;
      final value = board[index];
      board[index] = 0;
      if (layout.supportsUniqueSolution && solver.countSolutions(board) != 1) {
        board[index] = value;
      } else {
        filled--;
      }
    }
    return board;
  }

  int _filled(List<int> board) => board.where((v) => v != 0).length;
}
