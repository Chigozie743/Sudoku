import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME LEVEL
///////////////////////////////////////////////////////////////////////////////////////////////////
class GameLevel {
  const GameLevel({
    required this.number,
    required this.difficulty,
    required this.layout,
    required this.clues,
    this.maxMistakes = 3,
    this.hints = 1,
  });

  final int number;
  final String difficulty;
  final BoardLayout layout;

  /// How many cells start filled in.
  final int clues;
  final int maxMistakes;
  final int hints;

  String get title => 'Level $number';
}
