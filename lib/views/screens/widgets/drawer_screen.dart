import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:macstore/controllers/change_password_screen.dart';
import 'package:macstore/vendor/authentication/logout_confirmation_modal.dart';
import 'package:macstore/vendor/authentication/vendor_login_Screen.dart';
import 'package:macstore/views/screens/authentication_screens/login_screen.dart';
import 'package:macstore/views/screens/inner_screen/order_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import "../bottomNav_screens/acount_screen.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentFullName;
  final String currentProfileImage;

  const EditProfileScreen({
    Key? key,
    required this.currentFullName,
    required this.currentProfileImage,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _profileImageController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.currentFullName);
    _profileImageController =
        TextEditingController(text: widget.currentProfileImage);
  }

  _uploadProfileImageToStorage(Uint8List? image) async {
    Reference ref =
        _storage.ref().child('profilePics').child(_auth.currentUser!.uid);

    UploadTask uploadTask = ref.putData(image!);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  pickProfileImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();

    XFile? _file = await _imagePicker.pickImage(source: source);

    if (_file != null) {
      return await _file.readAsBytes();
    } else {
      print('No Image Selected');
    }
  }

  selectGalleryImage() async {
    Uint8List im = await pickProfileImage(ImageSource.gallery);

    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Edit Profile",
        style: GoogleFonts.roboto(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: "Full Name",
              labelStyle: GoogleFonts.roboto(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _profileImageController,
                  decoration: InputDecoration(
                    labelText: "Profile Image URL",
                    labelStyle: GoogleFonts.roboto(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  selectGalleryImage();
                },
                icon: Icon(Icons.image),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Cancel",
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            // Get the current user ID
            String userId = FirebaseAuth.instance.currentUser!.uid;

            // Create a reference to the user's document in Firestore
            DocumentReference userRef =
                FirebaseFirestore.instance.collection('buyers').doc(userId);

            // Update the user's data in Firestore

            String downloadUrl = await _uploadProfileImageToStorage(_image);
            await userRef.update({
              'fullName': _fullNameController.text,
              'profileImage': downloadUrl,
            }).whenComplete(() {
              setState(() {
                _isLoading = false;
              });
            });

            // Close the popup
            Navigator.of(context).pop();
          },
          child: _isLoading
              ? CircularProgressIndicator()
              : Text(
                  "Save",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}

class DrawerScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Future<void> sendMessageOnWhatsapp() async {
      final number = dotenv.env['WHATSAPP_CONTACT'];
      final message = "Hello to Ghar ka Bazar";
      final urlString =
          'https://wa.me/$number?text=${Uri.encodeComponent(message)}';

      final uri = Uri.parse(urlString);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $urlString';
      }
    }

    void _showLogoutConfirmationDialog() async {
      bool confirmLogout = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return LogoutConfirmationDialog();
        },
      );

      if (confirmLogout) {
        await _auth.signOut().whenComplete(() async {
          var sharedPref = await SharedPreferences.getInstance();
          sharedPref.setBool('login', false);
          sharedPref.setBool(VendorLoginScreenState.IsVendor, false);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return LoginScreen();
          }));
        });
      }
    }

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF3C55EF),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/app_logo.jpeg',
                  width: 60,
                  height: 60,
                ),
                SizedBox(width: 8),
                Text(
                  'Ghar Ka Bazar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              // Navigate to the order screen
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return OrderScreen();
              }));
            },
            leading: Image.asset('assets/icons/orders.png'),
            title: Text(
              'Track your order',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () {
              // Navigate to the terms and conditions screen
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TermsAndConditionsScreen();
              }));
            },
            leading: Image.asset('assets/icons/history.png'),
            title: Text(
              'Terms and Conditions ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () {
              // Navigate to the change password screen
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ChangePasswordScreen();
              }));
            },
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffF4F7FC),
              ),
              child: Image.asset(
                'assets/icons/reset_password.png',
                color: Color(0xff223150),
                scale: 15,
              ),
            ),
            title: Text(
              'Reset Password ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () {
              // Send message on WhatsApp
              sendMessageOnWhatsapp();
            },
            leading: Image.asset('assets/icons/help.png'),
            title: Text(
              'Help ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () {
              // Show logout confirmation dialog
              _showLogoutConfirmationDialog();
            },
            leading: Image.asset('assets/icons/logout.png'),
            title: Text(
              'Logout ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
