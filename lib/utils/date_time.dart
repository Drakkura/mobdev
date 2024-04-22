import 'package:flutter/material.dart';

class DateTimePicker {
  static Future<DateTime?> selectDate(BuildContext context, DateTime? selectedDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return pickedDate;
  }

  static Future<TimeOfDay?> selectTime(BuildContext context, TimeOfDay? selectedTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    return pickedTime;
  }
}
