import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:videofam/screens/recvid.dart';

class ss extends StatefulWidget {
  const ss({super.key});

  @override
  State<ss> createState() => _ssState();
}

class _ssState extends State<ss> {
  @override
  Widget build(BuildContext context) {
    Timer(
            Duration(seconds: 3),
                () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen())));
    return Scaffold(
      body: SingleChildScrollView(child: Column(
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
            SizedBox(height: 10,),
            Container(
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.black,
                size: 50,
              ),
            ),
        ],
      )),
    );
  }
}