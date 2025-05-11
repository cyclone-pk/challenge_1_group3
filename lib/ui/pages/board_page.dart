import 'package:challenge1_group3/models/board_column_model.dart';
import 'package:challenge1_group3/models/task_card_model.dart';
import 'package:challenge1_group3/provider/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class BoardPage extends StatefulWidget {
  final String boardId;

  const BoardPage({super.key, required this.boardId});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>  {
  String _searchQuery = '';

  @override
  State<BoardPage> createState() => _BoardPageState();
  Widget build(BuildContext context) {
    final provider = Provider.of<BoardProvider>(context);
    final columns = provider.getColumns(widget.boardId);

    // Initialize default columns if none exist
    if (columns.isEmpty) {
      provider.addColumn(widget.boardId, BoardColumnModel(id: 'todo', title: 'To Do'));
      provider.addColumn(
          widget.boardId, BoardColumnModel(id: 'doing', title: 'Doing'));
      provider.addColumn(widget.boardId, BoardColumnModel(id: 'done', title: 'Done'));
    }

    final updatedColumns = provider.getColumns(widget.boardId);

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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ...updatedColumns.map((column) {
              return _buildColumn(context, provider, column);
            }),
            _buildAddColumnButton(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, BoardProvider provider, BoardColumnModel column) {
    final filteredCards = _searchQuery.isEmpty
        ? column.cards
        : column.cards.where((card) {
      return card.title.toLowerCase().contains(_searchQuery) ||
          (card.description?.toLowerCase() ?? '').contains(_searchQuery);
    }).toList();

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(column.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...filteredCards.map((card) => Card(
            child: ListTile(
              leading: Checkbox(
                value: card.isDone,
                onChanged: (_) {
                  provider.toggleCardDone(widget.boardId, column.id, card.id);
                },
              ),
              title: Text(
                card.title,
                style: TextStyle(
                  decoration: card.isDone ? TextDecoration.lineThrough : null,
                  color: card.isDone ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                card.description,
                style: TextStyle(
                  color: card.isDone ? Colors.grey : Colors.black54,
                ),
              ),
              onTap: () {
                showEditCardDialog(
                  context: context,
                  provider: provider,
                  boardId: widget.boardId,
                  columnId: column.id,
                  card: card,
                );
              },
            ),
          )),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _addTask(context, provider, column.id),
            icon: const Icon(Icons.add),
            label: const Text('Add Card'),
          ),
        ],
      ),
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
                    provider.addColumn(widget.boardId, newCol);
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
        title: const Text('New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Task title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Instruction / Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              if (title.isNotEmpty) {
                final card = TaskCardModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  description: description,
                  isDone: false,
                );
                provider.addCard(widget.boardId, columnId, card);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
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