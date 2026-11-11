import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// HELPERS
///////////////////////////////////////////////////////////////////////////////////////////////////
Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [localStoreProvider.overrideWithValue(LocalStore(preferences))],
  );
}

bool _validBoard(BoardLayout layout, List<int> board) {
  for (var i = 0; i < board.length; i++) {
    if (board[i] < 1 || board[i] > layout.digits) return false;
    for (final peer in layout.peersOf(i)) {
      if (board[peer] == board[i]) return false;
    }
  }
  return true;
}

void main() {
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// GENERATOR
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  for (final level in GameLevels.all) {
    test(
      '${level.title} puzzles have ${level.clues} clues and can be solved',
      () {
        final source = PuzzleSourceImpl(random: Random(level.number));
        for (var run = 0; run < 25; run++) {
          final puzzle = source.generate(level);
          final solver = SudokuSolver(level.layout);
          expect(puzzle.clues.where((v) => v != 0).length, level.clues);
          final solution = solver.solve(puzzle.clues);
          expect(solution, isNotNull);
          expect(_validBoard(level.layout, solution!), isTrue);
          if (level.layout.supportsUniqueSolution) {
            expect(solver.countSolutions(puzzle.clues), 1);
          }
        }
      },
    );
  }

  test('classic 9×9 layout also generates', () {
    const level = GameLevel(
      number: 99,
      difficulty: 'Hard',
      layout: BoardLayout(
        boxesAcross: 3,
        boxesDown: 3,
        boxWidth: 3,
        boxHeight: 3,
      ),
      clues: 30,
    );
    final puzzle = PuzzleSourceImpl(random: Random(9)).generate(level);
    expect(SudokuSolver(level.layout).countSolutions(puzzle.clues), 1);
  });

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// GAME RULES
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  test(
    'wrong digit counts a mistake, undo restores, solving unlocks level 2',
    () async {
      final container = await _container();
      addTearDown(container.dispose);
      final provider = gameProvider(1);
      final sub = container.listen(provider, (_, _) {});
      final game = container.read(provider.notifier);
      var state = container.read(provider);

      final empty = List.generate(
        9,
        (i) => i,
      ).where((i) => !state.isGiven(i)).toList();
      final clash = state.values.firstWhere((v) => v != 0);

      game.select(empty.first);
      game.input(clash);
      state = container.read(provider);
      expect(state.mistakes, 1);
      expect(state.wrong, contains(empty.first));

      game.undo();
      state = container.read(provider);
      expect(state.values[empty.first], 0);
      expect(state.wrong, isEmpty);

      // A lone tile accepts any order of the missing digits.
      final missing = [
        for (var d = 1; d <= 9; d++)
          if (!state.values.contains(d)) d,
      ].reversed.toList();
      for (var i = 0; i < empty.length; i++) {
        game.select(empty[i]);
        game.input(missing[i]);
      }
      state = container.read(provider);
      expect(state.status, GameStatus.won);
      expect(state.mistakes, 1);

      await Future<void>.delayed(Duration.zero);
      expect(container.read(progressProvider).isUnlocked(2), isTrue);
      sub.close();
    },
  );

  test('three mistakes ends the game; hint fills a correct digit', () async {
    final container = await _container();
    addTearDown(container.dispose);
    final provider = gameProvider(2);
    final sub = container.listen(provider, (_, _) {});
    final game = container.read(provider.notifier);
    var state = container.read(provider);
    final solution = SudokuSolver(state.layout).solve(state.puzzle.clues)!;
    final open = List.generate(
      16,
      (i) => i,
    ).where((i) => !state.isGiven(i)).toList();

    game.hint();
    state = container.read(provider);
    expect(state.hintsLeft, 0);
    final hinted = open.firstWhere((i) => state.values[i] != 0);
    expect(state.values[hinted], solution[hinted]);

    final target = open.firstWhere((i) => i != hinted);
    final wrongDigits = [
      for (var d = 1; d <= 4; d++)
        if (d != solution[target]) d,
    ];
    game.select(target);
    for (final d in wrongDigits) {
      game.input(d);
    }
    expect(container.read(provider).status, GameStatus.lost);
    sub.close();
  });
}
