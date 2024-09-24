import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/note.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  void loadNotes() {
    final box = Hive.box<Note>('notes');
    _notes = box.values.toList();
    sortNotes();
  }

  void addNote(Note note) {
    final box = Hive.box<Note>('notes');
    box.add(note);
    _notes = box.values.toList();
    sortNotes();
  }

  void updateNote(Note note) {
    note.save();
    _notes = Hive.box<Note>('notes').values.toList();
    sortNotes();
  }

  void deleteNote(Note note) {
    note.delete();
    _notes.remove(note);
    notifyListeners();
  }

  void toggleCheck(Note note) {
    note.isChecked = !note.isChecked;
    note.save();
    sortNotes();
  }

  void sortNotes() {
    _notes.sort((a, b) {
      if (a.isChecked && !b.isChecked) return 1;
      if (!a.isChecked && b.isChecked) return -1;
      return b.createdDate.compareTo(a.createdDate); // Neuere zuerst
    });
    notifyListeners();
  }
}