// lib/dashboard.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'vehiclepage.dart';
import 'userinfo.dart';
import 'bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  LatLng _initialPosition = LatLng(45.521563, -122.677433);
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    _locationPermissionGranted = true;
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
    _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _initialPosition,
        zoom: 14.0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/fleet-tracker-high-resolution-logo-transparent.png', // Replace with the path to your logo
            height: 40, // Adjust the height as needed
          ),
        ),
        backgroundColor: Color.fromRGBO(62, 92, 67, 1),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 11.5,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                if (_locationPermissionGranted) {
                  _getUserLocation();
                }
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: ListTile(
                        title: Text('Total Vehicles'),
                        trailing: Text('25'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text('Vehicles in Operation'),
                        trailing: Text('20'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text('Idle Vehicles'),
                        trailing: Text('5'),
                      ),
                    ),
                    Divider(),
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(8),
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.local_shipping),
                          title: Text('Vehicle 1'),
                          subtitle: Text('In Operation'),
                          trailing: Icon(Icons.check_circle, color: Colors.green),
                        ),
                        ListTile(
                          leading: Icon(Icons.local_shipping),
                          title: Text('Vehicle 2'),
                          subtitle: Text('Idle'),
                          trailing: Icon(Icons.pause_circle, color: Colors.orange),
                        ),
                        // Add more ListTiles for additional vehicles
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
