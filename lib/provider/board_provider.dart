import 'package:challenge1_group3/models/board_column_model.dart';
import 'package:challenge1_group3/models/board_model.dart';
import 'package:challenge1_group3/models/task_card_model.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class BoardProvider with ChangeNotifier {
  List<BoardModel> boards = [];
  Map<String, List<BoardColumnModel>> columnsMap = {};

  void addBoard(BoardModel board) {
    boards.add(board);
    columnsMap[board.id] = [
      BoardColumnModel(id: 'todo', title: 'To Do', cards: []),
      BoardColumnModel(id: 'doing', title: 'Doing', cards: []),
      BoardColumnModel(id: 'done', title: 'Done', cards: []),
    ];

    notifyListeners();
  }

  void removeBoard(String boardId) {
    boards.removeWhere((b) => b.id == boardId);
    columnsMap.remove(boardId);
    notifyListeners();
  }

  BoardModel? getBoardById(String id) => boards.firstWhere((b) => b.id == id);

  void addColumn(String boardId, BoardColumnModel column) {
    final columns = columnsMap[boardId];
    if (columns != null) {
      columns.add(column);
      notifyListeners();
    }
  }

  void removeColumn(String boardId, String columnId) {
    final columns = columnsMap[boardId];
    if (columns != null) {
      columns.removeWhere((c) => c.id == columnId);
      notifyListeners();
    }
  }

  List<BoardColumnModel> getColumns(String boardId) =>
      columnsMap[boardId] ?? [];

  void addCard(String boardId, String columnId, TaskCardModel card) {
    final column = _getColumn(boardId, columnId);
    column?.cards.add(card);
    notifyListeners();
  }

  void removeCard(String boardId, String columnId, String cardId) {
    final column = _getColumn(boardId, columnId);
    column?.cards.removeWhere((c) => c.id == cardId);
    notifyListeners();
  }

  void moveCard({
    required String boardId,
    required String fromColumnId,
    required String toColumnId,
    required TaskCardModel card,
    required int toIndex,
  }) {
    final fromColumn = _getColumn(boardId, fromColumnId);
    final toColumn = _getColumn(boardId, toColumnId);

    if (fromColumn != null && toColumn != null) {
      fromColumn.cards.removeWhere((c) => c.id == card.id);
      toColumn.cards.insert(toIndex, card);
      notifyListeners();
    }
  }

  BoardColumnModel? _getColumn(String boardId, String columnId) {
    final columns = columnsMap[boardId];
    if (columns == null) return null;
    return columns.firstWhere((c) => c.id == columnId);
  }
}
