import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterSchoolPage extends StatefulWidget {
  @override
  _RegisterSchoolPageState createState() => _RegisterSchoolPageState();
}

class _RegisterSchoolPageState extends State<RegisterSchoolPage> {
  bool _isSubmitted = false;

  // Define a TextEditingController for each field
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _schoolAddressLine1Controller = TextEditingController();
  final TextEditingController _schoolAddressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _adminFirstNameController = TextEditingController();
  final TextEditingController _adminLastNameController = TextEditingController();
  final TextEditingController _adminEmailAddressController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _schoolNameController.dispose();
    _schoolAddressLine1Controller.dispose();
    _schoolAddressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    _adminEmailAddressController.dispose();
    super.dispose();
  }

  Future<void> sendRequest(BuildContext context, {required String schoolName, required String schoolAddress1, String? schoolAddress2, required String city, required String state, required String country, required String zipCode, required String adminFirstName, required String adminLastName, required String adminEmail}) async {
    if(schoolName.isNotEmpty && schoolAddress1.isNotEmpty && city.isNotEmpty && state.isNotEmpty && country.isNotEmpty && zipCode.isNotEmpty && adminFirstName.isNotEmpty && adminLastName.isNotEmpty && adminEmail.isNotEmpty) {
      var response = await http.post(
        Uri.parse(''),
        body: json.encode({
          "schoolname": _schoolNameController.text,
          "schooladdress1": _schoolAddressLine1Controller.text,
          "schooladdress2": _schoolAddressLine2Controller.text,
          "schoolcity": _cityController.text,
          "schoolstate": _stateController.text,
          "schoolpincode": _zipCodeController.text,
          "schoolcountry": _countryController.text,
          "schooladminFname": _adminFirstNameController.text,
          "schooladminLname": _adminLastNameController.text,
          "schooladminemail": _adminEmailAddressController.text,
          "approvalStatus": "Pending"
          // Add the rest of your parameters here
        }),
        // Include headers, authentication, etc., as needed
      );
      if (response.statusCode == 200) {
        setState(() {
          _isSubmitted = true;
          dispose();
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('End point is not specified properly'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('try agan'),
              ),
            ],
          ),
        );
        dispose();
      }
    } else {
      // One or more fields are empty, handle validation failure
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('All fields must be filled.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.primary;
    Color buttonTextColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/Register.png', width: 300, height: 200, fit: BoxFit.cover),
              SizedBox(height: 64),
              if (!_isSubmitted)
                Container(
                  width: 900,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withOpacity(0),
                    boxShadow: [BoxShadow(color: Color.fromRGBO(31, 38, 135, 0.7), blurRadius: 100, offset: Offset(0, 10))],
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text('Register Your School', style: TextStyle(color: Colors.white, fontFamily: 'Kode Mono', fontWeight: FontWeight.w100, letterSpacing: 5, fontSize: 28)),
                      ),
                      // Replace each TextFormField with a controller
                      TextFormField(controller: _schoolNameController, decoration: InputDecoration(labelText: 'School Name', border: OutlineInputBorder())),
                      SizedBox(height: 16),
                      TextFormField(controller: _schoolAddressLine1Controller, decoration: InputDecoration(labelText: 'School Address Line 1', border: OutlineInputBorder())),
                      SizedBox(height: 16),
                      TextFormField(controller: _schoolAddressLine2Controller, decoration: InputDecoration(labelText: 'School Address Line 2', border: OutlineInputBorder())),
                      SizedBox(height: 16),
                      Row(children: [Expanded(child: TextFormField(controller: _cityController, decoration: InputDecoration(labelText: 'City', border: OutlineInputBorder()))), SizedBox(width: 16), Expanded(child: TextFormField(controller: _stateController, decoration: InputDecoration(labelText: 'State', border: OutlineInputBorder())))],),
                      SizedBox(height: 16),
                      Row(children: [Expanded(child: TextFormField(controller: _countryController, decoration: InputDecoration(labelText: 'Country', border: OutlineInputBorder()))), SizedBox(width: 16), Expanded(child: TextFormField(controller: _zipCodeController, decoration: InputDecoration(labelText: 'ZipCode', border: OutlineInputBorder())))],),
                      SizedBox(height: 16),
                      Row(children: [Expanded(child: TextFormField(controller: _adminFirstNameController, decoration: InputDecoration(labelText: 'Admin First Name', border: OutlineInputBorder()))), SizedBox(width: 16), Expanded(child: TextFormField(controller: _adminLastNameController, decoration: InputDecoration(labelText: 'Admin Last Name', border: OutlineInputBorder())))],),
                      SizedBox(height: 16),
                      TextFormField(controller: _adminEmailAddressController, decoration: InputDecoration(labelText: 'Admin Email Address', border: OutlineInputBorder())),
                    ],
                  ),
                ),
              if (_isSubmitted) Image.asset('assets/Check.gif', width: 300, height: 200, fit: BoxFit.cover),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: buttonColor, onPrimary: buttonTextColor, padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                onPressed: () {
                  setState(() {
                    sendRequest(context, schoolName: _schoolNameController.text, schoolAddress1: _schoolAddressLine1Controller.text
                        ,schoolAddress2: _schoolAddressLine2Controller.text
                        , city: _cityController.text, state: _stateController.text, country: _countryController.text
                        , zipCode: _zipCodeController.text, adminFirstName: _adminFirstNameController.text
                        , adminLastName: _adminLastNameController.text, adminEmail: _adminEmailAddressController.text);
                  });

                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
