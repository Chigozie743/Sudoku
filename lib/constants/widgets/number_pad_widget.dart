import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// NUMBER PAD — ONE BUTTON PER DIGIT IN THE LEVEL
///////////////////////////////////////////////////////////////////////////////////////////////////
class NumberPadWidget extends StatelessWidget {
  const NumberPadWidget({
    super.key,
    required this.digits,
    required this.onDigit,
    this.isDone,
  });

  final int digits;
  final ValueChanged<int> onDigit;

  /// Digits already placed everywhere they can go are dimmed.
  final bool Function(int digit)? isDone;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var digit = 1; digit <= digits; digit++)
        Expanded(
          child: AspectRatio(
            aspectRatio: digits <= 4 ? 1.6 : 0.8,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onDigit(digit),
              child: Center(
                child: FittedBox(
                  child: TextWidget(
                    '$digit',
                    size: 40,
                    color: (isDone?.call(digit) ?? false)
                        ? AppColors.locked
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
