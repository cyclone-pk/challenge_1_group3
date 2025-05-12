import 'package:challenge1_group3/models/board_model.dart';
import 'package:challenge1_group3/provider/board_provider.dart';
import 'package:challenge1_group3/ui/pages/board_page.dart';
import 'package:challenge1_group3/ui/widgets/board_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final boardProvider = Provider.of<BoardProvider>(context);
    final boards = boardProvider.boards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boards'),
      ),
      body: boards.isEmpty
          ? const Center(child: Text('No boards found. Add one!'))
          : ListView.builder(
              itemCount: boards.length,
              itemBuilder: (context, index) {
                final board = boards[index];
                return BoardTile(
                  board: board,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BoardPage(board: board)));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateBoardDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateBoardDialog(BuildContext context) {
    final nameController = TextEditingController();
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              backgroundColor: Colors.white,
              title: const Text('Create Board'),
              content: Form(
                key: _formKey,
                child: TextFormField(
                  validator: (v) {
                    if (v!.isEmpty) return "Please enter board name";
                    return null;
                  },
                  controller: nameController,
                  decoration: const InputDecoration(
                      hintText: 'Board name', border: OutlineInputBorder()),
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                MaterialButton(
                  color: Colors.green,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final id =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      final board = BoardModel(
                        id: id,
                        name: name,
                        createdAt: DateTime.now(),
                      );
                      Provider.of<BoardProvider>(context, listen: false)
                          .addBoard(board);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ));
  }
}
