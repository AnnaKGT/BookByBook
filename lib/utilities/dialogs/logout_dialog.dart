
import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
import 'package:book_by_book/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context, 
    title: context.loc.logout_button, 
    content: context.loc.logout_dialog_prompt, 
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.logout_button: true,
    },
  ).then((value) => value ?? false);
}