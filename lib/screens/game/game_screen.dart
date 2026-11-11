import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME SCREEN
///////////////////////////////////////////////////////////////////////////////////////////////////
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key, required this.levelNumber});

  final int levelNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameProvider(levelNumber);
    final state = ref.watch(provider);
    final game = ref.read(provider.notifier);

    ref.listen(provider.select((s) => s.status), (previous, status) {
      if (previous == status) return;
      if (status == GameStatus.won) _showWon(context, state);
      if (status == GameStatus.lost) _showLost(context, game);
    });

    return Scaffold(
      appBar: AppBar(
        title: TextWidget(state.level.title, size: 20, weight: FontWeight.w500),
        actions: [
          IconButton(
            tooltip: 'New game',
            icon: const Icon(Icons.refresh),
            onPressed: game.restart,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _InfoBar(state: state, onPause: game.togglePause),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: _BoardArea(state: state, game: game),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Actions(state: state, game: game),
                  const SizedBox(height: 16),
                  NumberPadWidget(
                    digits: state.layout.digits,
                    onDigit: game.input,
                    isDone: (d) =>
                        !state.noteMode &&
                        state.placedCount(d) >= state.maxPerDigit,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// DIALOGS
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void _showWon(BuildContext context, GameState state) {
    final next = GameLevels.after(state.level);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => AlertDialog(
        title: const Text('Solved!'),
        content: Text(
          'You finished ${state.level.title} in ${formatClock(state.elapsed)}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialog).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Levels'),
          ),
          if (next != null)
            FilledButton(
              onPressed: () {
                Navigator.of(dialog).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => GameScreen(levelNumber: next.number),
                  ),
                );
              },
              child: Text('Next: ${next.title}'),
            ),
        ],
      ),
    );
  }

  void _showLost(BuildContext context, GameNotifier game) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => AlertDialog(
        title: const Text('Game over'),
        content: const Text('You reached the mistake limit.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialog).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Levels'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialog).pop();
              game.restart();
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// INFO BAR — MISTAKES · DIFFICULTY · CLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////
class _InfoBar extends StatelessWidget {
  const _InfoBar({required this.state, required this.onPause});

  final GameState state;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextWidget(
          'Mistakes: ${state.mistakes}/${state.level.maxMistakes}',
          color: AppColors.textMuted,
        ),
      ),
      TextWidget(state.level.difficulty, color: AppColors.textMuted),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextWidget(formatClock(state.elapsed), color: AppColors.textMuted),
            const SizedBox(width: 4),
            InkWell(
              onTap: onPause,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  state.paused ? Icons.play_arrow : Icons.pause,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// BOARD AREA — THE BOARD, COVERED WHILE PAUSED
///////////////////////////////////////////////////////////////////////////////////////////////////
class _BoardArea extends StatelessWidget {
  const _BoardArea({required this.state, required this.game});

  final GameState state;
  final GameNotifier game;

  @override
  Widget build(BuildContext context) {
    if (!state.paused) {
      return SudokuBoardWidget(state: state, onTap: game.select);
    }
    return AspectRatio(
      aspectRatio: state.layout.columns / state.layout.rows,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: game.togglePause,
          child: const Center(
            child: Icon(
              Icons.play_circle_fill,
              size: 72,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// ACTIONS ROW
///////////////////////////////////////////////////////////////////////////////////////////////////
class _Actions extends StatelessWidget {
  const _Actions({required this.state, required this.game});

  final GameState state;
  final GameNotifier game;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      GameActionButton(icon: Icons.undo, label: 'Undo', onTap: game.undo),
      GameActionButton(
        icon: Icons.backspace_outlined,
        label: 'Erase',
        onTap: game.erase,
      ),
      GameActionButton(
        icon: Icons.edit_outlined,
        label: state.noteMode ? 'Note: on' : 'Note',
        active: state.noteMode,
        onTap: game.toggleNoteMode,
      ),
      GameActionButton(
        icon: Icons.lightbulb_outline,
        label: 'Hint',
        badge: state.hintsLeft > 0 ? '${state.hintsLeft}' : null,
        onTap: state.hintsLeft > 0 ? game.hint : null,
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: buttons[i]),
        ],
      ],
    );
  }
}
