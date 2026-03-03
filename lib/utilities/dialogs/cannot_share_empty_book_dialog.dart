import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
import 'package:book_by_book/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showCannotShareEmptyBookDialog(BuildContext context) {
  return showGenericDialog<void> (
    context: context, 
    title: context.loc.sharing, 
    content: context.loc.cannot_share_empty_note_prompt, 
    optionsBuilder: () => {
      context.loc.ok: null,
    },
    );
  
}