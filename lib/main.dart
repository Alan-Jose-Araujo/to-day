import 'package:flutter/material.dart';
import './db_handler.dart';
import './todo.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHandler.database;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> _todos = [];
  final checkSoundEffect = CheckSoundEffect();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _playCheckSound() {
    checkSoundEffect.play();
  }

  void _loadTodos() async {
    List<Todo> todos = await DbHandler.getTodos();
    setState(() {
      _todos = todos;
    });
  }

  void _addTodo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTodoContent = "";
        return AlertDialog(
          title: Text("Adicionar nova tarefa"),
          content: TextField(
            onChanged: (value) {
              newTodoContent = value;
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (newTodoContent.isNotEmpty) {
                  final id = await DbHandler.insertTodo(newTodoContent);
                  if (!mounted) return;
                  setState(() {
                    _todos.add(Todo(id: id, content: newTodoContent));
                  });
                  Navigator.pop(context);
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.lightBlue,
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "To-Day",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: ListTile(
              title: Text(
                _todos[index].content,
                style: TextStyle(fontSize: 18),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _todos[index].completed,
                    onChanged: (bool? newValue) {
                      Todo targetTodo = _todos[index];
                      DbHandler.updateCompletedTodo(targetTodo.id, newValue!);
                      setState(() {
                        targetTodo.completed = newValue;
                      });
                      if (newValue) {
                        Todo movingOnTodo = _todos.removeAt(index);
                        _todos.add(movingOnTodo);
                        _playCheckSound();
                      }
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),

                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          Todo targetTodo = _todos[index];
                          String updatedTodoContent = "";
                          TextEditingController controller =
                              TextEditingController(text: targetTodo.content);
                          return AlertDialog(
                            title: Text('Atualizar tarefa'),
                            content: TextField(
                              controller: controller,
                              onChanged: (value) {
                                updatedTodoContent = value;
                              },
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Todo targetTodo = _todos[index];
                                  setState(() {
                                    if (updatedTodoContent.isNotEmpty) {
                                      DbHandler.updateTodo(
                                        targetTodo.id,
                                        updatedTodoContent,
                                      );
                                      _todos[index].content =
                                          updatedTodoContent;
                                    }
                                    Navigator.pop(context);
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Colors.lightBlue,
                                      ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Colors.white,
                                      ),
                                ),
                                child: Text('Salvar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Tem certeza que deseja excluir esta tarefa?',
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Colors.blueGrey,
                                      ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Colors.white,
                                      ),
                                ),
                                child: Text('Não'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Todo targetTodo = _todos[index];
                                  setState(() {
                                    DbHandler.deleteTodo(targetTodo.id);
                                    _todos.removeAt(index);
                                    Navigator.pop(context);
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Colors.blue,
                                      ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Colors.white,
                                      ),
                                ),
                                child: Text('Sim'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.lightBlue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CheckSoundEffect {
  AudioPlayer? _player;

  Future<void> play() async {
    _player?.dispose();
    _player = AudioPlayer();
    await _player!.play(AssetSource('pop_sound_effect.mp3'));
  }
}
