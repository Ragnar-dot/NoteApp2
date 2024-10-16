import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/note_provider.dart';
import 'note_edit_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/note.dart'; // Import the Note model

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update the UI every minute
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
        backgroundColor: const Color.fromARGB(171, 211, 207, 207),
        title: Stack(
          children: [
            // Outline
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 8
                  ..color = const Color.fromARGB(255, 134, 132, 132), // Outline color
              ),
            ),
            // Inner text
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 255, 0),
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
            color: const Color.fromARGB(255, 2, 156, 72),
            onPressed: () {
              // Navigate to settings screen
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Hintergrundbild hinzufügen
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpeg'),// Pfad zum Hintergrundbild
                fit: BoxFit.cover, // Füllt den gesamten Bildschirm
                opacity: 0.3, // Bildtransparenz
              ),
            ),
          ),
          // Inhalt der Seite über dem Hintergrundbild
          Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              if (noteProvider.notes.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.newNote),
                );
              }
              return ListView.builder(
                itemCount: noteProvider.notes.length,
                itemBuilder: (context, index) {
                  final note = noteProvider.notes[index];

                  // Check if the reminder is due
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
                      child: Icon(Icons.delete, color: Colors.white), // Delete icon
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                      decoration: BoxDecoration(
                        color: isReminderDue
                            ? Colors.redAccent.withOpacity(0.2)
                            : const Color.fromARGB(3, 221, 216, 216).withOpacity(0.20),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          shape: CircleBorder(),
                          activeColor: Color.fromARGB(172, 251, 0, 0),
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
                                padding: const EdgeInsets.only(left: 150.0),
                                child: Icon(
                                  Icons.alarm,
                                  color: isReminderDue
                                      ? Colors.red
                                      : Theme.of(context).primaryColorLight,
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
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Add new note button
        backgroundColor: const Color.fromARGB(255, 2, 206, 104),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Button rounding
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
        tooltip: AppLocalizations.of(context)!.newNote, // Optional tooltip
      ),
    );
  }
}
