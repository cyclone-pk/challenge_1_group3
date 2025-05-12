import 'package:challenge1_group3/models/board_column_model.dart';
import 'package:challenge1_group3/models/board_model.dart';
import 'package:challenge1_group3/models/task_card_model.dart';
import 'package:challenge1_group3/provider/board_provider.dart';
import 'package:challenge1_group3/ui/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BoardPage extends StatefulWidget {
  final BoardModel board;

  const BoardPage({super.key, required this.board});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  String _searchQuery = '';

  State<BoardPage> createState() => _BoardPageState();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoardProvider>(context);
    final columns = provider.getColumns(widget.board.id);
    if (columns.isEmpty) {
      provider.addColumn(
          widget.board.id, BoardColumnModel(id: 'todo', title: 'To Do'));
      provider.addColumn(
          widget.board.id, BoardColumnModel(id: 'doing', title: 'Doing'));
      provider.addColumn(
          widget.board.id, BoardColumnModel(id: 'done', title: 'Done'));
    }

    final updatedColumns = provider.getColumns(widget.board.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search by keyword',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        children: [
          ...updatedColumns.map((column) {
            return _buildColumn(context, provider, column);
          }),
          _buildAddColumnButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildColumn(
      BuildContext context, BoardProvider provider, BoardColumnModel column) {
    final filteredCards = _searchQuery.isEmpty
        ? column.cards
        : column.cards.where((card) {
            return card.title.toLowerCase().contains(_searchQuery) ||
                (card.description.toLowerCase() ?? '').contains(_searchQuery);
          }).toList();

    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (receivedTask) {
        setState(() {
          provider.moveCard(
            boardId: widget.board.id,
            fromColumnId: receivedTask.data['columnId'],
            toColumnId: column.id,
            task: receivedTask.data['task'],
          );
        });
      },
      builder:
          (BuildContext context, candidateData, List<dynamic> rejectedData) {
        return Container(
          width: 260,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(column.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Divider(
                height: 1,
              ),
              SizedBox(height: 8),
              if (candidateData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.task_outlined),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          "Release To Move Task Here",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ...filteredCards.map((task) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TaskTile(
                        task: task,
                        data: {"task": task, "columnId": column.id},
                        showDetail: () {
                          showEditCardDialog(
                            context: context,
                            provider: provider,
                            boardId: widget.board.id,
                            columnId: column.id,
                            card: task,
                          );
                        },
                        onComplete: () {
                          provider.toggleCardDone(
                              widget.board.id, column.id, task.id);
                        }),
                  )),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => _addTask(context, provider, column.id),
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            "Add New Card",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddColumnButton(BuildContext context, BoardProvider provider) {
    final nameController = TextEditingController();
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('New Column'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Column name'),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final newCol = BoardColumnModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: name,
                      cards: [],
                    );
                    provider.addColumn(widget.board.id, newCol);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: const Center(child: Icon(Icons.add, size: 30)),
      ),
    );
  }

  void _addTask(BuildContext context, BoardProvider provider, String columnId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        title: const Text('New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  hintText: 'Task title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                  hintText: 'Instruction / Description',
                  border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          MaterialButton(
            color: Colors.green,
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              if (title.isNotEmpty) {
                final card = TaskCardModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  description: description,
                  isDone: false,
                  createdAt: DateTime.now(),
                );
                provider.addCard(widget.board.id, columnId, card);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void showEditCardDialog({
    required BuildContext context,
    required BoardProvider provider,
    required String boardId,
    required String columnId,
    required TaskCardModel card,
  }) {
    final titleController = TextEditingController(text: card.title);
    final descController = TextEditingController(text: card.description ?? '');
    bool isDone = card.isDone;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: isDone,
                        onChanged: (val) {
                          setState(() {
                            isDone = val ?? false;
                          });
                        },
                      ),
                      const Text('Completed'),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedCard = TaskCardModel(
                      id: card.id,
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      isDone: isDone,
                      createdAt: DateTime.now(),
                    );
                    provider.updateCard(boardId, columnId, updatedCard);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
