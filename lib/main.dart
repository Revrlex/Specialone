import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'constants/styles.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'utils/notification_helper.dart';

void main() async {
  // Flutter Engine'i başlat
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bildirimleri başlat
  await NotificationHelper.initNotifications();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => TaskProvider(),
      child: MaterialApp(
        title: 'SpecialOne',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('tr', 'TR'),
        home: const HomeScreen(),
      ),
    );
  }
}