// signup_page.dart
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/functions/notifications.dart';
import 'package:flutter_user/pages/login/login.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import 'agreement.dart';
import 'whatsapp_connect_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  bool loginLoading = false;
  String _error = '';
  bool showPassword = false;
  bool otpSent = false;
  bool mobileVerified = false;
  dynamic proImageFile1;
  ImagePicker picker = ImagePicker();
  bool pickImage = false;
  bool privacyConsent = false;

  @override
  void initState() {
    super.initState();
    proImageFile1 = null;
    gender = '';
    countryCode();
  }

  countryCode() async {
    var result = await getCountryCode();
    setState(() {
      loginLoading = false;
    });
  }

  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.photos.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
      }
    }
    return status;
  }

  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        proImageFile1 = pickedFile?.path;
        pickImage = false;
      });
    }
  }

  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      setState(() {
        proImageFile1 = pickedFile?.path;
        pickImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              height: media.height,
              width: media.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/login_pg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Logo at the top
                    Container(
                      padding: EdgeInsets.only(top: media.height * 0.05),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/main_logo.png',
                            height: media.width * 0.2,
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
                          SizedBox(height: media.width * 0.05),
                          // Name field
                          Container(
                            height: media.width * 0.12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: media.width * 0.025),
                            child: TextField(
                              controller: _name,
                              decoration: InputDecoration(
                                hintText: languages[choosenLanguage]['text_name'],
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: media.width * 0.07),
                          // Mobile field
                          Container(
                            height: media.width * 0.12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: media.width * 0.025),
                            child: Row(
                              children: [
                                if (phcode != null)
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
                                    controller: _mobile,
                                    decoration: InputDecoration(
                                      hintText: languages[choosenLanguage]['text_mobile'],
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: media.width * 0.07),
                          // Gender selection
                          Container(
                            width: media.width * 0.8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: media.width * 0.12,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: media.width * 0.025),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: gender.isEmpty ? null : gender,
                                      hint: Text(
                                        languages[choosenLanguage]['text_select_gender'] ?? 'Select Gender',
                                        style: GoogleFonts.roboto(
                                          fontSize: media.width * fourteen,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                      icon: const Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: GoogleFonts.roboto(
                                        fontSize: media.width * fourteen,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          gender = newValue!;
                                        });
                                      },
                                      items: <String>['male', 'female', 'others']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value == 'male'
                                                ? languages[choosenLanguage]['text_male']
                                                : value == 'female'
                                                    ? languages[choosenLanguage]['text_female']
                                                    : languages[choosenLanguage]['text_others'],
                                            style: GoogleFonts.roboto(
                                              fontSize: media.width * fourteen,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: media.width * 0.07),
                          // Privacy consent checkbox and text
                          Container(
                            width: media.width * 0.8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First part - informational text without checkbox (only visible when checkbox is unchecked)
                                if (!privacyConsent)
                                  Text(
                                    'La société Atlas Mobility solutions traite vos données pour la mise en relation des chauffeurs de taxi et des passagers. Ce traitement a fait l\'objet d\'une autorisation auprès de la CNDP sous le numéro A-PO-134/2025 du 15/03/2025',
                                    style: TextStyle(
                                      fontSize: media.width * 0.03,
                                      color: Colors.black87,
                                    ),
                                  ),
                                if (!privacyConsent) SizedBox(height: 12),
                                // Second part - checkbox with terms acceptance
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: privacyConsent,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            privacyConsent = value ?? false;
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to terms and conditions page
                                          // You can implement this based on your app's navigation
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'J\'ai lu et J\'accepte les ',
                                            style: TextStyle(
                                              fontSize: media.width * 0.03,
                                              color: Colors.black87,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Conditions Générales d\'Utilisation',
                                                style: TextStyle(
                                                  fontSize: media.width * 0.03,
                                                  color: const Color(0xFFD4A373),
                                                  fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ', notamment la mention relative à la protection des données personnelles.',
                                                style: TextStyle(
                                                  fontSize: media.width * 0.03,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: media.width * 0.07),
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
                                    fontweight: FontWeight.w500, // decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: media.width * 0.07),
                          // WhatsApp connection button (only visible when checkbox is checked)
                          if (privacyConsent)
                            Container(
                              width: media.width * 0.8,
                              height: media.height * 0.07,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Check if the form is valid before navigating
                                  if (_name.text.isNotEmpty &&
                                      _mobile.text.isNotEmpty &&
                                      gender.isNotEmpty &&
                                      gender != '') {
                                    String pattern = r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                    RegExp regExp = RegExp(pattern);
                                    if (regExp.hasMatch(_mobile.text) &&
                                        _mobile.text.length <= countries[phcode]['dial_max_length'] &&
                                        _mobile.text.length >= countries[phcode]['dial_min_length']) {
                                      // Save the form data
                                      name = _name.text;
                                      phnumber = _mobile.text;
                                      
                                      // Proceed to WhatsApp connect page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WhatsappConnectPage(
                                            phoneNumber: _mobile.text,
                                          ),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _error = languages[choosenLanguage]['text_in_valid_number_enter'];
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _error = languages[choosenLanguage]['text_fill_form'];
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB5986A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Se connecter via Whatsapp",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: media.width * 0.07),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Image Picker Bottom Sheet
            if (pickImage == true)
              Positioned(
                bottom: 0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pickImage = false;
                    });
                  },
                  child: Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    color: Colors.transparent.withOpacity(0.6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(media.width * 0.05),
                          width: media.width * 1,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                            border: Border.all(color: borderLines, width: 1.2),
                            color: page,
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: media.width * 0.02,
                                width: media.width * 0.15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(media.width * 0.01),
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: media.width * 0.05),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          pickImageFromCamera();
                                        },
                                        child: Container(
                                          height: media.width * 0.171,
                                          width: media.width * 0.171,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: borderLines, width: 1.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.camera_alt_outlined,
                                            size: media.width * 0.064,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: media.width * 0.02),
                                      MyText(
                                        text: languages[choosenLanguage]['text_camera'],
                                        size: media.width * ten,
                                        color: textColor.withOpacity(0.4),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          pickImageFromGallery();
                                        },
                                        child: Container(
                                          height: media.width * 0.171,
                                          width: media.width * 0.171,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: borderLines, width: 1.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: media.width * 0.064,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: media.width * 0.02),
                                      MyText(
                                        text: languages[choosenLanguage]['text_gallery'],
                                        size: media.width * ten,
                                        color: textColor.withOpacity(0.4), // decoration: TextDecoration.none,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (loginLoading == true) const Positioned(top: 0, child: Loading()),
          ],
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
                                                  size: media.width * sixteen, // decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ],
                                          ),
                                          MyText(
                                            text: countries[i]['dial_code'],
                                            size: media.width * sixteen, // decoration: TextDecoration.none,
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
                                                      size: media.width * sixteen, // decoration: TextDecoration.none,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              MyText(
                                                text: countries[i]['dial_code'],
                                                size: media.width * sixteen, // decoration: TextDecoration.none,
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