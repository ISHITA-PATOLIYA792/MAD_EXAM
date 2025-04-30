import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';
import 'package:mad_exam_22it123/screens/home_screen.dart';
import 'package:mad_exam_22it123/screens/category_screen.dart';
import 'package:mad_exam_22it123/screens/settings_screen.dart';
import 'package:mad_exam_22it123/screens/offers_screen.dart';
import 'package:mad_exam_22it123/services/notification_service.dart';

// mock firebase initialization for demo purposes
class MockFirebase {
  static Future<void> initializeApp() async {
    // simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));
    print('Firebase mock initialized');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase (for demo we'll use a mock)
  await MockFirebase.initializeApp();
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CardProvider()),
      ],
      child: MaterialApp(
        title: 'Loyalty Card Storage',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // screens to show
  final List<Widget> _screens = [
    const HomeScreen(),
    const OffersScreen(),
    const CategoryScreen(),
    const SettingsScreen(),
  ];
  
  // bottom navigation items
  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.credit_card),
      label: 'Cards',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.local_offer),
      label: 'Offers',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.category),
      label: 'Categories',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
