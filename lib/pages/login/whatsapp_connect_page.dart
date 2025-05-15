import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/functions/notifications.dart';
import 'package:flutter_user/pages/login/login.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import 'agreement.dart';

class WhatsappConnectPage extends StatefulWidget {
  final String phoneNumber;
  const WhatsappConnectPage({super.key, required this.phoneNumber});

  @override
  State<WhatsappConnectPage> createState() => _WhatsappConnectPageState();
}

class _WhatsappConnectPageState extends State<WhatsappConnectPage> {
  final TextEditingController _otp = TextEditingController();
  bool loginLoading = false;
  String _error = '';
  bool _resend = false;
  int resendTimer = 60;
  bool mobileVerified = false;
  dynamic resendTime;

  @override
  void initState() {
    super.initState();
    // Send OTP when page opens
    sendOTP();
  }

  void sendOTP() async {
    setState(() {
      loginLoading = true;
    });
    
    if (isCheckFireBaseOTP) {
      var val = await otpCall();
      if (val.value == true) {
        await phoneAuth(countries[phcode]['dial_code'] + widget.phoneNumber);
        phoneAuthCheck = true;
        _resend = false;
        resendTimer = 60;
        resend();
      } else {
        phoneAuthCheck = false;
        RemoteNotification noti = const RemoteNotification(
            title: 'Otp for Login', body: 'Login to your account with test OTP 123456');
        showOtpNotification(noti);
      }
      _resend = false;
      resendTimer = 60;
      resend();
    } else {
      var val = await sendOTPtoMobile(widget.phoneNumber, countries[phcode]['dial_code'].toString());
      if (val == 'success') {
        phoneAuthCheck = true;
        _resend = false;
        resendTimer = 60;
        resend();
      } else {
        setState(() {
          _error = val;
        });
      }
    }
    
    setState(() {
      loginLoading = false;
    });
  }

  resend() {
    resendTime?.cancel();
    resendTime = null;

    resendTime = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          _resend = true;
          resendTime?.cancel();
          timer.cancel();
          resendTime = null;
        }
      });
    });
  }

  void verifyOTP() async {
    setState(() {
      _error = '';
      loginLoading = true;
    });

    if (_otp.text.isNotEmpty && _otp.text.length == 6) {
      if (phoneAuthCheck == true) {
        if (isCheckFireBaseOTP == true) {
          try {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verId, smsCode: _otp.text);
            await FirebaseAuth.instance.signInWithCredential(credential);
            mobileVerified = true;
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const AggreementPage()));
          } on FirebaseAuthException catch (error) {
            if (error.code == 'invalid-verification-code') {
              setState(() {
                _otp.clear();
                _error = 'Please enter correct Otp or resend';
              });
            }
          }
        } else {
          var val = await validateSmsOtp(widget.phoneNumber, _otp.text);
          if (val == 'success') {
            mobileVerified = true;
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const AggreementPage()));
          } else {
            setState(() {
              _error = val.toString();
            });
          }
        }
      } else {
        mobileVerified = true;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AggreementPage()));
      }
    } else {
      setState(() {
        _error = 'Please enter OTP';
      });
    }
    setState(() {
      loginLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    // Pinput decoration
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 24,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
    );
    
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          // Use decorative container as background instead of backgroundColor
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.black54,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              // Background image
              Container(
                height: media.height,
                width: media.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/login_pg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Main content
              Container(
                width: media.width,
                height: media.height,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top space
                      const SizedBox(height: 20),
                      
                      // Logo
                      Image.asset(
                        'assets/main_logo.png',
                        height: media.width * 0.25,
                        fit: BoxFit.contain,
                      ),
                      
                      // Spacer
                      const Spacer(flex: 1),
                      
                      // Instructional text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Nous avons envoyés un ',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text: 'CODE',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '\nsur votre WhatsApp pour\nvérifier votre numéro...',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Spacer
                      const Spacer(flex: 1),
                      
                      // OTP Input - 6 digit PIN
                      Pinput(
                        length: 6,
                        controller: _otp,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: const Color(0xFFD4A373)),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: const Color(0xFFD4A373)),
                          ),
                        ),
                        onCompleted: (pin) => verifyOTP(),
                        showCursor: true,
                      ),
                      
                      // Error message
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _error,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // Timer text
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Vous recevez votre code dans ${resendTimer} seconds',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      // Resend button
                      if (_resend)
                        TextButton(
                          onPressed: sendOTP,
                          child: Text(
                            'Renvoyer le code',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFFD4A373),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      
                      // Explicit Retour button
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Retour',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom spacer
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
              
              // Loading overlay
              if (loginLoading) const Positioned(top: 0, child: Loading()),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    resendTime?.cancel();
    super.dispose();
  }
} 