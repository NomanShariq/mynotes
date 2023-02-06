import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textcontroller;

  @override
  void initState() {
    _notesService = NotesService();
    _textcontroller = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textcontroller.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void setuptextcontrollerlistener() {
    _textcontroller.removeListener(_textControllerListener);
    _textcontroller.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteIfTextIsEmpty() async {
    final note = _note;
    final text = _textcontroller.text;
    if (note != null && text.isEmpty) {
      await _notesService.deleteNote(id: note.id);
    }
  }

  void _saveIfNoteIsNotEmpty() async {
    final note = _note;
    final text = _textcontroller.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteIfTextIsEmpty();
    _saveIfNoteIsNotEmpty();
    _textcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              setuptextcontrollerlistener();
              return TextField(
                controller: _textcontroller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
