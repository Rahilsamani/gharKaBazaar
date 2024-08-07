import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:macstore/views/screens/main_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;

  User get user => _user.value!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to create a new user
  Future<String> createNewUser(
    String email,
    String fullName,
    String password,
    String phoneNumber,
  ) async {
    String res = 'some error occurred';

    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore.collection('buyers').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'profileImage': '',
        'email': email,
        'phoneNumber': phoneNumber,
        'uid': userCredential.user!.uid,
        'pinCode ': "",
        'locality': "",
        'city': '',
        'state': '',
        'ban': false,
      });

      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  // Function to log in a user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    Map<String, dynamic> res = {'status': 'error', 'role': ''};

    try {
      // Sign in user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve user details from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('buyers')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        bool isBanned = userDoc['ban'] ?? false;
        if (isBanned) {
          // If user is banned, set status to error and provide a message
          res = {
            'status': 'error',
            'message': 'You are banned from logging in.',
          };
        } else {
          // If user exists in Firestore and is not banned, set status to success
          res = {
            'status': 'success',
            'role': 'buyer',
          };
        }
      } else {
        res['status'] = 'Invalid user role or user not found.';
      }
    } catch (e) {
      res['status'] = e.toString();
    }

    return res;
  }

  // Function to change user password
  Future<bool> changePassword(BuildContext context, String password) async {
    try {
      // Get the current authenticated user
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Update user password
        await currentUser.updatePassword(password);

        // Navigate to MainScreen and show a success message
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password Changed'),
          backgroundColor: Colors.blue,
        ));
        print('Password Changed');
        return true;
      } else {
        print('User is not authenticated');
        return false;
      }
    } on FirebaseAuthException catch (error) {
      // Handle FirebaseAuthException and show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.code.toString()),
        backgroundColor: Colors.blue,
      ));
      print(error.code.toString());
      return false;
    }
  }
}
