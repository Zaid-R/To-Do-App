import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/UI/theme.dart';
import 'package:to_do_app/UI/widgets/add_task_button.dart';
import 'package:to_do_app/UI/widgets/input_field.dart';
import 'package:to_do_app/controllers/task_controller.dart';
import 'package:to_do_app/models/task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController taskController = TaskController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String startTime = DateFormat.Hm().format(DateTime.now());
  String endTime = DateFormat.Hm().format(DateTime.now().add(const Duration(hours: 1)));
  int selectedRemid = 5;
  List<int> remindList = [5, 10, 15, 20];
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];
  String selectedRepeat = 'None';

  List<Color> taskColors = [bluishColor, pinkColor, yellowColor];
  int selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: buildAppBar(context),
      body:
          //He used SingleChildScrollView(child: Column()), and I remember that ListView is an alternative for the previous mix, so I'll try
          ListView(
        //Since ListView has padding property I think I can ommit using Container as parent widget for ListView to use its padding
        padding: const EdgeInsets.symmetric(horizontal: 20),
         
        children: [
          //Add Task label
          Text(
            'Add Task',
            style: headingStyle,
          ),
          //title field
          InputField(
            title: 'Title',
            hint: 'Enter your title ...',
            controller: titleController,
          ),
          //Note field
          InputField(
            title: 'Note',
            hint: 'Enter your note ...',
            controller: noteController,
          ),
          //Date field
          InputField(
            title: 'Date',
            hint: DateFormat.yMd().format(selectedDate),
            widget: IconButton(
                onPressed: getDateFromUser,
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey,
                )),
          ),
          //Start time and end time fields
          Row(
            children: [
              buildTimeField(
                  title: 'Start Time', hint: startTime, isStartTime: true),
              const SizedBox(
                width: 12,
              ),
              buildTimeField(
                  title: 'End Time', hint: endTime, isStartTime: false)
            ],
          ),
          //Remind field
          buildDropdownButton(
              title: 'Remind',
              hint: '$selectedRemid minutes early',
              items: remindList,
              onChange:(value)=>setState(()=>selectedRemid = value)),
          //Repeat field
          buildDropdownButton(
              title: 'Repeat',
              hint: selectedRepeat,
              items: repeatList,
              onChange: (value) => setState(() => selectedRepeat = value)),
          //Color and create task button
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildColorPallete(),
                AddTaskButton(
                  label: 'Create Task',
                  onTap: () async {
                    bool isTaskValid = validateDate();
                    if (isTaskValid) {
                      addTaskToDB();
                      Get.back();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void addTaskToDB() async {
    try {
      var idValue = await taskController.addTask(
          task: Task(
        note: noteController.text,
        title: titleController.text,
        date: DateFormat.yMd().format(selectedDate),
        startTime: startTime,
        endTime: endTime,
        remind: selectedRemid,
        repeat: selectedRepeat,
        color: selectedColorIndex,
        isCompleted: 0,
      ));
      print('Task id is $idValue');
    } catch (e) {
      print('Error in addTaskToDB() is $e');
    }
  }

  bool validateDate() {
    // if (titleController.text.isNotEmpty && noteController.text.isNotEmpty) {
    //   Get.back();
    // } else
    if (titleController.text.isEmpty || noteController.text.isEmpty) {
      Get.snackbar('Required', 'All fields are required !',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: whiteColor,
          colorText: pinkColor,
          icon: Icon(Icons.warning_amber_rounded));
      return false;
    }
    return true;
  }

  Expanded buildTimeField(
      {required String title,
      required String hint,
      required bool isStartTime}) {
    return Expanded(
        child: InputField(
      title: title, //'Start Time',
      hint: hint, //startTime,
      widget: IconButton(
          onPressed: () => getTimeFromUser(isStartTime: isStartTime),
          icon: const Icon(
            Icons.access_time_rounded,
            color: Colors.grey,
          )),
    ));
  }

  InputField buildDropdownButton(
      {required String title,
      required String hint,
      required List<dynamic> items,
      required Function(dynamic value) onChange
      //bool isRemind = false
      }) {
    return InputField(
      title: title,
      hint: hint,
      widget: DropdownButton(
          //To hide the underline below the icon
          underline: Container(),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
          ),
          iconSize: 32,
          elevation: 4,
          style: subTitleStyle,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text('$item'),
                  ))
              .toList(),
          onChanged: onChange),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios,
          size: 20,
        ),
      ),
      actions: const [
        CircleAvatar(
          maxRadius: 20,
          backgroundImage: AssetImage('assets/circle_avatar.png'),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  void getDateFromUser() async {
    DateTime? datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 6), //six years ago
      lastDate: DateTime(DateTime.now().year + 6), //six years later
    );

    if (datePicker != null) {
      setState(() => selectedDate = datePicker);
    } else {
      print('Date picker is null');
    }
  }

  void getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await showTimePicker(
        context: context,
        //initialEntryMode:TimePickerEntryMode.input ,
        initialTime: TimeOfDay(
          hour: int.parse(startTime.split(':')[0]),
          minute: int.parse(startTime.split(':')[1]),
        ));

    String formatedTime = pickedTime!.format(context);
    if (isStartTime) {
      setState(() => startTime = formatedTime);
    } else if (!isStartTime) {
      setState(() => endTime = formatedTime);
    } else {
      print('Time canceld');
    }
  }

  Widget buildColorPallete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Color',
            style: titleStyle,
          ),
        ),
        Wrap(
          children: List<Widget>.generate(
              3,
              (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                        onTap: () => setState(() => selectedColorIndex = index),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: taskColors[index],
                          child: index == selectedColorIndex
                              ? const Icon(
                                  Icons.done,
                                  color: whiteColor,
                                  size: 16,
                                )
                              : null,
                        )),
                  )),
        )
      ],
    );
  }
}
