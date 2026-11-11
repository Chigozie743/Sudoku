import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// ENTRY POINT
///////////////////////////////////////////////////////////////////////////////////////////////////
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(LocalStore(preferences)),
      ],
      child: const SudokuApp(),
    ),
  );
}
