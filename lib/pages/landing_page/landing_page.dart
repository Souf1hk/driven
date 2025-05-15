import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/translations/translation.dart';
import '../login/login_page.dart'; // Import the new LoginPage
import '../login/signup_page.dart'; // Import the new SignUpPage
import '../loadingPage/loading.dart';
import '../language/languages.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Container(
        height: media.height,
        width: media.width,
        decoration: const BoxDecoration(
          color: Color(0xfffDBEBEC), // Background color from the image
        ),
        child: Stack(
          children: [
            // Background image at the bottom
            Positioned(
              bottom: 0,
              child: Image.asset(
                'assets/introduction_vector1.png', // Replace with your image asset
                fit: BoxFit.fill,
                width: media.width,
                height: media.height * 0.4, // Adjust height to fit the bottom
              ),
            ),
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo at the top
                Container(
                  padding: EdgeInsets.only(top: media.height * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/main_logo.png',
                        height: media.width * 0.4, // Adjust logo size
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const Spacer(), // Pushes the buttons towards the middle/lower part
                // Sign Up and Sign In buttons
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center, // Center the buttons horizontally
                  children: [
                    SizedBox(
                      width: media.width * 0.8,
                      height: media.height * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A373), // Button color from the image
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          languages[choosenLanguage]['text_sign_up'] ?? 'Créer un nouveau compte',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center, // Center the text inside the button
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: media.width * 0.8,
                      height: media.height * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5E6CC), // Lighter button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          languages[choosenLanguage]['text_sign_in'] ?? 'Se connecter',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center, // Center the text inside the button
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2), // Space for the image and link at the bottom
                // Discover more link
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), // Padding inside the container
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Background color (semi-transparent white for visibility)
                    borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                  ),
                    // padding: EdgeInsets.only(bottom: media.height * 0.05),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          // Add logic to navigate to a "Discover More" page if needed
                        },
                        child: Text(
                          languages[choosenLanguage]['text_discover_more'] ?? 'Découvrir plus sur nos services',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center, // Center the text
                        ),
                      ),
                    ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}