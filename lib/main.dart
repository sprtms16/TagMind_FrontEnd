import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import application providers
import './providers/auth_provider.dart';
import './providers/diary_provider.dart';
import './providers/tag_provider.dart';
import './providers/iap_provider.dart';

// Import application screens
import './screens/auth_screen.dart';
import './screens/home_screen.dart';
import './screens/diary_edit_screen.dart';
import './screens/tag_store_screen.dart';

const Color kPrimaryColor = Color(0xFF2196F3);

void main() {
  // Run the application with MultiProvider for state management
  runApp(
    MultiProvider(
      providers: [
        // Provide AuthProvider for authentication state
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        // Provide DiaryProvider for diary data management
        ChangeNotifierProvider(
          create: (context) => DiaryProvider(),
        ),
        // Provide TagProvider for tag data management
        ChangeNotifierProvider(
          create: (context) => TagProvider(),
        ),
        // Provide IapProvider for in-app purchase related data
        ChangeNotifierProvider(
          create: (context) => IapProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TagMind', // Application title
      // Define the application's visual theme
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color swatch
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts density based on platform
        // Define the color scheme for the application
        colorScheme: const ColorScheme(
          primary: kPrimaryColor, // A vibrant blue for primary elements
          secondary: Color(0xFF42A5F5), // A lighter blue for secondary elements
          surface: Color(0xFFFFFFFF), // White for surfaces like cards and sheets
          background: Color(0xFFF5F5F5), // Light gray for general background
          error: Color(0xFFB00020), // Red for error states
          onPrimary: Colors.white, // Text/icons color on primary background
          onSecondary: Colors.white, // Text/icons color on secondary background
          onSurface: Colors.black, // Text/icons color on surface background
          onBackground: Colors.black, // Text/icons color on background
          onError: Colors.white, // Text/icons color on error background
          brightness: Brightness.light, // Overall brightness of the theme
        ),
        // Define the text theme for various text styles
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black), // Style for large headlines (e.g., screen titles)
          headlineMedium: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black), // Style for medium headlines (e.g., section titles)
          bodyLarge:
              TextStyle(fontSize: 16.0, color: Colors.black), // Style for main body text
          bodyMedium: TextStyle(
              fontSize: 14.0, color: Colors.grey), // Style for captions or auxiliary text
        ),
        // Define the theme for the AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor, // Use primary color for AppBar background
          foregroundColor: Colors.white, // White text/icons on AppBar
          elevation: 4, // Add a subtle shadow to the AppBar
        ),
        // Define the theme for Floating Action Buttons
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        // Define the theme for Elevated Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // Home screen based on authentication status
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.token != null ? HomeScreen() : AuthScreen();
        },
      ),
      // Define application routes
      routes: {
        DiaryEditScreen.routeName: (ctx) => DiaryEditScreen(),
        TagStoreScreen.routeName: (ctx) => TagStoreScreen(),
      },
    );
  }
}
