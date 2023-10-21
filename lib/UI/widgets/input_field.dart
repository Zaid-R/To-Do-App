// ignore_for_file: public_member_api_docs, sort_constructors_first
//Reusable widget
import 'package:flutter/material.dart';
import 'package:to_do_app/UI/theme.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/theme_provider.dart';

@immutable
class InputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  const InputField(
      {Key? key,
      required this.title,
      required this.hint,
      this.controller,
      this.widget})
      : super(key: key);

  UnderlineInputBorder _buildBorder(BuildContext context) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        //The color of underline
        color: Theme.of(context).backgroundColor,
        width: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle(themeProvider.isDarkMode),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(left: 14),
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: TextFormField(
                      //He did it using readOnly property
                  enabled: widget == null ? true : false,
                  cursorColor: Colors.grey[themeProvider.isDarkMode ? 100 : 700],
                  controller: controller,
                  style: subTitleStyle(themeProvider.isDarkMode),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: subTitleStyle(themeProvider.isDarkMode),
                    //border: _buildBorder(context),
                    focusedBorder: _buildBorder(context),
                    enabledBorder: _buildBorder(context),
                    disabledBorder: _buildBorder(context),
                  ),
                )),
                widget??Container()
              ],
            ),
          )
        ],
      ),
    );
  }
}
