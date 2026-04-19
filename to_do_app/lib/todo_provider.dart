import 'package:flutter/material.dart';
import 'package:to_do_app/main.dart';

class TodoProvider extends ChangeNotifier {
  List<MyTodo> _todos = [];
  List<MyTodo> get todo => _todos;
  addTodo(MyTodo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  updateTodo(bool value, int index) {
    _todos[index].completed = value;
    notifyListeners();
  }
}
