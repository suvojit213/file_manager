import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_file_manager/screens/home_screen.dart';
import 'package:flutter_file_manager/utils/app_theme.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/services/vault_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        Provider(create: (_) => FileService()),
        Provider(create: (_) => VaultService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Flutter File Manager',
      theme: themeNotifier.currentTheme,
      home: const HomeScreen(initialPath: null),
      debugShowCheckedModeBanner: false,
    );
  }
}