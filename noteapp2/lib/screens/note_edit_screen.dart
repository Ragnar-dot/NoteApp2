import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/note_provider.dart';
import '../models/note.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
<<<<<<< HEAD
import '../main.dart'; // Importiere main.dart für die Benachrichtigungsinstanz
import 'package:hive/hive.dart';
=======
import '../main.dart'; // Import main.dart für die Benachrichtigungsinstanz
import 'package:permission_handler/permission_handler.dart'; // <-- Ensure this import is here

>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3

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
      // Überprüfen Sie, ob die Berechtigung SCHEDULE_EXACT_ALARM erteilt wurde
      if (await Permission.scheduleExactAlarm.isGranted) {
        final scheduledNotificationDateTime = tz.TZDateTime.from(
          _selectedReminderDate!,
          tz.local,
        );

<<<<<<< HEAD
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
=======
        await flutterLocalNotificationsPlugin.zonedSchedule(
          note.key.hashCode,
          'Reminder: ${note.title}',
          note.content,
          scheduledNotificationDateTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'notes_channel_id',
              'Notes Channel',
              channelDescription: 'Channel for note reminders',
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
      } else {
        // Wenn die Berechtigung nicht erteilt wurde, fordern Sie sie an oder leiten Sie den Benutzer zu den Einstellungen
        await _requestExactAlarmPermission();
      }
    } else {
      // Löschen Sie die geplante Benachrichtigung, wenn keine Erinnerung gesetzt ist
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
      await flutterLocalNotificationsPlugin.cancel(note.key.hashCode);
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    final locale = AppLocalizations.of(context)!;
    // Zeigen Sie einen Dialog an, um den Benutzer zu informieren
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale.permissionRequired),
        content: Text(locale.exactAlarmPermissionExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(locale.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Öffnen Sie die App-Einstellungen, damit der Benutzer die Berechtigung erteilen kann
              await openAppSettings();
            },
            child: Text(locale.openSettings),
          ),
        ],
      ),
    );
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

<<<<<<< HEAD
    // Stelle sicher, dass initialDate nicht vor jetzt liegt
=======
    // Stellen Sie sicher, dass initialDate nicht vor jetzt liegt
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
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
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedReminderDate != null && _selectedReminderDate!.isAfter(now)
            ? _selectedReminderDate!
            : now,
      ),
      helpText: locale.pickReminder,
    );
    if (pickedDate != null && pickedTime != null) {
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

  void _removeReminder() async {
    setState(() {
      _selectedReminderDate = null;
    });
<<<<<<< HEAD
    // Lösche die geplante Benachrichtigung, falls die Notiz existiert
    if (_note != null) {
      await flutterLocalNotificationsPlugin.cancel(_note!.key.hashCode);
=======
    // Löschen Sie die geplante Benachrichtigung, falls die Notiz existiert
    if (widget.note != null) {
      await flutterLocalNotificationsPlugin.cancel(widget.note!.key.hashCode);
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
<<<<<<< HEAD
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      if (_note == null) {
        // Erstelle eine neue Notiz
=======
      final noteProvider =
          Provider.of<NoteProvider>(context, listen: false);

      // Fordern Sie die erforderlichen Berechtigungen an
      await _requestPermissions();

      if (widget.note == null) {
        // Erstellen Sie eine neue Notiz
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
        final newNote = Note(
          title: _title,
          content: _contentController.text,
          createdDate: DateTime.now(),
          reminderDate: _selectedReminderDate,
        );
        noteProvider.addNote(newNote);
        await _scheduleNotification(newNote);
      } else {
<<<<<<< HEAD
        // Aktualisiere bestehende Notiz
        _note!.title = _title;
        _note!.content = _contentController.text;
        _note!.reminderDate = _selectedReminderDate;
        await _note!.save();
        noteProvider.updateNote(_note!);
        await _scheduleNotification(_note!);
=======
        // Aktualisieren Sie die bestehende Notiz
        widget.note!.title = _title;
        widget.note!.content = _contentController.text;
        widget.note!.reminderDate = _selectedReminderDate;
        await widget.note!.save();
        noteProvider.updateNote(widget.note!);
        await _scheduleNotification(widget.note!);
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
      }
      Navigator.pop(context);
    }
  }

  Future<void> _requestPermissions() async {
    // Fordern Sie die Benachrichtigungsberechtigung an (für Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Fordern Sie die Berechtigung für genaue Alarme an (für Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied ||
        await Permission.scheduleExactAlarm.isPermanentlyDenied) {
      await _requestExactAlarmPermission();
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
            color: Colors.red,
            iconSize: 40,
            color: Colors.red,
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
            icon: Icon(Icons.save_as),
<<<<<<< HEAD
            color: Colors.green,
            iconSize: 50,
=======
            iconSize: 50,
            color: Colors.green,
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
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
<<<<<<< HEAD
                      Text(
                        '${locale.reminderSet} ${DateFormat('dd.MM.yyyy – HH:mm').format(_selectedReminderDate!)}',
                        style: TextStyle(color: Colors.red),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
=======
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10.0), // Verschiebt den Text nach rechts
                        child: Text(
                          '${locale.reminderSet} ${DateFormat('dd.MM.yyyy – HH:mm').format(_selectedReminderDate!)}',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 241, 3, 3)),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: const Color.fromARGB(255, 241, 3, 3)),
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
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
<<<<<<< HEAD
}
=======
}
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
