import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:macstore/controllers/auth_controller.dart';
import '../views/screens/widgets/button_widget.dart';
import '../views/screens/widgets/custom_text_Field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late String newPassword;
  late String confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                "Change Password",
                style: GoogleFonts.roboto(
                  color: Color(0xFF0d120E),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  fontSize: 23,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, left: 8.0),
                  child: Text(
                    'New Password',
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
                  newPassword = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your password';
                  } else {
                    return null;
                  }
                },
                label: 'Enter your new password',
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
              SizedBox(height: 30),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, left: 8.0),
                  child: Text(
                    'Confirm New Password',
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
                  confirmPassword = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your password';
                  } else {
                    return null;
                  }
                },
                label: 'Enter confirm password',
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
              SizedBox(
                height: 30,
              ),
              ButtonWidgets(
                isLoading: false,
                buttonChange: () async {
                  String message = "";
                  bool result = false;

                  if (newPassword.isEmpty) {
                    message = 'New password is Empty';
                  } else if (confirmPassword.isEmpty) {
                    message = 'Confirm password is Empty';
                  } else if (confirmPassword == newPassword) {
                    result = await AuthController.instance
                        .changePassword(context, newPassword);
                  } else {
                    message = 'Confirm password is not matching';
                  }

                  print('Result --> $result');
                  if (message != "") {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.blue,
                    ));
                  }
                },
                buttonTitle: 'Update',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
