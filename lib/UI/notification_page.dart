// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/UI/theme.dart';
import 'package:to_do_app/theme_provider.dart';

class NotificationPage extends StatelessWidget {
  final String payload;
  const NotificationPage({
    Key? key,
    required this.payload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    List<String> payload = this.payload.split('|');
    String title = payload[0];
    String body = payload[1];

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[600] : Colors.white,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey,
            )),
        title: Text(
          title,
          style: headingStyle(themeProvider.isDarkMode),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        height: 400,
        width: 300,
        decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[400],
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          body,
          style: subTitleStyle(themeProvider.isDarkMode),
        ),
      ),
    );
  }
}
