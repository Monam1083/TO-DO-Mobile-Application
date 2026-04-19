import 'package:flutter/material.dart';
import 'package:to_do_app/todo_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TodoPage(),
      ),
    ),
  );
}

// 1. DATA MODEL & ENUM
enum Todopriority { low, normal, high }

class MyTodo {
  String name;
  int id;
  bool completed;
  Todopriority priority;

  MyTodo({
    required this.name,
    required this.id,
    this.completed = false,
    required this.priority,
  });

  // This is where we store the list in memory
  static List<MyTodo> todos = [];
}

// 2. MAIN PAGE
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _controller = TextEditingController();
  Todopriority priority = Todopriority.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => addTodo(),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("MY TODOS", style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.todo.isEmpty) {
            return const Center(child: Text("Nothing To Do"));
          } else {
            return ListView.builder(
              itemCount: provider.todo.length,
              itemBuilder: (context, index) {
                final todo = provider.todo[index];
                return MyTodoItems(
                  todo: todo,
                  onchanged: (value) {
                    provider.updateTodo(value, index);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void addTodo() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setBuilderState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 12,
            right: 12,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: "What to do?"),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text("Select priority"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<Todopriority>(
                    value: Todopriority.low,
                    groupValue: priority,
                    onChanged: (value) {
                      setBuilderState(() => priority = value!);
                    },
                  ),
                  const Text("Low"),
                  Radio<Todopriority>(
                    value: Todopriority.normal,
                    groupValue: priority,
                    onChanged: (value) {
                      setBuilderState(() => priority = value!);
                    },
                  ),
                  const Text("Normal"),
                  Radio<Todopriority>(
                    value: Todopriority.high,
                    groupValue: priority,
                    onChanged: (value) {
                      setBuilderState(() => priority = value!);
                    },
                  ),
                  const Text("High"),
                ],
              ),
              ElevatedButton(onPressed: _save, child: const Text("Save")),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_controller.text.isEmpty) {
      showMsg(context, "Input field must not be empty");
      return;
    }

    final todo = MyTodo(
      name: _controller.text,
      id: DateTime.now().millisecondsSinceEpoch,
      priority: priority,
    );

    Provider.of<TodoProvider>(context, listen: false).addTodo(todo);
    _controller.clear();
    Navigator.pop(context);
  }
}

// 3. HELPER WIDGETS
void showMsg(BuildContext context, String s) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Caution"),
      content: Text(s),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

class MyTodoItems extends StatelessWidget {
  final MyTodo todo;
  final Function(bool) onchanged;
  const MyTodoItems({super.key, required this.todo, required this.onchanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(todo.name),
      subtitle: Text("Priority: ${todo.priority.name}"),
      value: todo.completed,
      onChanged: (value) => onchanged(value!),
    );
  }
}
