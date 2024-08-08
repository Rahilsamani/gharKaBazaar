import 'package:flutter/material.dart';
import 'package:macstore/views/screens/inner_screen/search_screen.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.155,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Stack(
        children: [
          Image.asset(
            'assets/icons/searchBanner.jpeg',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 50,
                child: TextField(
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.center,
                  autocorrect: false,
                  maxLines: 1,
                  minLines: null,
                  cursorRadius: const Radius.circular(2),
                  cursorColor: const Color(0xFF5C69E5),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                    hintText: 'Enter text',
                    hintStyle: const TextStyle(
                      color: Color(0xFF7F7F7F),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                    hintMaxLines: 1,
                    errorStyle: const TextStyle(
                      color: Color(0xFFFF0000),
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
                    errorMaxLines: 1,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 28,
                      color: Colors.black54,
                    ),
                    suffixIcon: Image.asset('assets/images/app_logo.jpeg'),
                    filled: true,
                    fillColor: Colors.white,
                    focusColor: Colors.black,
                    hoverColor: const Color(0x197F7F7F),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SearchScreen();
                    }));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
