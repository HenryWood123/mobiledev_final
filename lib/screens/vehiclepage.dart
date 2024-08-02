import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobiledev_final/models/vehiclemodel.dart';

class VehicleListPage extends StatefulWidget {
  @override
  _VehicleListPageState createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  final storage = FlutterSecureStorage();
  late Future<List<Vehicle>> futureVehicles;

  @override
  void initState() {
    super.initState();
    futureVehicles = fetchVehicles();
  }

  Future<List<Vehicle>> fetchVehicles() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      print('Token: $token'); // Log the token for debugging

      if (token == null) {
        throw Exception('No JWT token found');
      }

      final response = await http.get(
        Uri.parse('https://mobiledev-final.ew.r.appspot.com/list_user_vehicles'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> vehiclesJson = json.decode(response.body)['vehicles'];
        return vehiclesJson.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      throw Exception('Error fetching vehicles');
    }
  }

  Future<void> _refreshVehicles() async {
    setState(() {
      futureVehicles = fetchVehicles();
    });
  }

  void _showAddVehicleModal(BuildContext context) {
    final TextEditingController licensePlateController = TextEditingController();
    final TextEditingController makeController = TextEditingController();
    final TextEditingController modelController = TextEditingController();
    final TextEditingController statusController = TextEditingController();
    final TextEditingController vinController = TextEditingController();
    final TextEditingController yearController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add Vehicle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'License Plate',
                          border: OutlineInputBorder(),
                        ),
                        controller: licensePlateController,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Make',
                          border: OutlineInputBorder(),
                        ),
                        controller: makeController,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Model',
                          border: OutlineInputBorder(),
                        ),
                        controller: modelController,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        controller: statusController,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'VIN',
                          border: OutlineInputBorder(),
                        ),
                        controller: vinController,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        controller: yearController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final newVehicle = Vehicle(
                            imageUrl: '', // No image URL since we're not handling images
                            licensePlate: licensePlateController.text,
                            make: makeController.text,
                            model: modelController.text,
                            status: statusController.text,
                            vin: vinController.text,
                            year: int.parse(yearController.text),
                          );

                          final token = await storage.read(key: 'jwt_token');
                          if (token == null) {
                            // Handle the error of missing token
                            return;
                          }

                          final response = await http.post(
                            Uri.parse('https://mobiledev-final.ew.r.appspot.com/register_vehicle'),
                            headers: {
                              'Authorization': 'Bearer $token',
                              'Content-Type': 'application/json',
                            },
                            body: json.encode(newVehicle.toJson()),
                          );

                          if (response.statusCode == 201) {
                            setState(() {
                              futureVehicles = fetchVehicles(); // Refresh the list of vehicles
                            });
                            Navigator.pop(context);
                          } else {
                            // Handle the error of failed registration
                          }
                        },
                        child: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(62, 92, 67, 1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/fleet-tracker-high-resolution-logo-transparent.png', // Replace with your logo path
            height: 40, // Adjust the height as needed
          ),
        ),
        backgroundColor: Color.fromRGBO(62, 92, 67, 1),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: futureVehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No vehicles found'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshVehicles,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final vehicle = snapshot.data![index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ExpansionTile(
                      leading: vehicle.imageUrl.isNotEmpty
                          ? Image.network(
                        vehicle.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 50),
                      ),
                      title: Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('License Plate: ${vehicle.licensePlate}'),
                          Text('Status: ${vehicle.status}'),
                        ],
                      ),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    vehicle.imageUrl.isNotEmpty
                                        ? Image.network(
                                      vehicle.imageUrl,
                                      width: 200,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      width: 200,
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image, size: 50),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${vehicle.make} ${vehicle.model}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '${vehicle.licensePlate}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Year',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${vehicle.year}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'VIN: ${vehicle.vin}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddVehicleModal(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(62, 92, 67, 1),
      ),
      // bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
