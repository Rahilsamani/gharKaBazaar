import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:macstore/controllers/auth_controller.dart';
import 'package:macstore/views/screens/authentication_screens/login_screen.dart';
import 'package:macstore/views/screens/widgets/button_widget.dart';
import 'package:macstore/views/screens/widgets/custom_text_Field.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  late String email;
  late String fullName;
  late String password;
  late String phoneNumber;

  registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String res = await _authController.createNewUser(
        email,
        fullName,
        password,
        phoneNumber,
      );

      setState(() {
        _isLoading = false;
      });

      if (res == 'success') {
        Get.to(LoginScreen());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Congratulations! Your account has been created.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Create Your Account",
                      style: GoogleFonts.roboto(
                        color: Color(0xFF0d120E),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        fontSize: 23,
                      ),
                    ),
                    Text(
                      'To Explore the world exclusives',
                      style: GoogleFonts.roboto(
                        color: Color(0xFF0d120E),
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Image.asset(
                      'assets/images/Illustration.png',
                      width: 200,
                      height: 200,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0, left: 8.0),
                        child: Text(
                          'Email',
                          style: GoogleFonts.getFont(
                            'Nunito Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    CustomTextField(
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your email';
                        } else {
                          return null;
                        }
                      },
                      label: 'Enter your email',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/email.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      text: 'enter email',
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0, left: 8.0),
                        child: Text(
                          'Full Name',
                          style: GoogleFonts.getFont(
                            'Nunito Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    CustomTextField(
                      onChanged: (value) {
                        fullName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your Full Name';
                        } else {
                          return null;
                        }
                      },
                      label: 'Enter your Full Name',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/user.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      text: 'enter email',
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0, left: 8.0),
                        child: Text(
                          'Phone Number',
                          style: GoogleFonts.getFont(
                            'Nunito Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    CustomTextField(
                      onChanged: (value) {
                        phoneNumber = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your phone number';
                        } else {
                          return null;
                        }
                      },
                      label: 'Enter your phone number',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/phone.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      text: 'enter phone number',
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0, left: 8.0),
                        child: Text(
                          'Password',
                          style: GoogleFonts.getFont(
                            'Nunito Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    CustomTextField(
                      isPassword: true,
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your password';
                        } else {
                          return null;
                        }
                      },
                      label: 'Enter your password',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/password.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      text: 'enter password',
                    ),
                    ButtonWidgets(
                      isLoading: _isLoading ? true : false,
                      buttonChange: () {
                        if (_formKey.currentState!.validate()) {
                          registerUser();
                        } else {
                          print('failed');
                        }
                      },
                      buttonTitle: 'Sign Up',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login  account?',
                          style: GoogleFonts.roboto(),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(LoginScreen());
                          },
                          child: Text(
                            'Login?',
                            style: GoogleFonts.roboto(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
