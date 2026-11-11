import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// PROGRESS NOTIFIER PROVIDER
///////////////////////////////////////////////////////////////////////////////////////////////////
final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>(
  (ref) => ProgressNotifier(ref.watch(gameRepositoryProvider)),
);

///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME NOTIFIER PROVIDER — ONE PER LEVEL BEING PLAYED
///////////////////////////////////////////////////////////////////////////////////////////////////
final gameProvider = StateNotifierProvider.autoDispose
    .family<GameNotifier, GameState, int>(
      (ref, levelNumber) => GameNotifier(
        ref.watch(gameRepositoryProvider),
        GameLevels.byNumber(levelNumber),
        onWin: (level, time) =>
            ref.read(progressProvider.notifier).recordWin(level, time),
      ),
    );
