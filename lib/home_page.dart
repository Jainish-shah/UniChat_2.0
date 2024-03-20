import 'package:flutter/material.dart';
import 'MultiLayerParallax.dart'; // Make sure this is correctly imported

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _offset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildImageDescriptionSection(String imagePath, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0), // Add vertical padding between each photo-description pair
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 450, // Adjust as per your image aspect ratio
              margin: const EdgeInsets.only(right: 8.0), // Add some padding between photo and description
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kode Mono',
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            MultiLayerParallax(offset: _offset),
            SizedBox(height: 20),
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'About Us',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kode Mono',
                  ),
                ),
              ),
            ),
            _buildImageDescriptionSection('assets/aboutimg1.png', 'Unichat is the ultimate project management application that seamlessly integrates with Google Docs and leverages the power of Discord for communication.'),
            _buildImageDescriptionSection('assets/aboutimg2.jpeg', 'With Unichat, teams can collaborate effectively, manage projects efficiently, and brainstorm ideas effortlessly with the help of AI.'),
            _buildImageDescriptionSection('assets/AI.jpeg', 'Unichat empowers educators to oversee student activities, monitor progress, and facilitate seamless communication, enhancing classroom efficiency and student engagement.'),
            _buildImageDescriptionSection('assets/logo.png', 'With AI assistance, students can harness their creativity and brainstorm innovative ideas, fostering a collaborative learning environment and enhancing problem-solving skills.'),
            // Add more widgets as needed
          ],
        ),
      ),
    );
  }
}
