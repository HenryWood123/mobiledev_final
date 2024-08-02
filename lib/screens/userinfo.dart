import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobiledev_final/models/usermodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  late User user;
  bool isLoading = true;
  String? errorMessage;
  final _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  final storage = FlutterSecureStorage();

  Future<void> fetchUserInfo() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      print('Token: $token'); // Log the token for debugging

      if (token == null) {
        throw Exception('No JWT token found');
      }

      final response = await http.get(
        Uri.parse('https://mobiledev-final.ew.r.appspot.com/view_user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          user = User.fromJson(jsonResponse);
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode} ${response.body}'); // Log the error response
        throw Exception('Failed to load user info: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> updateUserInfo(User updatedUser) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      print('Token: $token'); // Log the token for debugging

      if (token == null) {
        throw Exception('No JWT token found');
      }

      final response = await http.patch(
        Uri.parse('https://mobiledev-final.ew.r.appspot.com/update_user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': updatedUser.name,
          'email': updatedUser.email,
          'contactNumber': updatedUser.phone,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          user = updatedUser;
        });
      } else {
        print('Error: ${response.statusCode} ${response.body}'); // Log the error response
        throw Exception('Failed to update user info: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _showEditModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: user.name);
    final TextEditingController emailController = TextEditingController(text: user.email);
    final TextEditingController phoneController = TextEditingController(text: user.phone);

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
                        'Edit Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        controller: nameController,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        controller: emailController,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                        controller: phoneController,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final updatedUser = User(
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            photoUrl: user.photoUrl,
                          );

                          await updateUserInfo(updatedUser);
                          Navigator.pop(context);
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

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      // Handle the picked image file
                      print('Picked file: ${pickedFile.path}');
                    }
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      // Handle the picked image file
                      print('Picked file: ${pickedFile.path}');
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user.name}.jpg');
      await storageRef.putFile(_image!);
      final downloadUrl = await storageRef.getDownloadURL();

      await _updateUserProfilePicture(downloadUrl);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _updateUserProfilePicture(String imageUrl) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No JWT token found');

    final response = await http.post(
      Uri.parse('https://mobiledev-final.ew.r.appspot.com/upload_profile_picture'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'imageurl': imageUrl}),
    );

    if (response.statusCode == 200) {
      // Handle successful update
      print('Profile picture updated successfully');
    } else {
      // Handle failed update
      print('Profile picture update failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, // Background color changed to white
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text('Error: $errorMessage'))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/user_photo.png'), // Replace with your user photo
                    ),
                    SizedBox(height: 10),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      leading: Icon(Icons.phone, color: Color.fromRGBO(62, 92, 67, 1)),
                      title: Text(
                        user.phone,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email, color: Color.fromRGBO(62, 92, 67, 1)),
                      title: Text(
                        user.email,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showEditModal(context);
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Edit Information'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(62, 92, 67, 1), // Button color
                    foregroundColor: Colors.white, // Text color
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showImageSourceActionSheet(context);
                  },
                  icon: Icon(Icons.upload),
                  label: Text('Upload Profile Picture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(62, 92, 67, 1), // Button color
                    foregroundColor: Colors.white, // Text color
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildInfoTile(IconData icon, String info) {
    return ListTile(
      leading: Icon(icon, color: Color.fromRGBO(62, 92, 67, 1)),
      title: Text(
        info,
        style: TextStyle(color: Colors.black), // Text color changed to black
      ),
      tileColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildNavigationTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      tileColor: Color(0xFF1D1E33),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () {
        // Implement navigation functionality
      },
    );
  }
}
