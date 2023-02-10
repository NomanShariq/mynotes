import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/show_delete_dialog.dart';

typedef NoteCallBack = void Function(DatabaseNote note);

class NoteListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;
  const NoteListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            softWrap: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            onTap(note);
          },
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
        );
      },
    );
  }
}
