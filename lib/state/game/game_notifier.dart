import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME NOTIFIER
///////////////////////////////////////////////////////////////////////////////////////////////////
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(this.repository, GameLevel level, {this.onWin})
    : super(GameState.start(level, repository.newPuzzle(level))) {
    _startClock();
  }

  final GameRepositoryAbstract repository;
  final Future<void> Function(GameLevel level, Duration time)? onWin;
  Timer? _clock;

  SudokuSolver get _solver => SudokuSolver(state.layout);

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// CLOCK
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void _startClock() {
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPlaying) {
        state = state.copyWith(
          elapsed: state.elapsed + const Duration(seconds: 1),
        );
      }
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// SELECT A CELL
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void select(int index) {
    if (!state.isPlaying) return;
    state = state.copyWith(selected: () => index);
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// TOGGLES
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void toggleNoteMode() => state = state.copyWith(noteMode: !state.noteMode);

  void togglePause() {
    if (state.status != GameStatus.playing) return;
    state = state.copyWith(paused: !state.paused);
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// NEW BOARD FOR THE SAME LEVEL
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void restart() {
    state = GameState.start(state.level, repository.newPuzzle(state.level));
    _startClock();
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// ENTER A DIGIT — OR TOGGLE IT AS A NOTE IN NOTE MODE
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void input(int digit) {
    final index = state.selected;
    if (!state.isPlaying || index == null || state.isGiven(index)) return;

    if (state.noteMode) {
      if (state.values[index] != 0) return;
      final notes = Set<int>.of(state.notes[index]);
      notes.contains(digit) ? notes.remove(digit) : notes.add(digit);
      _apply(index, value: 0, notes: notes, wrong: false);
      return;
    }

    if (state.values[index] == digit) return;
    final correct = _isCorrect(index, digit);
    _apply(index, value: digit, notes: const {}, wrong: !correct);

    if (!correct) {
      final mistakes = state.mistakes + 1;
      state = state.copyWith(
        mistakes: mistakes,
        status: mistakes >= state.level.maxMistakes ? GameStatus.lost : null,
      );
      return;
    }
    _clearNotesAround(index, digit);
    _checkWin();
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// ERASE THE SELECTED CELL
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void erase() {
    final index = state.selected;
    if (!state.isPlaying || index == null || state.isGiven(index)) return;
    if (state.values[index] == 0 && state.notes[index].isEmpty) return;
    _apply(index, value: 0, notes: const {}, wrong: false);
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// UNDO THE LAST CHANGE
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void undo() {
    if (!state.isPlaying || state.history.isEmpty) return;
    final move = state.history.last;
    final values = List<int>.of(state.values)..[move.index] = move.value;
    final notes = List<Set<int>>.of(state.notes)..[move.index] = move.notes;
    final wrong = Set<int>.of(state.wrong);
    move.wasWrong ? wrong.add(move.index) : wrong.remove(move.index);
    state = state.copyWith(
      values: values,
      notes: notes,
      wrong: wrong,
      selected: () => move.index,
      history: state.history.sublist(0, state.history.length - 1),
    );
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// HINT — FILL THE SELECTED CELL (OR THE FIRST OPEN ONE) WITH A DIGIT THAT STILL SOLVES
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void hint() {
    if (!state.isPlaying || state.hintsLeft <= 0) return;
    final solution = _solver.solve(_correctBoard());
    if (solution == null) return;

    bool open(int i) =>
        !state.isGiven(i) && (state.values[i] == 0 || state.wrong.contains(i));
    final selected = state.selected;
    final index = selected != null && open(selected)
        ? selected
        : List<int>.generate(
            state.values.length,
            (i) => i,
          ).where(open).firstOrNull;
    if (index == null) return;

    _apply(index, value: solution[index], notes: const {}, wrong: false);
    state = state.copyWith(
      selected: () => index,
      hintsLeft: state.hintsLeft - 1,
    );
    _clearNotesAround(index, solution[index]);
    _checkWin();
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// HELPERS
  ///////////////////////////////////////////////////////////////////////////////////////////////////

  /// Write one cell and remember what it held so undo can put it back.
  void _apply(
    int index, {
    required int value,
    required Set<int> notes,
    required bool wrong,
  }) {
    final move = GameMove(
      index: index,
      value: state.values[index],
      notes: state.notes[index],
      wasWrong: state.wrong.contains(index),
    );
    final wrongCells = Set<int>.of(state.wrong);
    wrong ? wrongCells.add(index) : wrongCells.remove(index);
    state = state.copyWith(
      values: List<int>.of(state.values)..[index] = value,
      notes: List<Set<int>>.of(state.notes)..[index] = notes,
      wrong: wrongCells,
      history: [...state.history, move],
    );
  }

  /// The board without any wrong entries.
  List<int> _correctBoard() => [
    for (var i = 0; i < state.values.length; i++)
      state.wrong.contains(i) ? 0 : state.values[i],
  ];

  /// A digit is correct when it breaks no rule and the board can still be finished with it.
  /// Checking against "can still be finished" rather than one stored answer means a lone
  /// 3×3 tile, which has many valid fillings, accepts any of them.
  bool _isCorrect(int index, int digit) {
    final board = _correctBoard()..[index] = 0;
    if (!_solver.fits(board, index, digit)) return false;
    board[index] = digit;
    return _solver.countSolutions(board, limit: 1) > 0;
  }

  /// A placed digit can no longer be a note anywhere it would clash.
  void _clearNotesAround(int index, int digit) {
    final notes = List<Set<int>>.of(state.notes);
    var changed = false;
    for (final peer in state.layout.peersOf(index)) {
      if (notes[peer].contains(digit)) {
        notes[peer] = Set<int>.of(notes[peer])..remove(digit);
        changed = true;
      }
    }
    if (changed) state = state.copyWith(notes: notes);
  }

  void _checkWin() {
    if (state.wrong.isNotEmpty || state.values.contains(0)) return;
    state = state.copyWith(status: GameStatus.won, selected: () => null);
    _clock?.cancel();
    unawaited(onWin?.call(state.level, state.elapsed));
  }
}
