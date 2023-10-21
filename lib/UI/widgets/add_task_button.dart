// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:to_do_app/UI/theme.dart';
class AddTaskButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  const AddTaskButton({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: bluishColor,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: whiteColor),
          ),
        ),
      ),
    );
  }
}
