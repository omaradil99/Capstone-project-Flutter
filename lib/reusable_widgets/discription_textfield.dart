import 'package:flutter/material.dart';

TextField descriptionTextField(String text, TextEditingController controller) {
  return TextField(
    controller: controller,
    expands: true,
    maxLines: null,
    enableSuggestions: true,
    autocorrect: true,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    textAlignVertical: TextAlignVertical.top,
    decoration: InputDecoration(
      
      labelText: text,
      labelStyle: TextStyle(color: Colors.white70),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
    ),
    keyboardType: TextInputType.multiline,
  );
}
