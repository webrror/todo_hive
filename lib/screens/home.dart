import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mitch_todo/utils/customColor.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = []; // TO STORE ITEMS FROM THE HIVE DB

  final _todos = Hive.box('Todos');
  TextEditingController todo = TextEditingController();

  void _refreshItems() {
    final data = _todos.keys.map((index) {
      final value = _todos.get(index);
      return {"key": index, "todo": value["todo"], "isDone": value["isDone"]};
    }).toList();
    setState(() {
      _items = data.reversed.toList();
    });
  }

  // Create new item
  Future<void> _createTodo(Map<String, dynamic> newItem) async {
    await _todos.add(newItem);
    _refreshItems(); // update the UI
  }

  // Update item
  Future<void> _updateTodo(int key, Map<String, dynamic> newItem) async {
    await _todos.put(key, newItem);
    _refreshItems(); // update the UI
  }

  // Delete item
  Future<void> _deleteTodo(int key) async {
    await _todos.delete(key);
    _refreshItems(); // update the UI
  }

  showFormSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      isScrollControlled: true,
      elevation: 2,
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.green[100],
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Todo',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        padding: EdgeInsets.zero,
                        width: 30,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(FluentIcons.dismiss_20_filled),
                          padding: EdgeInsets.zero,
                          //constraints: const BoxConstraints(),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: todo,
                    minLines: 3,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    cursorColor: Colors.green,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.green)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black))),
                    textInputAction: TextInputAction.done),
                const SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                          elevation: 2,
                          backgroundColor: MaterialColor(0xFFB9E2BA, color),
                          // foregroundColor:
                          //     Theme.of(context).primaryIconTheme.color,
                          minimumSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        if (todo.text.isNotEmpty) {
                          _createTodo({"todo": todo.text, "isDone": false})
                              .then((value) => Fluttertoast.showToast(
                                  msg: 'Added successfully',
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM));

                          todo.text = '';
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Empty field',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM);
                        }
                      },
                      child: const Text('Create'
                          //style: TextStyle(color: Theme.of(context).textTheme.headlineSmall!.color),
                          ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TODO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[200],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text("No Data"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final currentItem = _items[index];
                return SwipeableTile.card(
                  key: UniqueKey(),
                  borderRadius: 8,
                  swipeThreshold: 0.99,
                  color: const Color.fromARGB(255, 174, 219, 175),
                  backgroundBuilder: (context, direction, progress) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 2),
                      child: Container(
                        padding: const EdgeInsets.only(right: 30),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              FluentIcons.delete_20_regular,
                              color: Colors.white,
                            )),
                      ),
                    );
                  },
                  onSwiped: (direction) {
                    _deleteTodo(currentItem["key"]).then((value) =>
                        Fluttertoast.showToast(
                            msg: 'Removed',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM));
                  },
                  horizontalPadding: 1,
                  verticalPadding: 5,
                  shadow: BoxShadow(
                      color: Colors.black.withOpacity(0.0),
                      blurRadius: 1,
                      offset: const Offset(1, 1)),
                  direction: SwipeDirection.endToStart,
                  child: CheckboxListTile(
                    value: currentItem["isDone"],
                    checkColor: Colors.green[200],
                    activeColor: Colors.black87,
                    onChanged: (value) {
                      _updateTodo(currentItem["key"],
                          {"todo": currentItem["todo"], "isDone": value});

                      if (!currentItem["isDone"]) {
                        Fluttertoast.showToast(
                            msg: 'You did it!',
                            //backgroundColor: Colors.green[300],
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM);
                      }
                    },
                    title: Text(
                      currentItem["todo"],
                      style: TextStyle(
                          decoration: currentItem["isDone"]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none),
                    ),
                    checkboxShape: const CircleBorder(),
                  ),
                );
              },
              itemCount: _items.length,
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MaterialColor(0xFFB9E2BA, color),
        onPressed: () {
          showFormSheet(context);
        },
        shape: const CircleBorder(),
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }
}
