import 'package:flutter/material.dart';
import 'registered.dart';
import 'food.dart';
import 'user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Start with User tab (rightmost)

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Build screens dynamically - Use stable keys for camera screens
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const RegisteredScreen(key: ValueKey('registered_screen'));
      case 1:
        return const FoodScreen(key: ValueKey('food_screen'));
      case 2:
        return const UserScreenContent();
      default:
        return const UserScreenContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: const Color(0xFF2D1B47),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Creepster',
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.orange,
          shadows: [
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 8,
              color: Colors.deepOrange,
            ),
          ],
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Creepster',
          fontSize: 13,
          color: Colors.white70,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
