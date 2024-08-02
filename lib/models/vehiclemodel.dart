// lib/models/vehicle.dart
class Vehicle {
  final String imageUrl;
  final String licensePlate;
  final String make;
  final String model;
  final String status;
  final String vin;
  final int year;

  Vehicle({
    required this.imageUrl,
    required this.licensePlate,
    required this.make,
    required this.model,
    required this.status,
    required this.vin,
    required this.year,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      imageUrl: json['imageUrl'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      status: json['status'] ?? '',
      vin: json['vin'] ?? '',
      year: json['year'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'licensePlate': licensePlate,
      'make': make,
      'model': model,
      'status': status,
      'vin': vin,
      'year': year,
    };
  }
}
