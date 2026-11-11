import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME ACTION BUTTON — UNDO / ERASE / NOTE / HINT
///////////////////////////////////////////////////////////////////////////////////////////////////
class GameActionButton extends StatelessWidget {
  const GameActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? badge;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textPrimary;
    return Material(
      color: active ? AppColors.cellSameValue : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badge != null,
                label: Text(badge ?? ''),
                backgroundColor: AppColors.badge,
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 6),
              TextWidget(label, size: 13, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
