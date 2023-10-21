import 'dart:io';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/UI/add_task_page.dart';
import 'package:to_do_app/UI/theme.dart';
import 'package:to_do_app/UI/widgets/add_task_button.dart';
import 'package:to_do_app/UI/widgets/task_tile.dart';
import 'package:to_do_app/controllers/task_controller.dart';
import 'package:to_do_app/models/task.dart';
import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/services/theme_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  var themeServices = ThemeServices();
  DateTime selectedDate = DateTime.now();
  var taskController = TaskController();

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    if (Platform.isIOS) {
      //we need to ask for permissions after the notification has been initialized
      notifyHelper.requestIOSPermissions();
    }
    //To load the tasks
    //taskController.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: buildAppBar(),
      body: buildTemplate(children: [
        buildTaskBar(),
        buildDatePicker(),
        const SizedBox(
          height: 10,
        ),
        showTasks()
      ]),
    );
  }

  Widget buildTemplate({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: children,
      ),
    );
  }

  Widget buildTaskBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMMd().format(DateTime.now()),
              style: subHeadingStyle,
            ),
            Text(
              'Today',
              style: headingStyle,
            )
          ],
        ),
        AddTaskButton(
            label: '+ Add Task',
            onTap: () async {
              await Get.to(() => AddTaskPage());
              //To refresh task list in task controller
              taskController.getTasks();
            })
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          // var title =
          //     '${themeServices.getTheme() == ThemeMode.dark ? 'Dark' : 'Light'} theme activated';
          // String body = 'Theme changed';

          themeServices.switchTheme();
          notifyHelper.displayNotification(title: ' title', body: 'body');
          // notifyHelper.scheduledNotification(
          //   0,
          //   DateTime.now().minute+1
          //   ,DateFormat.yMd().format(DateTime.now().add(const Duration(days: 1)))

          // );
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_rounded,
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

  Widget buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectedTextColor: whiteColor,
        selectionColor: bluishColor,
        dateTextStyle: buildGoogleFontsStyle(16, Colors.grey, FontWeight.w600),
        monthTextStyle: buildGoogleFontsStyle(14, Colors.grey, FontWeight.w600),
        dayTextStyle: buildGoogleFontsStyle(16, Colors.grey, FontWeight.w600),
        onDateChange: (newDate) => setState(() => selectedDate = newDate),
      ),
    );
  }

  Widget showTasks() {
    taskController.getTasks();
    return Expanded(
        //Obx used with observable objects
        child: Obx(
      () {
        return ListView.builder(
            itemCount: taskController.taskList.length,
            itemBuilder: (_, index) {
              //print('task list lenght = ${taskController.taskList.length}');
              var task = taskController.taskList[index];
              print('Pure start time of task = ${task.startTime}');
              //I use Hm() because the time is in 24 hour format, not Jm() which is for AM PM format
              DateTime taskStartTime =
                  DateFormat.Hm().parse(task.startTime.toString());
              List formatedStartTime =
                  DateFormat.Hm().format(taskStartTime).split(':');
              var taskWidget = AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            biuldBottomSheet(context, task);
                          },
                          child: TaskTile(task),
                        )
                      ],
                    ),
                  ),
                ),
              );
              var taskDateSplit = task.date!.split('/');
              var month =
                  (taskDateSplit[0].length == 1 ? '0' : '') + taskDateSplit[0];
              var day =
                  (taskDateSplit[1].length == 1 ? '0' : '') + taskDateSplit[1];
              int compareDateResult = selectedDate
                  .compareTo(DateTime.parse('${taskDateSplit[2]}-$month-$day'));
              if ((task.repeat == 'Daily' && compareDateResult >= 0) ||
                  compareDateResult == 0) {
                    print('hour = ${formatedStartTime[0]}');
                //scheduled notification
                notifyHelper.scheduledNotification(
                    int.parse(formatedStartTime[0]),
                    int.parse(formatedStartTime[1]),
                    task);
                return taskWidget;
              } else {
                return Container();
              }
            });
      },
    ));
  }

  void biuldBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.only(top: 4),
      //Note****: try ommit using height and just pust ternary operator on the completed button itself, since the container has dynamic size by default
      height: context.mediaQuery.size.height *
          (task.isCompleted == 1 ? 0.24 : 0.32),
      width: context.mediaQuery.size.width,
      color: Get.isDarkMode ? darkGreyColor : Colors.white,
      child: Column(
        children: [
          //small bar appaer at the top of the bottom sheet
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[Get.isDarkMode ? 600 : 300]),
          ),
          task.isCompleted == 1
              ? Container()
              : biuldBottomSheetButton(
                  label: 'Task Completed',
                  onTap: () {
                    taskController.markTaskCompleted(task.id!);
                    Get.back();
                  },
                  context: context,
                  color: bluishColor),
          biuldBottomSheetButton(
              label: 'Delete Task',
              onTap: () {
                notifyHelper.cancelNotification(task.id!);
                taskController.deleteTask(task.id!);
                Get.back();
              },
              context: context,
              color: Colors.red),
          const SizedBox(
            height: 15,
          ),
          biuldBottomSheetButton(
              label: 'Close',
              onTap: () {
                Get.back();
              },
              context: context,
              color: whiteColor,
              isCloseButton: true),
        ],
      ),
    ));
  }

  biuldBottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color color,
      required BuildContext context,
      //Note****: I don't think that I need isCloseButton parameter, so after finishing the app with the instructor try to remove it
      bool isCloseButton = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: context.mediaQuery.size.height * 0.07,
        width: context.mediaQuery.size.width * 0.9,
        decoration: BoxDecoration(
            color: isCloseButton ? Colors.transparent : color,
            border: Border.all(
              width: 2,
              color: isCloseButton
                  ? Colors.grey[Get.isDarkMode ? 600 : 300]!
                  : color,
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: Text(label,
                style: isCloseButton
                    ? titleStyle
                    : titleStyle.copyWith(color: whiteColor))),
      ),
    );
  }
}
