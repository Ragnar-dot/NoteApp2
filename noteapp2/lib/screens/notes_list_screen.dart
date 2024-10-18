<<<<<<< HEAD
import 'dart:async'; // Für Timer

=======
// For Timer
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
import 'package:flutter/material.dart';
<<<<<<< HEAD
// ignore: unused_import
import '../models/note.dart'; // Importiere das Note-Modell
=======
// Import the Note model
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3

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
<<<<<<< HEAD
        backgroundColor: const Color.fromARGB(52, 9, 9, 9),
=======
        backgroundColor: const Color.fromARGB(132, 211, 206, 206), // App bar color
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
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
<<<<<<< HEAD
                  ..strokeWidth = 6
                  ..color = const Color.fromARGB(255, 73, 73, 73), // Farbe der Umrandung
=======
                  ..strokeWidth = 2
            
                  ..color = const Color.fromARGB(131, 0, 0, 0), // Outline color
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
              ),
            ),
            // Innerer Text
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                color: const Color.fromARGB(188, 241, 239, 239), // Text color
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
            icon: Icon(Icons.settings_display_rounded),
            iconSize: 30,
<<<<<<< HEAD
            color: const Color.fromARGB(255, 0, 255, 162),
=======
            color: const Color.fromARGB(255, 0, 0, 0), // Icon color
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
            onPressed: () {
              // Navigiere zum Einstellungsbildschirm
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
<<<<<<< HEAD
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
              indent: 30,
              endIndent: 30,
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
                    activeColor: Color.fromARGB(172, 251, 8, 0),
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
                          padding: const EdgeInsets.only(left: 140.0),
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
=======
      body: Stack(
        children: [
          // Add background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpeg'), // Path to background image
                fit: BoxFit.cover, // Fills the entire screen
                opacity: 0.3, // Image transparency
              ),
            ),
          ),
          // Page content over the background image
          Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              if (noteProvider.notes.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.newNote),
                );
              }
              return ListView.separated(
                itemCount: noteProvider.notes.length,
                separatorBuilder: (context, index) => Divider(
                  color: const Color.fromARGB(255, 112, 112, 112), // Color of the divider
                  thickness: 1.0, // Thickness of the divider
                ),
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
                      color: Colors.red, // Background color
                      child: Icon(Icons.delete, color: Colors.white), // Delete icon
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      decoration: BoxDecoration(
                        color: isReminderDue
                            ? const Color.fromARGB(255, 145, 36, 36).withOpacity(0.4) 
                            : const Color.fromARGB(136, 255, 255, 255).withOpacity(0.30), // Note background color
                        // Note background color
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
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
<<<<<<< HEAD
        // Neue Notiz hinzufügen Button

        backgroundColor: const Color.fromARGB(255, 0, 255, 162),
=======
        // Add new note button
        backgroundColor: const Color.fromARGB(62, 0, 0, 0),
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
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
<<<<<<< HEAD
          size: 36.0,
          color: Colors.black,
        ),
        tooltip: AppLocalizations.of(context)!.newNote, // Optionaler Tooltip
=======
          size: 50.0,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        tooltip: AppLocalizations.of(context)!.newNote, // Optional tooltip
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
      ),
    );
  }
}
