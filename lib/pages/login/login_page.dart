// login_page.dart
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/functions/notifications.dart';
import 'package:flutter_user/pages/onTripPage/invoice.dart';
import 'package:flutter_user/pages/onTripPage/map_page.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../language/languages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  bool loginLoading = false;
  String _error = '';
  bool withOtp = false;
  bool showPassword = false;
  bool showNewPassword = false;
  bool otpSent = false;
  bool _resend = false;
  int resendTimer = 60;
  bool isLoginemail = true;
  bool forgotPassword = false;
  bool newPassword = false;
  dynamic resendTime;

  @override
  void initState() {
    super.initState();
    countryCode();
  }

  countryCode() async {
    var result = await getCountryCode();
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

  navigate(dynamic verify) {
    if (verify == true) {
      if (userRequestData.isNotEmpty && userRequestData['is_completed'] == 1) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Invoice()),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
            (route) => false);
      }
    } else if (verify == false) {
      setState(() {
        _error = 'User Doesn\'t exists with this number, please Signup to continue';
      });
    } else {
      _error = verify.toString();
    }
    loginLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          height: media.height,
          width: media.width,
          color: const Color(0xfffDBEBEC),
          child: Stack(
            children: [
              // Background image at the bottom
              Positioned(
                bottom: 0,
                child: Image.asset(
                  'assets/introduction_vector1.png', // Use the same image as in LandingPage
                  fit: BoxFit.fill,
                  width: media.width,
                  height: media.height * 0.4, // Adjust height to fit the bottom
                ),
              ),
              // Main content
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Logo at the top
                    Container(
                      padding: EdgeInsets.only(top: media.height * 0.05),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/main_logo.png',
                            height: media.width * 0.3,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Form fields
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: media.width * 0.1),
                      child: Column(
                        children: [
                          // Email/Mobile field
                          Container(
                            height: media.width * 0.12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: media.width * 0.025),
                            child: Row(
                              children: [
                                if (isLoginemail == false && phcode != null)
                                  InkWell(
                                    onTap: () {
                                      if (otpSent == false) {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (builder) {
                                            return _buildCountryPicker(media);
                                          },
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: media.width * 0.025),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            countries[phcode]['flag'],
                                            width: media.width * 0.06,
                                          ),
                                          SizedBox(width: media.width * 0.015),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            size: media.width * 0.05,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: (otpSent == true) ? false : true,
                                    controller: _email,
                                    onChanged: (v) {
                                      String pattern = r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                      RegExp regExp = RegExp(pattern);
                                      if (regExp.hasMatch(_email.text) && isLoginemail == true) {
                                        setState(() {
                                          isLoginemail = false;
                                        });
                                      } else if (isLoginemail == false && !regExp.hasMatch(_email.text)) {
                                        setState(() {
                                          isLoginemail = true;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: languages[choosenLanguage]['text_email_mobile'],
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (otpSent == true)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _error = '';
                                        otpSent = false;
                                        _password.clear();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      size: media.width * 0.05,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if ((withOtp == false || otpSent == true || newPassword == false))
                            Column(
                              children: [
                                SizedBox(height: media.width * 0.05),
                                Container(
                                  height: media.width * 0.12,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: media.width * 0.025),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _password,
                                          decoration: InputDecoration(
                                            hintText: (otpSent == true)
                                                ? languages[choosenLanguage]['text_driver_otp']
                                                : languages[choosenLanguage]['text_enter_password'],
                                            border: InputBorder.none,
                                          ),
                                          keyboardType: (otpSent == true)
                                              ? TextInputType.number
                                              : TextInputType.emailAddress,
                                          obscureText: (withOtp == false && showPassword == false) ? true : false,
                                        ),
                                      ),
                                      if (withOtp == false)
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              showPassword = !showPassword;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.remove_red_eye_sharp,
                                            color: showPassword ? const Color(0xffFFD302) : null,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          // New Password field (for forgot password)
                          if (newPassword == true)
                            Column(
                              children: [
                                SizedBox(height: media.width * 0.05),
                                Container(
                                  height: media.width * 0.12,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: media.width * 0.025),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _newPassword,
                                          decoration: InputDecoration(
                                            hintText: languages[choosenLanguage]['Enter New Password'],
                                            border: InputBorder.none,
                                          ),
                                          keyboardType: TextInputType.emailAddress,
                                          obscureText: !showNewPassword,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showNewPassword = !showNewPassword;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.remove_red_eye_sharp,
                                          color: showNewPassword ? const Color(0xffFFD302) : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (_error != '')
                            Column(
                              children: [
                                SizedBox(height: media.width * 0.025),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: media.width * 0.9,
                                    minWidth: media.width * 0.5,
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xffFFFFFF).withOpacity(0.5),
                                  ),
                                  child: MyText(
                                    text: _error,
                                    size: media.width * fourteen,
                                    color: Colors.red,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    fontweight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: media.width * 0.05),
                          // Sign In Button
                          SizedBox(
                            width: media.width * 0.5,
                            height: media.height * 0.07,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _error = '';
                                  loginLoading = true;
                                });

                                if (newPassword == true) {
                                  if (_newPassword.text.length >= 8) {
                                    var val = await updatePassword(_email.text, _newPassword.text, isLoginemail);
                                    if (val == true) {
                                      withOtp = false;
                                      otpSent = false;
                                      _password.clear();
                                      _email.clear();
                                      forgotPassword = false;
                                      newPassword = false;
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: page,
                                        builder: (context) {
                                          return Container(
                                            width: media.width,
                                            padding: EdgeInsets.all(media.width * 0.05),
                                            child: MyText(
                                              text: languages[choosenLanguage]['text_password_update_successfully'],
                                              size: media.width * fourteen,
                                              maxLines: 4,
                                              color: textColor,
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      _error = val.toString();
                                    }
                                  } else {
                                    setState(() {
                                      _error = 'Password must be 8 character length';
                                    });
                                  }
                                } else if (withOtp == true) {
                                  if (otpSent == true) {
                                    if (_email.text.isNotEmpty && _password.text.isNotEmpty && _password.text.length == 6) {
                                      if (phoneAuthCheck == true) {
                                        if (isLoginemail == true) {
                                          if (forgotPassword == true) {
                                            var val = await emailVerify(_email.text, _password.text);
                                            if (val == 'success') {
                                              _password.clear();
                                              newPassword = true;
                                              showNewPassword = false;
                                            } else {
                                              _error = val;
                                            }
                                          } else {
                                            var val = await verifyUser(
                                                _email.text, 1, _password.text, '', withOtp, forgotPassword);
                                            print('verifyUser returned: $val');
                                            navigate(val);
                                          }
                                        } else {
                                          if (isCheckFireBaseOTP == true) {
                                            try {
                                              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                                                  verificationId: verId, smsCode: _password.text);
                                              await FirebaseAuth.instance.signInWithCredential(credential);
                                              String? bearerrrrr = await FirebaseAuth.instance.currentUser!.getIdToken();
                                              var verify = await verifyUser(
                                                  _email.text, 0, '', '', withOtp, forgotPassword);
                                              if (forgotPassword == true) {
                                                if (verify == true) {
                                                  _password.clear();
                                                  newPassword = true;
                                                  showNewPassword = false;
                                                }
                                              } else {
                                                navigate(verify);
                                              }
                                            } on FirebaseAuthException catch (error) {
                                              if (error.code == 'invalid-verification-code') {
                                                setState(() {
                                                  _password.clear();
                                                  _error = 'Please enter correct Otp or resend';
                                                });
                                              }
                                            }
                                          } else {
                                            var val = await validateSmsOtp(_email.text, _password.text);
                                            if (val == 'success') {
                                              var verify = await verifyUser(_email.text, 0, '', '', withOtp, forgotPassword);
                                              if (forgotPassword == true) {
                                                if (verify == true) {
                                                  _password.clear();
                                                  newPassword = true;
                                                  showNewPassword = false;
                                                }
                                              } else {
                                                navigate(verify);
                                              }
                                            } else {
                                              _error = val.toString();
                                            }
                                          }
                                        }
                                      } else {
                                        if (_password.text == '123456') {
                                          var val = await verifyUser(
                                              _email.text, (isLoginemail == true) ? 1 : 0, _password.text, '', withOtp, forgotPassword);
                                          if (forgotPassword == true) {
                                            if (val == true) {
                                              _password.clear();
                                              newPassword = true;
                                              showNewPassword = false;
                                            }
                                          } else {
                                            navigate(val);
                                          }
                                        } else {
                                          _error = 'Please enter correct otp';
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        if (_password.text.isEmpty) {
                                          _error = 'Please enter otp';
                                        } else {
                                          _error = 'Please enter correct otp';
                                        }
                                      });
                                    }
                                  } else {
                                    var exist = true;
                                    if (forgotPassword == true) {
                                      var ver = await verifyUser(_email.text, (isLoginemail == true) ? 1 : 0, _password.text, '', withOtp, forgotPassword);
                                      if (ver == true) {
                                        exist = true;
                                      } else {
                                        exist = false;
                                      }
                                    }
                                    if (exist == true) {
                                      if (isLoginemail == false) {
                                        String pattern = r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                        RegExp regExp = RegExp(pattern);
                                        if (regExp.hasMatch(_email.text) &&
                                            _email.text.length <= countries[phcode]['dial_max_length'] &&
                                            _email.text.length >= countries[phcode]['dial_min_length']) {
                                          if (isCheckFireBaseOTP) {
                                            var val = await otpCall();
                                            if (val.value == true) {
                                              await phoneAuth(countries[phcode]['dial_code'] + _email.text);
                                              phoneAuthCheck = true;
                                              _resend = false;
                                              otpSent = true;
                                              resendTimer = 60;
                                              resend();
                                            } else {
                                              phoneAuthCheck = false;
                                              RemoteNotification noti = const RemoteNotification(
                                                  title: 'Otp for Login', body: 'Login to your account with test OTP 123456');
                                              showOtpNotification(noti);
                                            }
                                            _resend = false;
                                            otpSent = true;
                                            resendTimer = 60;
                                            resend();
                                          } else {
                                            var val = await sendOTPtoMobile(_email.text, countries[phcode]['dial_code'].toString());
                                            if (val == 'success') {
                                              phoneAuthCheck = true;
                                              _resend = false;
                                              otpSent = true;
                                              resendTimer = 60;
                                              resend();
                                            } else {
                                              _error = val;
                                            }
                                          }
                                        } else {
                                          _error = 'Please enter valid mobile number';
                                        }
                                      } else {
                                        String pattern =
                                            r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                        RegExp regex = RegExp(pattern);
                                        if (regex.hasMatch(_email.text)) {
                                          phoneAuthCheck = true;
                                          var val = await sendOTPtoEmail(_email.text);
                                          if (val == 'success') {
                                            _resend = false;
                                            otpSent = true;
                                            resendTimer = 60;
                                            resend();
                                          } else {
                                            _error = val;
                                          }
                                        } else {
                                          _error = 'Please enter valid email address';
                                        }
                                      }
                                    } else {
                                      _error = (isLoginemail == false) ? 'Mobile Number doesn\'t exists' : 'Email doesn\'t exists';
                                    }
                                  }
                                } else {
                                  if (_password.text.isNotEmpty && _password.text.length >= 8 && _email.text.isNotEmpty) {
                                    String pattern = r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                    RegExp regExp = RegExp(pattern);
                                    String pattern1 =
                                        r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                    RegExp regex = RegExp(pattern1);
                                    if ((regExp.hasMatch(_email.text) &&
                                            _email.text.length <= countries[phcode]['dial_max_length'] &&
                                            _email.text.length >= countries[phcode]['dial_min_length'] &&
                                            isLoginemail == false) ||
                                        (isLoginemail == true && regex.hasMatch(_email.text))) {
                                      print('Calling verifyUser with:');
                                      print('number/email: ${_email.text}');
                                      print('login: ${(isLoginemail == true) ? 1 : 0}');
                                      print('password: ${_password.text}');
                                      print('email: ""');
                                      print('withOtp: $withOtp');
                                      print('forgotPassword: $forgotPassword');
                                      var val = await verifyUser(
                                          _email.text, (isLoginemail == true) ? 1 : 0, _password.text, '', withOtp, forgotPassword);
                                      print('verifyUser returned: $val');
                                      navigate(val);
                                    } else {
                                      if (isLoginemail == false) {
                                        _error = 'Please enter valid mobile number';
                                      } else {
                                        _error = 'please enter valid email address';
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      _error = 'Password must be 8 character length';
                                    });
                                  }
                                }
                                setState(() {
                                  loginLoading = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A373),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                (newPassword == true)
                                    ? languages[choosenLanguage]['text_update_password']
                                    : (withOtp == false)
                                        ? languages[choosenLanguage]['text_sign_in']
                                        : (otpSent == true)
                                            ? languages[choosenLanguage]['text_verify_otp']
                                            : languages[choosenLanguage]['text_get_otp'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          if (otpSent == true && newPassword == false)
                            Container(
                              alignment: Alignment.center,
                              width: media.width * 0.5,
                              height: media.width * 0.1,
                              child: (_resend == true)
                                  ? TextButton(
                                      onPressed: () async {
                                        var exist = true;
                                        if (forgotPassword == true) {
                                          var ver = await verifyUser(
                                              _email.text, (isLoginemail == true) ? 1 : 0, _password.text, '', withOtp, forgotPassword);
                                          if (ver == true) {
                                            exist = true;
                                          } else {
                                            exist = false;
                                          }
                                        }
                                        if (exist == true) {
                                          if (isLoginemail == false) {
                                            String pattern = r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                            RegExp regExp = RegExp(pattern);
                                            if (regExp.hasMatch(_email.text) &&
                                                _email.text.length <= countries[phcode]['dial_max_length'] &&
                                                _email.text.length >= countries[phcode]['dial_min_length']) {
                                              if (isCheckFireBaseOTP) {
                                                var val = await otpCall();
                                                if (val.value == true) {
                                                  await phoneAuth(countries[phcode]['dial_code'] + _email.text);
                                                  phoneAuthCheck = true;
                                                  _resend = false;
                                                  otpSent = true;
                                                  resendTimer = 60;
                                                  resend();
                                                } else {
                                                  phoneAuthCheck = false;
                                                  RemoteNotification noti = const RemoteNotification(
                                                      title: 'Otp for Login', body: 'Login to your account with test OTP 123456');
                                                  showOtpNotification(noti);
                                                }
                                                _resend = false;
                                                otpSent = true;
                                                resendTimer = 60;
                                                resend();
                                              } else {
                                                var val = await sendOTPtoMobile(
                                                    _email.text, countries[phcode]['dial_code'].toString());
                                                if (val == 'success') {
                                                  phoneAuthCheck = true;
                                                  _resend = false;
                                                  otpSent = true;
                                                  resendTimer = 60;
                                                  resend();
                                                } else {
                                                  _error = val;
                                                }
                                              }
                                            } else {
                                              _error = 'Please enter valid mobile number';
                                            }
                                          } else {
                                            String pattern =
                                                r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                            RegExp regex = RegExp(pattern);
                                            if (regex.hasMatch(_email.text)) {
                                              phoneAuthCheck = true;
                                              var val = await sendOTPtoEmail(_email.text);
                                              if (val == 'success') {
                                                _resend = false;
                                                otpSent = true;
                                                resendTimer = 60;
                                                resend();
                                              } else {
                                                _error = val;
                                              }
                                            } else {
                                              _error = 'Please enter valid email address';
                                            }
                                          }
                                        } else {
                                          _error = (isLoginemail == false) ? 'Mobile Number doesn\'t exists' : 'Email doesn\'t exists';
                                        }
                                      },
                                      child: MyText(
                                        text: languages[choosenLanguage]['text_resend_otp'],
                                        size: media.width * fourteen,
                                        textAlign: TextAlign.center,
                                        color: Colors.black,
                                      ),
                                    )
                                  : MyText(
                                      text: languages[choosenLanguage]['text_resend_otp_in']
                                          .toString()
                                          .replaceAll('1111', resendTimer.toString()),
                                      size: media.width * fourteen,
                                      textAlign: TextAlign.center,
                                      color: Colors.black,
                                    ),
                            ),
                          SizedBox(height: media.height * 0.05),
                          if (withOtp == false || forgotPassword == true)
                            SizedBox(
                              width: media.width * 0.4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), // Padding inside the container
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8), // Background color (semi-transparent white for visibility)
                                  borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _error = '';
                                      if (forgotPassword == true) {
                                        _email.clear();
                                        _password.clear();
                                        isLoginemail = true;
                                        otpSent = false;
                                        withOtp = false;
                                        forgotPassword = false;
                                        newPassword = false;
                                      } else {
                                        _email.clear();
                                        _password.clear();
                                        isLoginemail = true;
                                        otpSent = false;
                                        withOtp = true;
                                        forgotPassword = true;
                                      }
                                    });
                                  },
                                  child: MyText(
                                    text: (forgotPassword == true)
                                        ? languages[choosenLanguage]['text_sign_in']
                                        : languages[choosenLanguage]['text_forgot_password'],
                                    size: media.width * fourteen,
                                    textAlign: TextAlign.center,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: media.width * 0.05),
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.pop(context); // Go back to LandingPage
                          //   },
                          //   child: MyText(
                          //     text: languages[choosenLanguage]['text_back'] ?? 'Retour',
                          //     size: media.width * fourteen,
                          //     color: Colors.black,
                          //     // decoration: TextDecoration.underline,
                          //   ),
                          // ),
                          // Add some extra space at the bottom to ensure content doesn't overlap with the image
                          SizedBox(height: media.height * 0.4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryPicker(Size media) {
    String searchVal = '';
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(media.width * 0.05),
          width: media.width,
          color: page,
          child: Directionality(
            textDirection: (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 40,
                  width: media.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: (languageDirection == 'rtl')
                          ? EdgeInsets.only(bottom: media.width * 0.035)
                          : EdgeInsets.only(bottom: media.width * 0.04),
                      border: InputBorder.none,
                      hintText: languages[choosenLanguage]['text_search'],
                      hintStyle: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: hintColor),
                    ),
                    style: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: textColor),
                    onChanged: (val) {
                      setState(() {
                        searchVal = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: countries.asMap().map((i, value) {
                        return MapEntry(
                          i,
                          SizedBox(
                            width: media.width * 0.9,
                            child: (searchVal == '' && countries[i]['flag'] != null)
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        phcode = i;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      color: page,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.network(countries[i]['flag']),
                                              SizedBox(width: media.width * 0.02),
                                              SizedBox(
                                                width: media.width * 0.4,
                                                child: MyText(
                                                  text: countries[i]['name'],
                                                  size: media.width * sixteen,
                                                ),
                                              ),
                                            ],
                                          ),
                                          MyText(
                                            text: countries[i]['dial_code'],
                                            size: media.width * sixteen,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : (countries[i]['flag'] != null && countries[i]['name'].toLowerCase().contains(searchVal.toLowerCase()))
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            phcode = i;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                          color: page,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.network(countries[i]['flag']),
                                                  SizedBox(width: media.width * 0.02),
                                                  SizedBox(
                                                    width: media.width * 0.4,
                                                    child: MyText(
                                                      text: countries[i]['name'],
                                                      size: media.width * sixteen,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              MyText(
                                                text: countries[i]['dial_code'],
                                                size: media.width * sixteen,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                          ),
                        );
                      }).values.toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}