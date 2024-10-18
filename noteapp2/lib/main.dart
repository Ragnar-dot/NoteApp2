import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/note.dart';
import 'providers/note_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/notes_list_screen.dart';
import 'screens/settings_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
<<<<<<< HEAD
import 'package:flutter_native_timezone/flutter_native_timezone.dart'; // Neues Paket importieren
=======
import 'package:permission_handler/permission_handler.dart'; // <-- Ensure this import is here
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes');

<<<<<<< HEAD
  // Initialisiere Zeitzonen
  await _configureLocalTimeZone();
=======
  // Initialize time zones
  tz.initializeTimeZones();
  final String timeZoneName = tz.local.name;
  tz.setLocalLocation(tz.getLocation(timeZoneName));
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3

  // Initialize notifications
  await initializeNotifications();

  // Request necessary permissions
  await requestPermissions();

  runApp(MyApp());
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      // Optional: Lokale Benachrichtigung empfangen, während die App im Vordergrund ist (iOS/macOS)
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Optional: Behandlung beim Antippen der Benachrichtigung
      // Hier können Sie die Navigation zur entsprechenden Notiz hinzufügen
    },
  );
}

Future<void> requestPermissions() async {
  // Request notification permission (for Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Request schedule exact alarm permission (for Android 12+)
  if (await Permission.scheduleExactAlarm.isDenied) {
    // Since this is a special permission, you cannot request it directly.
    // You can guide the user to settings if necessary.
    // For now, we will print a message or handle as appropriate.
    print('Exact alarm permission is denied. Some features may not work as expected.');
    // Optionally, you can open app settings:
    // await openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()..loadNotes()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
<<<<<<< HEAD
            debugShowCheckedModeBanner: false,
=======
            debugShowCheckedModeBanner: false,  // Remove the debug banner
>>>>>>> ed389eec04170d748c89213a1d7f6b292afbe2f3
            title: 'Notizen',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => NotesListScreen(),
              '/settings': (context) => SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
