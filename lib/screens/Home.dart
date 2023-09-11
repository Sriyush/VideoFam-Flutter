import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:videofam/screens/otpver.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _phoneNumberController = TextEditingController();
  bool _showLoadingAnimation = true;

  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showLoadingAnimation = false;
      });
    });
  }

  Future<void> _sendOtp(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: $e');
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Otpver(verificationId: verificationId, phoneNumber: phoneNumber ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
        },
      );
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Logo2.png',
                      height: 300, // Replace with your image path
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: !_showLoadingAnimation,
              child: Column(
                children: [
                  Text(
                    'Login or Signup',
                    style: TextStyle(
                      fontFamily: 'lexend',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 300,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          '+91',
                          style: TextStyle(
                            fontFamily: 'lexend',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter Phone Number',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 20),
                  Material(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        // Handle continue action
                        String phoneNumber = "+91" + _phoneNumberController.text;
                        _sendOtp(phoneNumber);
                      },
                      child: Container(
                        width: 350,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        alignment: Alignment.center,
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
            child: Visibility(
              visible: _showLoadingAnimation,
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.black,
                size: 50,
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
