// ignore_for_file: public_member_api_docs, sort_constructors_first
//Reusable widget
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/UI/theme.dart';

class InputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  InputField(
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
        color: context.theme.backgroundColor,
        width: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
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
                  cursorColor: Colors.grey[Get.isDarkMode ? 100 : 700],
                  controller: controller,
                  style: subTitleStyle,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: subTitleStyle,
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
