import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// PROGRESS LOCAL SOURCE CONTRACT — UNLOCKED LEVELS AND BEST TIMES
///////////////////////////////////////////////////////////////////////////////////////////////////
abstract class ProgressLocalSourceAbstract {
  int get unlockedLevel;
  Future<void> saveUnlockedLevel(int level);

  int? bestSeconds(int level);
  Future<void> saveBestSeconds(int level, int seconds);
}
