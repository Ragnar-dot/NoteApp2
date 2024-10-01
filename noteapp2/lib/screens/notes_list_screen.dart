import 'dart:async'; // Für Timer

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/note_provider.dart';
import 'note_edit_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ignore: unused_import
import '../models/note.dart'; // Importiere das Note-Modell

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Aktualisiere die UI jede Minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(52, 9, 9, 9),
        title: Stack(
          children: [
            // Umrandung
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 73, 73, 73), // Farbe der Umrandung
              ),
            ),
            // Innerer Text
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 255, 162),
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 40,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 30,
            color: const Color.fromARGB(255, 1, 177, 121),
            onPressed: () {
              // Navigiere zum Einstellungsbildschirm
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.notes.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.newNote),
            );
          }
          return ListView.separated(
            itemCount: noteProvider.notes.length,
            separatorBuilder: (context, index) => Divider(
              color: const Color.fromARGB(255, 34, 255, 0).withOpacity(0.5),
              thickness: 1,
              indent: 15,
              endIndent: 15,
            ),
            itemBuilder: (context, index) {
              final note = noteProvider.notes[index];

              // Überprüfen, ob die Erinnerung fällig ist
              final isReminderDue = note.isReminderDue();

              return Dismissible(
                key: Key(note.key.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  noteProvider.deleteNote(note);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.noteDeleted)),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  leading: Checkbox(
                    shape: CircleBorder(),
                    activeColor: Color.fromARGB(172, 0, 251, 159),
                    value: note.isChecked,
                    onChanged: (value) {
                      noteProvider.toggleCheck(note);
                    },
                  ),
                  title: Text(
                    note.title,
                    style: TextStyle(
                      decoration: note.isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isReminderDue ? Colors.red : null,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy – HH:mm').format(note.createdDate),
                        style: TextStyle(
                          decoration: note.isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (note.reminderDate != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.alarm,
                            color: isReminderDue ? Colors.red
                             : Theme.of(context).brightness == Brightness.dark
                                ? const Color.fromARGB(255, 141, 139, 139)
                                : const Color.fromARGB(255, 141, 139, 139),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEditScreen(note: note),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Neue Notiz hinzufügen Button

        backgroundColor: const Color.fromARGB(255, 0, 255, 162),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rundung des Buttons
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteEditScreen()),
          );
        },
        child: Icon(
          Icons.add,
          size: 36.0,
          color: Colors.black,
        ),
        tooltip: AppLocalizations.of(context)!.newNote, // Optionaler Tooltip
      ),
    );
  }
}