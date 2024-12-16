import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task_model.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final Box<Task> taskBox = Hive.box<Task>('tasks');
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void addTask(String title, String description) {
    final newTask = Task(title: title, description: description);
    taskBox.add(newTask);
    setState(() {});
  }

  void toggleTaskCompletion(Task task) {
    final taskIndex = taskBox.values.toList().indexOf(task);
    final updatedTask = Task(
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
      appBar: AppBar(title: Center(child: const Text("To-Do App"))),
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          final pendingTasks = box.values.where((task) => !task.isCompleted).toList();
          final completedTasks = box.values.where((task) => task.isCompleted).toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Pending Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ...pendingTasks.map((task) => ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => toggleTaskCompletion(task),
                      ),
                    )),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Completed Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ...completedTasks.map((task) => ListTile(
                      title: Text(task.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
                      subtitle: Text(task.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(box.values.toList().indexOf(task)),
                      ),
                    )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: "Description"),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      onPressed: () {
                        addTask(titleController.text, descriptionController.text);
                        titleController.clear();
                        descriptionController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
