import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/UI/theme.dart';
import 'package:to_do_app/UI/widgets/add_task_button.dart';
import 'package:to_do_app/UI/widgets/input_field.dart';
import 'package:to_do_app/models/task.dart';
import 'package:to_do_app/task_provider.dart';
import 'package:to_do_app/theme_provider.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String startTime = DateFormat.Hm().format(DateTime.now());
  String endTime =
      DateFormat.Hm().format(DateTime.now().add(const Duration(hours: 1)));
  int selectedRemid = 5;
  List<int> remindList = [5, 10, 15, 20];
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];
  String selectedRepeat = 'None';

  List<Color> taskColors = [bluishColor, pinkColor, yellowColor];
  int selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>(); 
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
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
            style: headingStyle(themeProvider.isDarkMode),
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
              themeProvider: themeProvider,
              title: 'Remind',
              hint: '$selectedRemid minutes early',
              items: remindList,
              //TODO: remove setState, instead use provider
              onChange: (value) => setState(() => selectedRemid = value)),
          //Repeat field
          buildDropdownButton(
            themeProvider: themeProvider,
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
                buildColorPallete(themeProvider),
                AddTaskButton(
                  label: 'Create Task',
                  onTap: () async {
                    bool isTaskValid = validateDate();
                    if (isTaskValid) {
                      addTaskToDB();
                      Navigator.pop(context);
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
      var idValue = await context.read<TaskProvider>().addTask(
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All fields are required !'),
        backgroundColor: whiteColor,
      ));
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
      {
        required ThemeProvider themeProvider,
        required String title,
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
          style: subTitleStyle(themeProvider.isDarkMode),
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
      backgroundColor: Theme.of(context).backgroundColor,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
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

  Widget buildColorPallete(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Color',
            style: titleStyle(themeProvider.isDarkMode),
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
