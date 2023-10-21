import 'dart:io';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/UI/add_task_page.dart';
import 'package:to_do_app/UI/theme.dart';
import 'package:to_do_app/UI/widgets/add_task_button.dart';
import 'package:to_do_app/UI/widgets/task_tile.dart';
import 'package:to_do_app/models/task.dart';
import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/task_provider.dart';
import 'package:to_do_app/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  DateTime selectedDate = DateTime.now();

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
    final themeProvider = context.watch<ThemeProvider>();
    final taskProvider = context.watch<TaskProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: buildAppBar(themeProvider),
      body: buildTemplate(children: [
        buildTaskBar(themeProvider),
        buildDatePicker(),
        const SizedBox(
          height: 10,
        ),
        showTasks(themeProvider,taskProvider)
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

  Widget buildTaskBar(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMMd().format(DateTime.now()),
              style: subHeadingStyle(themeProvider.isDarkMode),
            ),
            Text(
              'Today',
              style: headingStyle(themeProvider.isDarkMode),
            )
          ],
        ),
        AddTaskButton(
            label: '+ Add Task',
            onTap: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddTaskPage()));
              //To refresh task list in task controller
              //taskController.getTasks();
            })
      ],
    );
  }

  AppBar buildAppBar(ThemeProvider themeProvider) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).backgroundColor,
      leading: GestureDetector(
        onTap: () {
          // var title =
          //     '${themeServices.getTheme() == ThemeMode.dark ? 'Dark' : 'Light'} theme activated';
          // String body = 'Theme changed';

          context.read<ThemeProvider>().switchTheme();
          notifyHelper.displayNotification(title: ' title', body: 'body');
          // notifyHelper.scheduledNotification(
          //   0,
          //   DateTime.now().minute+1
          //   ,DateFormat.yMd().format(DateTime.now().add(const Duration(days: 1)))

          // );
        },
        child: Icon(
          themeProvider.isDarkMode
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_rounded,
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

  Widget showTasks(ThemeProvider themeProvider, TaskProvider taskProvider) {
    return Expanded(
        //Obx used with observable objects
        child: ListView.builder(
            itemCount: taskProvider.taskList.length,
            itemBuilder: (context, index) {
              //print('task list lenght = ${taskController.taskList.length}');
              var task = taskProvider.taskList[index];
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
                            biuldBottomSheet(
                                context, task, themeProvider, taskProvider);
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
                    context,
                    int.parse(formatedStartTime[0]),
                    int.parse(formatedStartTime[1]),
                    task);
                return taskWidget;
              } else {
                return Container();
              }
            }));
  }

  void biuldBottomSheet(BuildContext context, Task task,
      ThemeProvider themeProvider, TaskProvider taskProvider) {
    showBottomSheet(
        context: context,
        builder: (innerContext) => Container(
              padding: const EdgeInsets.only(top: 4),
              //Note****: try ommit using height and just pust ternary operator on the completed button itself, since the container has dynamic size by default
              height: MediaQuery.of(context).size.height *
                  (task.isCompleted == 1 ? 0.24 : 0.32),
              width: MediaQuery.of(context).size.width,
              color: themeProvider.isDarkMode ? darkGreyColor : Colors.white,
              child: Column(
                children: [
                  //small bar appaer at the top of the bottom sheet
                  Container(
                    height: 6,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            Colors.grey[themeProvider.isDarkMode ? 600 : 300]),
                  ),
                  task.isCompleted == 1
                      ? Container()
                      //TODO: add copyWith() to biuldBottomSheetButton to decrease amount of code below
                      : biuldBottomSheetButton(
                        themeProvider: themeProvider,
                          label: 'Task Completed',
                          onTap: () {
                            taskProvider.markTaskCompleted(task.id!);
                            Navigator.pop(context);
                          },
                          context: context,
                          color: bluishColor),
                  biuldBottomSheetButton(
                    themeProvider: themeProvider,
                      label: 'Delete Task',
                      onTap: () {
                        notifyHelper.cancelNotification(task.id!);
                        taskProvider.deleteTask(task.id!);
                        Navigator.pop(context);
                      },
                      context: context,
                      color: Colors.red),
                  const SizedBox(
                    height: 15,
                  ),
                  biuldBottomSheetButton(
                      themeProvider: themeProvider,
                      label: 'Close',
                      onTap: () {
                        Navigator.pop(context);
                      },
                      context: context,
                      color: whiteColor,
                      isCloseButton: true),
                ],
              ),
            ));
  }

  biuldBottomSheetButton(
      {required ThemeProvider themeProvider,
      required String label,
      required Function()? onTap,
      required Color color,
      required BuildContext context,
      //Note****: I don't think that I need isCloseButton parameter, so after finishing the app with the instructor try to remove it
      bool isCloseButton = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
            color: isCloseButton ? Colors.transparent : color,
            border: Border.all(
              width: 2,
              color: isCloseButton
                  ? Colors.grey[themeProvider.isDarkMode ? 600 : 300]!
                  : color,
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: Text(label,
                style: isCloseButton
                    ? titleStyle(themeProvider.isDarkMode)
                    : titleStyle(themeProvider.isDarkMode).copyWith(color: whiteColor))),
      ),
    );
  }
}
