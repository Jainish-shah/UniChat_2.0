import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart'; // Assuming this is where MyHomePage is defined

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
  }

  Future<void> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seenOnboarding') ?? false);

    if (!_seen) {
      print("SEEN NO");
      await prefs.setBool('seenOnboarding', true);
    } else {
      print("SEEN YES");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "About Us",
          style: TextStyle(
            fontSize: 40, // Increased font size for 'About Us'
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0, // Removes the shadow under the app bar
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Aligns to the start of the column
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: <Widget>[
                createOnboardingPage(
                  'assets/aboutimg2.jpeg',
                  "Unichat is the ultimate project management application that seamlessly integrates with Google Docs and leverages the power of Discord for communication.",
                  false,
                ),
                createOnboardingPage(
                  'assets/collab.jpg',
                  "With Unichat, teams can collaborate effectively, manage projects efficiently, and brainstorm ideas effortlessly with the help of AI.",
                  false,
                ),
                createOnboardingPage(
                  'assets/teacher.png',
                  "Unichat empowers educators to oversee student activities, monitor progress, and facilitate seamless communication, enhancing classroom efficiency and student engagement.",
                  false,
                ),
                createOnboardingPage(
                  'assets/AI.jpeg',
                  "With AI assistance, brainstorm innovative ideas, fostering a collaborative learning environment and enhancing problem-solving skills.",
                  true, // This is the last page
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              4, // Number of pages
                  (int index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: 10,
                  width: (index == _currentPage) ? 30 : 10,
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: (index == _currentPage)
                        ? Colors.blue
                        : Colors.blue.withOpacity(0.5),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget createOnboardingPage(String imagePath, String text, bool isLastPage) {
    return Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: isLastPage ? 16.0 : 32.0, // Adjusted top padding
        bottom: isLastPage ? 0 : 16.0, // Adjusted bottom padding for other pages
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 5.0), // Move image up by 5px
            child: ClipOval(
              child: Container(
                width: 400,
                height: 400,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Increased font size
                  height: 1.5, // Increased line height
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (isLastPage) // Check if it's the last page and show the button
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Button color
                  onPrimary: Colors.white, // Text color
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 6.0),
                  child: Text(
                    'GET STARTED',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
