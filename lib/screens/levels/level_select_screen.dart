import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// LEVEL SELECT SCREEN
///////////////////////////////////////////////////////////////////////////////////////////////////
class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget('Sudoku', size: 22, weight: FontWeight.w600),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: GameLevels.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final level = GameLevels.all[i];
          return _LevelCard(
            level: level,
            unlocked: progress.isUnlocked(level.number),
            best: progress.bestTime(level.number),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GameScreen(levelNumber: level.number),
              ),
            ),
          );
        },
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// LEVEL CARD
///////////////////////////////////////////////////////////////////////////////////////////////////
class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.unlocked,
    required this.best,
    required this.onTap,
  });

  final GameLevel level;
  final bool unlocked;
  final Duration? best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final layout = level.layout;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: unlocked ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: AspectRatio(
                  aspectRatio: layout.columns / layout.rows,
                  child: ColoredBox(
                    color: AppColors.background,
                    child: CustomPaint(painter: BoardLinesPainter(layout)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      level.title,
                      size: 18,
                      weight: FontWeight.w600,
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.locked,
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      '${layout.label} · digits 1–${layout.digits}',
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 2),
                    TextWidget(
                      best == null
                          ? level.difficulty
                          : '${level.difficulty} · best ${formatClock(best!)}',
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              Icon(
                unlocked ? Icons.play_circle_fill : Icons.lock_outline,
                size: 32,
                color: unlocked ? AppColors.primary : AppColors.locked,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
