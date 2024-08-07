import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/button_widget.dart';
import '../widgets/custom_text_Field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  late String email;
  bool _isLoading = false;

  Future<void> passwordReset() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset link sent! Check your email'),
        backgroundColor: Colors.blue,
      ));
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication exception (error)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'An error occurred'),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your Email and we will send you a password reset link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 60,
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
            SizedBox(
              height: 30,
            ),
            ButtonWidgets(
              isLoading: _isLoading,
              buttonChange: passwordReset,
              buttonTitle: 'Reset Password',
            ),
          ],
        ),
      ),
    );
  }
}
