import 'package:get/get.dart';
import 'package:to_do_app/database/database_helper.dart';
import 'package:to_do_app/models/task.dart';

//Processing data could be complex operation but getx help you to overcome those problems
class TaskController extends GetxController{
  //An observable is a way 
  //to be notified of a continuous stream of events over time (object which has a state)
  final taskList = <Task>[].obs;

  //This called during the initialization
  @override
  void onReady(){
    super.onReady();
  }
  
  Future<int> addTask({Task? task})async{
    int id = await DBHelper.insert(task);
    getTasks();
    return id;
  }
  //Get all data from table
  void getTasks()async{
    List<Map<String,dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.getDataFromJson(data)).toList());
    print('Task list length = ${taskList.length} this statement written in getTasks() in task_controller.dart');
  }

  void deleteTask(int taskId){
    DBHelper.delete(taskId);
    getTasks();
  }

  void markTaskCompleted(int taskId)async{
    await DBHelper.update(taskId);
    getTasks();
  }

}