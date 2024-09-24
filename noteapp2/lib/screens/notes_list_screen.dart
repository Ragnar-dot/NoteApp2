import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/note_provider.dart';
import 'note_edit_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Entferne die folgende Zeile, da sie nicht verwendet wird
    // final noteProvider = Provider.of<NoteProvider>(context);

return Scaffold(
  appBar: AppBar(
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
              ..color = const Color.fromARGB(255, 115, 118, 115), // Farbe der Umrandung
          ),
        ),
        // Innerer Text
        Text(
          AppLocalizations.of(context)!.appTitle,
          style: TextStyle(
            color: const Color.fromARGB(255, 8, 201, 130),
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
            color: const Color.fromARGB(255, 9, 159, 104),
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
          return ListView.builder(
            itemCount: noteProvider.notes.length,
            itemBuilder: (context, index) {
              final note = noteProvider.notes[index];
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
                    activeColor:  Color.fromARGB(172, 0, 251, 159),
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
                            color: Theme.of(context).primaryColor,
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
        // Neue Notiz hinzufügen  button
        backgroundColor: const Color.fromARGB(172, 0, 251, 159),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rundung des Buttons
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteEditScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: AppLocalizations.of(context)!.newNote, // Optional: Tooltip hinzufügen
      ),
    );
  }
}