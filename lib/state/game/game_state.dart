import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME STATUS
///////////////////////////////////////////////////////////////////////////////////////////////////
enum GameStatus { playing, won, lost }

///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME STATE
///////////////////////////////////////////////////////////////////////////////////////////////////
class GameState {
  const GameState({
    required this.level,
    required this.puzzle,
    required this.values,
    required this.notes,
    required this.wrong,
    required this.selected,
    required this.noteMode,
    required this.mistakes,
    required this.hintsLeft,
    required this.elapsed,
    required this.paused,
    required this.status,
    required this.history,
  });

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// A FRESH GAME FOR THE PUZZLE
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  factory GameState.start(GameLevel level, SudokuPuzzle puzzle) => GameState(
    level: level,
    puzzle: puzzle,
    values: List<int>.of(puzzle.clues),
    notes: List.generate(puzzle.clues.length, (_) => const <int>{}),
    wrong: const {},
    selected: null,
    noteMode: false,
    mistakes: 0,
    hintsLeft: level.hints,
    elapsed: Duration.zero,
    paused: false,
    status: GameStatus.playing,
    history: const [],
  );

  final GameLevel level;
  final SudokuPuzzle puzzle;
  final List<int> values;
  final List<Set<int>> notes;
  final Set<int> wrong;
  final int? selected;
  final bool noteMode;
  final int mistakes;
  final int hintsLeft;
  final Duration elapsed;
  final bool paused;
  final GameStatus status;
  final List<GameMove> history;

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// DERIVED
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  BoardLayout get layout => puzzle.layout;
  bool get isPlaying => status == GameStatus.playing && !paused;
  bool isGiven(int index) => puzzle.isGiven(index);
  int? get selectedValue =>
      selected == null || values[selected!] == 0 ? null : values[selected!];

  /// How many times [digit] sits correctly on the board — the pad dims it once all are placed.
  int placedCount(int digit) {
    var count = 0;
    for (var i = 0; i < values.length; i++) {
      if (values[i] == digit && !wrong.contains(i)) count++;
    }
    return count;
  }

  /// Every cell holds a digit at most once per row, so a digit can appear at most this often.
  int get maxPerDigit => layout.cellCount ~/ layout.digits;

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// COPY WITH
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  GameState copyWith({
    List<int>? values,
    List<Set<int>>? notes,
    Set<int>? wrong,
    int? Function()? selected,
    bool? noteMode,
    int? mistakes,
    int? hintsLeft,
    Duration? elapsed,
    bool? paused,
    GameStatus? status,
    List<GameMove>? history,
  }) => GameState(
    level: level,
    puzzle: puzzle,
    values: values ?? this.values,
    notes: notes ?? this.notes,
    wrong: wrong ?? this.wrong,
    selected: selected == null ? this.selected : selected(),
    noteMode: noteMode ?? this.noteMode,
    mistakes: mistakes ?? this.mistakes,
    hintsLeft: hintsLeft ?? this.hintsLeft,
    elapsed: elapsed ?? this.elapsed,
    paused: paused ?? this.paused,
    status: status ?? this.status,
    history: history ?? this.history,
  );
}
