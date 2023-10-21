import 'package:flutter/material.dart';
import 'package:to_do_app/database/database_helper.dart';
import 'package:to_do_app/models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _taskList=[];
  TaskProvider(){
    getTasks();
  }

  get taskList => _taskList;
 
  //TODO: why he made task nullable here ?
  Future<int> addTask({Task? task}) async {
    _taskList.add(task!);
    int id = await DBHelper.insert(task);
    return id;
  }

  //TODO:make sure that deleting gettasks won't delete updating screen of tasks or any other screen
  //Get all data from table
  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.addAll(tasks.map((data) => Task.getDataFromJson(data)).toList());
    print(
        'Task list length = ${_taskList.length} this statement written in getTasks() in task_controller.dart');
  }

  void deleteTask(int taskId) {
    _taskList.removeWhere((element) => element.id==taskId);
    DBHelper.delete(taskId);
  }

  void markTaskCompleted(int taskId) async {
    // var index;
    // for(int i=0;i<_taskList.length;i++){
    //   if(_taskList[i].id==taskId){
    //     index = i;
    //     break;
    //   }
    // }
    // Task toUpdateTask = _taskList.removeAt(index);
    // toUpdateTask.setIsCompleted();
    // _taskList.insert(index,toUpdateTask);
    await DBHelper.update(taskId);
    getTasks();
  }
}
