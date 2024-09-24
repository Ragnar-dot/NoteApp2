// note_edit_screen.dart
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

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  NoteEditScreen({this.note});

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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    if (widget.note != null) {
      _title = widget.note!.title;
      _contentController.text = widget.note!.content;
      if (widget.note!.reminderDate != null) {
        _selectedReminderDate = widget.note!.reminderDate;
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
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'notizen_channel_id',
            'Notizen Channel',
            channelDescription: 'Channel für Notizen Erinnerungen',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
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

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: locale.pickReminder,
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            _selectedReminderDate ?? DateTime.now()),
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

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final noteProvider =
          Provider.of<NoteProvider>(context, listen: false);
      if (widget.note == null) {
        // Neue Notiz erstellen
        final newNote = Note(
          title: _title,
          content: _contentController.text,
          createdDate: DateTime.now(),
          reminderDate: _selectedReminderDate,
        );
        noteProvider.addNote(newNote);
        await _scheduleNotification(newNote);
      } else {
        // Existierende Notiz aktualisieren
        widget.note!.title = _title;
        widget.note!.content = _contentController.text;
        widget.note!.reminderDate = _selectedReminderDate;
        await widget.note!.save();
        noteProvider.updateNote(widget.note!);
        await _scheduleNotification(widget.note!);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.note == null ? locale.newNote : locale.editNote),
        actions: [
          IconButton(
            icon: Icon(Icons.alarm),
            onPressed: _pickReminderDate,
            tooltip: locale.pickReminder,
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _listen,
            tooltip: locale.speechNote,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: locale.save,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
              SizedBox(height: 16),
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
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${locale.reminderSet} ${DateFormat('dd.MM.yyyy – HH:mm').format(_selectedReminderDate!)}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}