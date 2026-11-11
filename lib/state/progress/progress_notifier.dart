import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// PROGRESS NOTIFIER
///////////////////////////////////////////////////////////////////////////////////////////////////
class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier(this.repository) : super(_read(repository));

  final GameRepositoryAbstract repository;

  static ProgressState _read(GameRepositoryAbstract repository) =>
      ProgressState(
        unlockedLevel: repository.unlockedLevel,
        bestTimes: repository.bestTimes(),
      );

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// RECORD A WIN
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> recordWin(GameLevel level, Duration time) async {
    await repository.recordWin(level, time);
    if (mounted) state = _read(repository);
  }
}
