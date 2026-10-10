import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/account_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/account_selection_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ مزود العهد
        ChangeNotifierProvider(
          create: (_) => AccountProvider()..loadAll(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'إدارة المصروفات',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Cairo'),
            bodyMedium: TextStyle(fontFamily: 'Cairo'),
            bodySmall: TextStyle(fontFamily: 'Cairo'),
            titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            labelLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            labelMedium: TextStyle(fontFamily: 'Cairo'),
            labelSmall: TextStyle(fontFamily: 'Cairo'),
          ),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        // ✅ شاشة اختيار العهدة أولاً
        home: const AccountSelectionScreen(),
      ),
    );
  }
}