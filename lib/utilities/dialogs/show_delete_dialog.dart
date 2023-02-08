import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog<bool>(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are your sure you want to Delete this Note',
    optionBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}
