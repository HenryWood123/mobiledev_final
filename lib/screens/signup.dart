import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isloading = false;

  Future<void> _signup() async{
    setState(() {
      _isloading = true;
    });

    final response = await http.post(
      Uri.parse('https://mobiledev-final.ew.r.appspot.com/signup'), // Update with your signup endpoint
      body: jsonEncode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'name': _nameController.text,
        'contactNumber': _phoneController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      _isloading = false;
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed. Please try again.')),
      );
    }

  }

  // void _signup() {
  //   if (_formKey.currentState!.validate()) {
  //     // Implement your signup logic here, for example:
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     );
  //     print('Username: ${ _usernameController.text }');
  //     print('Email: ${ _emailController.text }');
  //     print('Name: ${ _nameController.text }');
  //     print('Phone: ${ _phoneController.text }');
  //     print('Password: ${ _passwordController.text }');
  //     print('Confirm Password: ${ _confirmPasswordController.text }');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final pageHeight = MediaQuery.of(context).size.height;
    final pageWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(62, 92, 67, 1), // Background color
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: pageHeight * 0.05), // Adjust this value to move elements up or down
              Image.asset(
                'assets/images/fleet-tracker-high-resolution-logo-transparent.png', // Replace with your icon asset
                height: 150,
                width: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Create a New Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: pageWidth * 0.8,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1D1E33),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Color(0xFF111328),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Color(0xFF111328),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Color(0xFF111328),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Color(0xFF111328),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Color(0xFF111328),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      // SizedBox(height: 20),
                      // TextFormField(
                      //   controller: _confirmPasswordController,
                      //   decoration: InputDecoration(
                      //     hintText: 'Confirm Password',
                      //     hintStyle: TextStyle(color: Colors.white54),
                      //     filled: true,
                      //     fillColor: Color(0xFF111328),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //       borderSide: BorderSide.none,
                      //     ),
                      //     contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      //   ),
                      //   style: TextStyle(color: Colors.white),
                      //   obscureText: true,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please confirm your password';
                      //     }
                      //     if (value != _passwordController.text) {
                      //       return 'Passwords do not match';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          ); // Navigate back to login screen
                        },
                        child: Center(
                          child: Text(
                            'Already have an account? Log in',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: pageHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
