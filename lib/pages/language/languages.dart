import 'package:flutter/material.dart';
import 'package:flutter_user/pages/landing_page/landing_page.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../login/login.dart';

class Languages extends StatefulWidget {
  const Languages({super.key});

  @override
  State<Languages> createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  @override
  void initState() {
    choosenLanguage = 'en';
    languageDirection = 'ltr';
    super.initState();
  }

  // Navigate to login screen
  navigate(String selectedLanguage) {
    setState(() {
      choosenLanguage = selectedLanguage;
      if (choosenLanguage == 'ar' || choosenLanguage == 'ur' || choosenLanguage == 'iw') {
        languageDirection = 'rtl';
      } else {
        languageDirection = 'ltr';
      }
      pref.setString('languageDirection', languageDirection);
      pref.setString('choosenLanguage', choosenLanguage);
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection:
            (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          height: media.height,
          width: media.width,
          decoration: const BoxDecoration(
            color: const Color(0xfffDBEBEC), // Solid background color
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo at the top
              Container(
                padding: EdgeInsets.only(top: media.height * 0.05),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/main_logo.png', // Your logo asset
                      height: media.width * 0.4, // Adjust logo size
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const Spacer(), // Pushes the buttons towards the middle/lower part
              // Language buttons
              Column(
                children: [
                  _buildLanguageButton('ar', 'العربية', media),
                  const SizedBox(height: 20),
                  _buildLanguageButton('en', 'English', media),
                  const SizedBox(height: 20),
                  _buildLanguageButton('fr', 'Français', media),
                ],
              ),
              const Spacer(flex: 2), // Pushes content up, leaving space at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build language buttons
  Widget _buildLanguageButton(String languageCode, String languageName, Size media) {
    return SizedBox(
      width: media.width * 0.5, // Button width
      height: media.height * 0.07, // Button height
      child: ElevatedButton(
        onPressed: () {
          navigate(languageCode); // Navigate immediately on button press
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4A373), // Button color from the image
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
        ),
        child: Text(
          languageName,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}