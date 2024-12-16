import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task_model.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Box<Task> taskBox = Hive.box<Task>('tasks');
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void addTask(String title, String description) {
    Task newTask = Task(title: title, description: description);
    taskBox.add(newTask);
    setState(() {});
  }

  void toggleTaskCompletion(Task task) {
    int taskIndex = taskBox.values.toList().indexOf(task);
    Task updatedTask = Task(
      title: task.title,
      description: task.description,
      isCompleted: !task.isCompleted,
    );
    taskBox.putAt(taskIndex, updatedTask);
    setState(() {});
  }

  void deleteTask(int index) {
    taskBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("To-Do App")),
      ),
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          List<Task> pendingTasks = box.values.where((task) => !task.isCompleted).toList();
          List<Task> completedTasks = box.values.where((task) => task.isCompleted).toList();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text("Pending Tasks", style: TextStyle(fontSize: 18)),
                    Column(
                      children: pendingTasks.map((task) {
                        return ListTile(
                          title: Text(task.title),
                          subtitle: Text(task.description),
                          trailing: IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () {
                              toggleTaskCompletion(task);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    Text("Completed Tasks", style: TextStyle(fontSize: 18)),
                    Column(
                      children: completedTasks.map((task) {
                        return ListTile(
                          title: Text(
                            task.title,
                            style: TextStyle(decoration: TextDecoration.lineThrough),
                          ),
                          subtitle: Text(task.description),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteTask(box.values.toList().indexOf(task));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: "Title"),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      addTask(titleController.text, descriptionController.text);
                      titleController.clear();
                      descriptionController.clear();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
