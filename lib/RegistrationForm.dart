import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Services/MongoDB_Routines.dart';
import 'main_home_page.dart';

class RegistrationForm extends StatefulWidget {

  final String studentId;
  const RegistrationForm({Key? key, required this.studentId}) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Registration')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'First Name'),
              validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
              onSaved: (value) => _firstName = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Last Name'),
              validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
              onSaved: (value) => _lastName = value,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Assuming `registerUser` method in `MongoDBService` to register the user.
                  // await _mongoDBService.registerUser(
                  //   widget.user!.email!,
                  //   _firstName!,
                  //   _lastName!,
                  // );
                  // Optionally, update AuthContext or perform other actions after registration.
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainHomePage(studentId: widget.studentId,)));
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
