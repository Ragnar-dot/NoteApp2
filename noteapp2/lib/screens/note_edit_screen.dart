import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/note_provider.dart';
import '../models/note.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart'; // Importiere main.dart für die Benachrichtigungsinstanz
import 'package:hive/hive.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;
  final int? noteId;

  NoteEditScreen({this.note, this.noteId});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;
  TextEditingController _contentController = TextEditingController();
  DateTime? _selectedReminderDate;

  Note? _note; // Lokale Variable für die Notiz

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    if (widget.noteId != null) {
      // Notiz anhand der ID laden
      final noteBox = Hive.box<Note>('notes');
      _note = noteBox.get(widget.noteId);
    } else {
      _note = widget.note;
    }

    if (_note != null) {
      _title = _note!.title;
      _contentController.text = _note!.content;
      if (_note!.reminderDate != null) {
        _selectedReminderDate = _note!.reminderDate;
      }
    }
  }

  Future<void> _scheduleNotification(Note note) async {
    if (_selectedReminderDate != null) {
      final scheduledNotificationDateTime = tz.TZDateTime.from(
        _selectedReminderDate!,
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        note.key.hashCode,
        'Erinnerung: ${note.title}',
        note.content,
        scheduledNotificationDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'notes_channel_id',
            'Notizen Kanal',
            channelDescription: 'Kanal für Notizerinnerungen',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: note.key.toString(),
      );
    } else {
      // Lösche die geplante Benachrichtigung, wenn keine Erinnerung gesetzt ist
      await flutterLocalNotificationsPlugin.cancel(note.key.hashCode);
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => setState(() {
          if (val == 'notListening') _isListening = false;
        }),
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _contentController.text = val.recognizedWords;
          }),
          localeId: Localizations.localeOf(context).languageCode,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _pickReminderDate() async {
    final locale = AppLocalizations.of(context)!;

    DateTime now = DateTime.now();
    DateTime initialDate = _selectedReminderDate ?? now;

    // Stelle sicher, dass initialDate nicht vor jetzt liegt
    if (initialDate.isBefore(now)) {
      initialDate = now;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2100),
      helpText: locale.pickReminder,
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedReminderDate != null && _selectedReminderDate!.isAfter(now)
              ? _selectedReminderDate!
              : now,
        ),
        helpText: locale.pickReminder,
      );
      if (pickedTime != null) {
        setState(() {
          _selectedReminderDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _removeReminder() async {
    setState(() {
      _selectedReminderDate = null;
    });
    // Lösche die geplante Benachrichtigung, falls die Notiz existiert
    if (_note != null) {
      await flutterLocalNotificationsPlugin.cancel(_note!.key.hashCode);
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      if (_note == null) {
        // Erstelle eine neue Notiz
        final newNote = Note(
          title: _title,
          content: _contentController.text,
          createdDate: DateTime.now(),
          reminderDate: _selectedReminderDate,
        );
        noteProvider.addNote(newNote);
        await _scheduleNotification(newNote);
      } else {
        // Aktualisiere bestehende Notiz
        _note!.title = _title;
        _note!.content = _contentController.text;
        _note!.reminderDate = _selectedReminderDate;
        await _note!.save();
        noteProvider.updateNote(_note!);
        await _scheduleNotification(_note!);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_note == null ? locale.newNote : locale.editNote),
        actions: [
          IconButton(
            icon: Icon(Icons.alarm),
            iconSize: 40,
            padding: EdgeInsets.only(right: 19.0),
            onPressed: _pickReminderDate,
            tooltip: locale.pickReminder,
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            iconSize: 40,
            padding: EdgeInsets.only(right: 19.0),
            onPressed: _listen,
            tooltip: locale.speechNote,
          ),
          IconButton(
            icon: Icon(Icons.save_rounded),
            iconSize: 40,
            onPressed: _saveNote,
            tooltip: locale.save,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: locale.title),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return locale.pleaseEnterTitle;
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: locale.content),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  onSaved: (value) {
                    // Inhalt wird bereits im Controller gespeichert
                  },
                ),
              ),
              if (_selectedReminderDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    children: [
                      Text(
                        '${locale.reminderSet} ${DateFormat('dd.MM.yyyy – HH:mm').format(_selectedReminderDate!)}',
                        style: TextStyle(color: Colors.red),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: _removeReminder,
                        tooltip: locale.removeReminder,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}