import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// SUDOKU PUZZLE — THE STARTING CLUES (0 = EMPTY)
///////////////////////////////////////////////////////////////////////////////////////////////////
class SudokuPuzzle {
  const SudokuPuzzle({required this.layout, required this.clues});

  final BoardLayout layout;
  final List<int> clues;

  bool isGiven(int index) => clues[index] != 0;
}
