import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:videofam/main.dart';
import 'package:videofam/screens/recvid.dart';
class Otpver extends StatefulWidget {
  final String verificationId;
  const Otpver({required this.verificationId, Key? key}) : super(key: key);

  @override
  State<Otpver> createState() => _OtpverState();
}

class _OtpverState extends State<Otpver> {
   bool otpSent = true;
   final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _otpController = TextEditingController();
  void _changeText() {
    setState(() {
      otpSent = false;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        otpSent = true;
      });
    });
  }
  void _verifyOTP(String otp) async {
  try {
    await _auth.signInWithCredential(PhoneAuthProvider.credential(
      verificationId: widget.verificationId, // Use the actual verification ID
      smsCode: otp,
    ));

    // OTP verification successful, navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  } catch (e) {
    // Handle OTP verification failure
    print("OTP verification failed: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
  width: 72,
  height: 72,
  textStyle: TextStyle(fontSize: 18, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.black),
    borderRadius: BorderRadius.circular(20),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
  borderRadius: BorderRadius.circular(8),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration?.copyWith(
    color: Color.fromRGBO(234, 239, 243, 1),
  ),
);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Color(0xFFF7F6F0),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'OTP Verification',
          style: TextStyle(
            fontFamily: 'lexend',
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Request focus on a hidden text field to show the keyboard
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          color: Color(0xFFF7F6F0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 4),
              Center(
                child: Text(
                  otpSent
                      ? 'We have sent a verification code to'
                      : 'OTP ReSent- pls check',
                  style: TextStyle(
                    fontFamily: 'lexend',
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF545454),
                  ),
                ),
              ),
              // SizedBox(height: 9),
              SizedBox(height: 50),
              Pinput(
                length: 6,
                 controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                onCompleted: (pin) => _verifyOTP(pin),
              ),
              SizedBox(height: 25),
              TextButton(
                onPressed: () {
                  _verifyOTP(_otpController.text); 
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
             Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(17.5, 0, 16.5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 7, 0),
                        child: Text(
                          otpSent
                              ? 'Didn’t receive code?'
                              : 'OTP Sent Successfully',
                          style: TextStyle(
                            fontFamily: 'lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 0.5,
                            color: Color(0xFF010F07),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _changeText();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          otpSent ? 'Resend Again.' : '',
                          style: TextStyle(
                            fontFamily: 'lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 0.5,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      );
    // );
  }
}