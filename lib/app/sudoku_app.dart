import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// SUDOKU APP
///////////////////////////////////////////////////////////////////////////////////////////////////
class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sudoku',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const LevelSelectScreen(),
  );
}
