import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME REPOSITORY IMPLEMENTATION
///////////////////////////////////////////////////////////////////////////////////////////////////
class GameRepositoryImpl implements GameRepositoryAbstract {
  GameRepositoryImpl(this.puzzles, this.progress);

  final PuzzleSourceAbstract puzzles;
  final ProgressLocalSourceAbstract progress;

  @override
  SudokuPuzzle newPuzzle(GameLevel level) => puzzles.generate(level);

  @override
  int get unlockedLevel => progress.unlockedLevel;

  @override
  Map<int, int> bestTimes() => {
    for (final level in GameLevels.all)
      level.number: ?progress.bestSeconds(level.number),
  };

  @override
  Future<void> recordWin(GameLevel level, Duration time) async {
    final next = GameLevels.after(level);
    if (next != null && next.number > progress.unlockedLevel) {
      await progress.saveUnlockedLevel(next.number);
    }
    final best = progress.bestSeconds(level.number);
    if (best == null || time.inSeconds < best) {
      await progress.saveBestSeconds(level.number, time.inSeconds);
    }
  }
}
