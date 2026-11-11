import 'package:sudoku/constants/utils/export_file.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////
/// SUDOKU BOARD — CELLS, HIGHLIGHTS AND TILE LINES FOR ANY LAYOUT
///////////////////////////////////////////////////////////////////////////////////////////////////
class SudokuBoardWidget extends StatelessWidget {
  const SudokuBoardWidget({
    super.key,
    required this.state,
    required this.onTap,
  });

  final GameState state;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final layout = state.layout;
    return AspectRatio(
      aspectRatio: layout.columns / layout.rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / layout.columns;
          return Stack(
            children: [
              Column(
                children: [
                  for (var row = 0; row < layout.rows; row++)
                    Expanded(
                      child: Row(
                        children: [
                          for (
                            var column = 0;
                            column < layout.columns;
                            column++
                          )
                            Expanded(
                              child: _Cell(
                                state: state,
                                index: row * layout.columns + column,
                                size: cellSize,
                                onTap: onTap,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: BoardLinesPainter(layout)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// ONE CELL
///////////////////////////////////////////////////////////////////////////////////////////////////
class _Cell extends StatelessWidget {
  const _Cell({
    required this.state,
    required this.index,
    required this.size,
    required this.onTap,
  });

  final GameState state;
  final int index;
  final double size;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final value = state.values[index];
    final wrong = state.wrong.contains(index);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: ColoredBox(
        color: _background(),
        child: Center(
          child: value != 0
              ? Text(
                  '$value',
                  style: TextStyle(
                    fontSize: size * 0.55,
                    color: wrong
                        ? AppColors.wrong
                        : state.isGiven(index)
                        ? AppColors.given
                        : AppColors.entered,
                  ),
                )
              : _Notes(
                  notes: state.notes[index],
                  layout: state.layout,
                  size: size,
                ),
        ),
      ),
    );
  }

  Color _background() {
    final selected = state.selected;
    if (selected == null) return AppColors.background;
    if (selected == index) return AppColors.cellSelected;
    if (state.wrong.contains(index)) return AppColors.cellError;
    final selectedValue = state.selectedValue;
    if (selectedValue != null && state.values[index] == selectedValue) {
      return AppColors.cellSameValue;
    }
    final layout = state.layout;
    final sameLine =
        layout.rowOf(index) == layout.rowOf(selected) ||
        layout.columnOf(index) == layout.columnOf(selected);
    // On a single tile every cell shares the tile, so only light up the row and column.
    final singleTile = layout.boxesAcross * layout.boxesDown == 1;
    final sameTile =
        !singleTile && layout.boxOf(index) == layout.boxOf(selected);
    return sameLine || sameTile ? AppColors.cellRelated : AppColors.background;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// PENCIL NOTES — A MINI GRID SHAPED LIKE ONE TILE
///////////////////////////////////////////////////////////////////////////////////////////////////
class _Notes extends StatelessWidget {
  const _Notes({required this.notes, required this.layout, required this.size});

  final Set<int> notes;
  final BoardLayout layout;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.all(size * 0.06),
      child: Column(
        children: [
          for (var row = 0; row < layout.boxHeight; row++)
            Expanded(
              child: Row(
                children: [
                  for (var column = 0; column < layout.boxWidth; column++)
                    Expanded(
                      child: Center(
                        child: Builder(
                          builder: (context) {
                            final digit = row * layout.boxWidth + column + 1;
                            return Text(
                              notes.contains(digit) ? '$digit' : '',
                              style: TextStyle(
                                fontSize: size / (layout.boxHeight + 1) * 0.8,
                                color: AppColors.note,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// BOARD LINES — THIN BETWEEN CELLS, THICK AROUND EACH TILE
///////////////////////////////////////////////////////////////////////////////////////////////////
class BoardLinesPainter extends CustomPainter {
  const BoardLinesPainter(this.layout);

  final BoardLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = AppColors.cellBorder
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = AppColors.boxBorder
      ..strokeWidth = 2;
    final cellWidth = size.width / layout.columns;
    final cellHeight = size.height / layout.rows;

    for (var column = 1; column < layout.columns; column++) {
      final x = column * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        column % layout.boxWidth == 0 ? thick : thin,
      );
    }
    for (var row = 1; row < layout.rows; row++) {
      final y = row * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        row % layout.boxHeight == 0 ? thick : thin,
      );
    }
    canvas.drawRect(Offset.zero & size, thick..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(BoardLinesPainter oldDelegate) =>
      oldDelegate.layout != layout;
}
