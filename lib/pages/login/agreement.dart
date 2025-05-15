import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/pages/loadingPage/loading.dart';
import 'package:flutter_user/pages/referralcode/referral_code.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import 'login.dart'; // Import login.dart to access global variables

class AggreementPage extends StatefulWidget {
  const AggreementPage({super.key});

  @override
  State<AggreementPage> createState() => _AggreementPageState();
}

class _AggreementPageState extends State<AggreementPage> {
  //navigate
  navigate() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Referral()),
        (route) => false);
  }

  bool loginLoading = false;
  // ignore: unused_field
  String _error = '';
  
  // Define local variables for email and password
  String localEmail = '';
  String localPassword = '';
  String localPhnumber = '';
  
  @override
  void initState() {
    super.initState();
    // Copy global variables to local variables
    localEmail = email;
    localPassword = password;
    localPhnumber = phnumber;
  }
  
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      color: const Color(0xFFE6EFF0), // Light blue background color from image
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            // Main content
            Container(
              width: media.width,
              height: media.height,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: media.height * 0.08),
                    
                    // Driven Logo
                    Image.asset(
                      'assets/main_logo.png',
                      height: media.width * 0.25,
                      fit: BoxFit.contain,
                    ),
                    
                    SizedBox(height: media.height * 0.02),
                    
                    // Brand name
                    const Text(
                      "DRIVEN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    
                    SizedBox(height: media.height * 0.04),
                    
                    // Main slogan
                    Text(
                      "Redéfinir la mobilité et créer un écosystème de commerce équitable",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: media.height * 0.04),
                    
                    // Morocco map
                    Image.asset(
                      'assets/map_ma.png',
                      height: media.height * 0.25,
                      fit: BoxFit.contain,
                    ),
                    
                    SizedBox(height: media.height * 0.04),
                    
                    // Station text
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Notre première station est\nDrâa-Tafilalet, ",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: "Ouarzazate",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: media.height * 0.04),
                    
                    // Help us grow text
                    Text(
                      "Aidez-nous à faire grandir\nle réseau...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: media.height * 0.04),
                    
                    // Avec plaisir button (Same functionality as Suivant)
                    InkWell(
                      onTap: () async {
                        setState(() {
                          loginLoading = true;
                          _error = '';
                        });

                        valueNotifierLogin.incrementNotifier();
                        
                        // Set default email if not provided
                        if (localEmail.isEmpty) {
                          // Use phone number as email if it's not provided
                          localEmail = "${localPhnumber}@atlas-mobility.com";
                        }
                        
                        // Set default password if not provided
                        if (localPassword.isEmpty) {
                          // Generate a default password
                          localPassword = "Pass${localPhnumber}";
                        }
                        
                        // Update global variables
                        email = localEmail;
                        password = localPassword;
                        
                        var register = await registerUser();
                        if (register == 'true') {
                          //referral page
                          navigate();
                        } else {
                          // Check if the error is about email field
                          if (register.toString().toLowerCase().contains('email') || 
                              register.toString().toLowerCase().contains('the email field is required')) {
                            // Try again with a default email
                            localEmail = "${localPhnumber}@atlas-mobility.com";
                            email = localEmail; // Update global variable
                            register = await registerUser();
                            if (register == 'true') {
                              navigate();
                            } else {
                              setState(() {
                                _error = register.toString();
                              });
                            }
                          } else if (register.toString().toLowerCase().contains('password')) {
                            // Try again with a stronger password
                            localPassword = "Atlas${localPhnumber}!";
                            password = localPassword; // Update global variable
                            register = await registerUser();
                            if (register == 'true') {
                              navigate();
                            } else {
                              setState(() {
                                _error = register.toString();
                              });
                            }
                          } else {
                            setState(() {
                              _error = register.toString();
                            });
                          }
                        }
                        
                        setState(() {
                          loginLoading = false;
                        });
                        valueNotifierLogin.incrementNotifier();
                      },
                      child: Container(
                        width: media.width * 0.8,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xffC9A36C), // Gold/brown color from image
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Avec plaisir",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: media.height * 0.02),
                    
                    // Peut-être après text button
                    InkWell(
                      onTap: () {
                        // Placeholder for the functionality you want to add later
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Peut-être après >",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: media.height * 0.04),
                  ],
                ),
              ),
            ),
            
            // Error message if present
            if (_error != '')
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
            // Loading overlay
            if (loginLoading) const Positioned(child: Loading())
          ],
        ),
      ),
    );
  }
}

// Updated Driven UI with new design
