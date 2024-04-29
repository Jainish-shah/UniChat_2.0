import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unichat_poojan_project/Services/loginFormApi.dart';
import 'package:unichat_poojan_project/main_home_page.dart';

class loginform extends StatefulWidget {
  final String studentId;
  loginform({Key? key, required this.studentId,}) : super(key:key);

  @override
  _loginformState createState() => _loginformState();
}

class _loginformState extends State<loginform> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF16043F),
              Color(0xFF0C0101),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MORE ABOUT YOU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    letterSpacing: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Card(
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.25),
                  color: Color(0xFF241D31),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        buildTextFormField(
                            _firstNameController, 'First Name *'),
                        SizedBox(height: 20),
                        buildTextFormField(_lastNameController, 'Last Name *'),
                        SizedBox(height: 20),
                        buildTextFormField(_emailController, 'School Email'),
                        SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () async {
                            String userEmail = _emailController.text;

                            final apiService = ApiService();
                            final response = await apiService
                                .updateFirstTimeLogin(userEmail);

                            if (response['status'] == 'Updated') {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainHomePage(studentId: widget.studentId)));
                            } else {
                              print('Error: ${response['type']}');
                            }
                          },
                          child: Text('GO'),
                          style: ElevatedButton.styleFrom(
                            // primary: Theme.of(context)
                            //     .primaryColor, // Use the theme's primary color
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField(
      TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.white70),
    );
  }
}
