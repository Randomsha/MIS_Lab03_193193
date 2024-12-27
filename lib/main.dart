import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/random_joke_screen.dart';
import 'screens/jokes_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/api_services.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'firebase_options.dart'; // Import the generated Firebase options file
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import local notifications
import 'package:timezone/data/latest.dart'
    as tz; // Import timezone data initialization
import 'package:timezone/timezone.dart' as tz; // Import timezone functionality

void main() async {
  // Ensure that Firebase is initialized before the app starts
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Use the platform-specific options
  );

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

  // Request permission for notifications (for iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Set up the local notifications plugin
  await _initializeLocalNotifications();

  // Schedule a daily joke notification
  await _scheduleJokeNotification();

  runApp(MyApp());
}

// Foreground message handler
Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print("Handling a foreground message: ${message.notification?.title}");
  await _showNotification(message); // Show a notification in the foreground
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

// Initialize local notifications
Future<void> _initializeLocalNotifications() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Show a local notification
Future<void> _showNotification(RemoteMessage message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'default_channel',
    'Default Channel',
    channelDescription: 'This is the default channel for notifications.',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title, // Notification title
    message.notification?.body, // Notification body
    notificationDetails,
    payload: 'item x', // Additional data
  );
}

// Schedule a daily joke notification
Future<void> _scheduleJokeNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'joke_channel',
    'Joke Notifications',
    channelDescription: 'Receive a joke of the day notification',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  // Schedule the notification for 9:00 AM daily
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // Notification ID
    'Joke of the Day', // Title
    'Here\'s your joke of the day!', // Body
    _nextInstanceOfTime(9, 0), // Schedule for 9:00 AM
    notificationDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.wallClockTime,
    matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
  );
}

// Get the next instance of a specific time (e.g., 9:00 AM)
tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> favoriteJokes = [];

  void _toggleFavorite(Map<String, dynamic> joke) {
    setState(() {
      if (favoriteJokes.contains(joke)) {
        favoriteJokes.remove(joke);
      } else {
        favoriteJokes.add(joke);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(favoriteJokes: favoriteJokes),
        '/random-joke': (context) => RandomJokeScreen(
              favoriteJokes: favoriteJokes,
              onToggleFavorite: _toggleFavorite,
            ),
        '/joke-list': (context) => JokeListScreen(
              favoriteJokes: favoriteJokes,
              onToggleFavorite: _toggleFavorite,
            ),
        '/favorites': (context) => FavoritesScreen(
              favoriteJokes: favoriteJokes,
              onToggleFavorite: _toggleFavorite,
            ),
      },
    );
  }
}
