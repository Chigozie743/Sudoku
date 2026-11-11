///////////////////////////////////////////////////////////////////////////////////////////////////
/// GAME MOVE — WHAT A CELL HELD BEFORE A CHANGE, SO UNDO CAN RESTORE IT
///////////////////////////////////////////////////////////////////////////////////////////////////
class GameMove {
  const GameMove({
    required this.index,
    required this.value,
    required this.notes,
    required this.wasWrong,
  });

  final int index;
  final int value;
  final Set<int> notes;
  final bool wasWrong;
}
