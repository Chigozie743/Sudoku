import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// PROGRESS LOCAL SOURCE IMPLEMENTATION
///////////////////////////////////////////////////////////////////////////////////////////////////
class ProgressLocalSourceImpl implements ProgressLocalSourceAbstract {
  ProgressLocalSourceImpl(this.store);

  final LocalStore store;

  @override
  int get unlockedLevel => store.unlockedLevel;

  @override
  Future<void> saveUnlockedLevel(int level) => store.setUnlockedLevel(level);

  @override
  int? bestSeconds(int level) => store.bestSeconds(level);

  @override
  Future<void> saveBestSeconds(int level, int seconds) =>
      store.setBestSeconds(level, seconds);
}
