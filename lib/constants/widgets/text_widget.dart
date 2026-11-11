import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// TEXT WIDGET
///////////////////////////////////////////////////////////////////////////////////////////////////
class TextWidget extends StatelessWidget {
  const TextWidget(
    this.text, {
    super.key,
    this.size = 14,
    this.weight = FontWeight.w400,
    this.color = AppColors.textPrimary,
    this.align,
  });

  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    style: TextStyle(fontSize: size, fontWeight: weight, color: color),
  );
}
