import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String yesLabel = 'Sí',
  String noLabel = 'No',
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(noLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(yesLabel),
        ),
      ],
    ),
  );
}
