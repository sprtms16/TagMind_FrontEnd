import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TagMind',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define custom color palette based on design document
        colorScheme: const ColorScheme(
          primary: Color(0xFF4C6EF5), // Calm Blue
          primaryVariant: Color(0xFF3A5BBF), // Darker Calm Blue
          secondary: Color(0xFFADB5BD), // Soft Gray
          secondaryVariant: Color(0xFF868E96), // Darker Soft Gray
          surface: Color(0xFFF8F9FA), // Off-White
          background: Color(0xFFF8F9FA), // Off-White
          error: Color(0xFFDC3545), // Red for errors
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Color(0xFF212529), // Deep Charcoal
          onBackground: Color(0xFF212529), // Deep Charcoal
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color(0xFF212529)), // Screen Title
          headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Color(0xFF212529)), // Section Title
          bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF212529)), // Body Text
          bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFFADB5BD)), // Caption/Auxiliary Text
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          foregroundColor: Color(0xFF212529),
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    Text('Insights Page'),
    Text('Mind Garden Page'),
    Text('Settings Page'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TagMind'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: 'Mind Garden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Diary Creation Page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}