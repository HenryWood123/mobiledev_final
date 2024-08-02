class User {
  String name;
  String email;
  String phone;
  // String address;
  String photoUrl;

  User({
    required this.name,
    required this.email,
    required this.phone,
    // required this.address,
    this.photoUrl = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['contactNumber'] ?? '',
      // address: json['address'] ?? '',
      photoUrl: json['imageurl'] ?? '',
    );
  }
}
