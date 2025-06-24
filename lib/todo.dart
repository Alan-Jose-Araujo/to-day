class Todo {
  int id;
  String content;
  bool completed;

  Todo({required this.id, required this.content, this.completed = false});

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      content: map['content'],
      completed: map['completed'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'content': content, 'completed': completed ? 1 : 0};
  }
}
