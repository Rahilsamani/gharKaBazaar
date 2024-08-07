import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Logout",
        style: GoogleFonts.roboto(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "Are you sure you want to logout?",
        style: GoogleFonts.roboto(
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Cancel logout
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
          onPressed: () {
            Navigator.of(context).pop(true); // Confirm logout
          },
          child: Text(
            "Logout",
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
