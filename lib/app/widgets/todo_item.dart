import 'package:efficient_work_app/app/app.dart';
import 'package:efficient_work_app/app/model/todo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final onToDoChanged;
  final onDeleteItem;

  ToDoItem({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
  }) : super(key: key);

  String? getText() {
    return todo.text;
  }

  bool? itemBool = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 0.5.h,
      ),
      child: CheckboxListTile(
        visualDensity: VisualDensity.comfortable,
        side: BorderSide(
          color: AppState.pomodoroModeBackground,
          width: 2,
        ),
        dense: true,
        checkboxShape: CircleBorder(),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppState.pomodoroModeBackground,
        checkColor: Colors.white,
        onChanged: (value) {
          onToDoChanged(todo);
        },
        value: todo.isDone,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 0.w,
          vertical: 0.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        tileColor: Colors.white,
        title: Text(
          todo.text as String,
          style: GoogleFonts.notoSans(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            decorationThickness: 2,
          ),
        ),
        secondary: IconButton(
          constraints: BoxConstraints.tight(Size.square(12.w)),
          padding: EdgeInsets.all(0),
          splashRadius: 6.w,
          iconSize: 6.w,
          icon: Icon(
            Icons.delete,
            color: const Color.fromRGBO(186, 73, 73, 1),
          ),
          onPressed: () {
            onDeleteItem(todo.id);
          },
        ),
      ),
    );
  }
}
