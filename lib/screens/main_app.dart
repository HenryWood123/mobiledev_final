import 'package:flutter/material.dart';
import 'package:mobiledev_final/screens/home.dart';
import 'package:mobiledev_final/screens/userinfo.dart';
import 'package:mobiledev_final/screens/vehiclepage.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    UserInfoPage(),
    VehicleListPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Vehicles',
          ),
        ],
        selectedItemColor: Color.fromRGBO(62, 92, 67, 1),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
