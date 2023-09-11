import 'dart:async';

import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:videofam/screens/postvid.dart';
import 'package:videofam/screens/recvid.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoDescription;
  final String videotitle;
  VideoPlayerScreen({
    required this.videoUrl,
    required this.videoDescription,
    required this.videotitle, // Pass the description
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  TextEditingController _searchController = TextEditingController();
  //  Widget currentscreen =HomeScreen();
  int currenttab =0;
  late VideoPlayerController _controller;
  List<String> comments = [];
  bool _showControls = true;
  late DatabaseReference _videoCommentsRef;
  late Query dbref;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });

    _commentController = TextEditingController(); // Initialize the controller

    // Create a unique node for each video's comments
    _videoCommentsRef =
        FirebaseDatabase.instance.reference().child('video_comments').child(widget.videotitle);
    dbref = FirebaseDatabase.instance.ref().child('video_comments').child(widget.videotitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.videotitle,
        style: TextStyle(
          fontFamily: 'lexend',
          color: Colors.black54,

        ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
         actions: [
            IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications,
            color: Colors.black54,
          ),
        ),
         ],
          iconTheme: IconThemeData(
            color: Colors.black54, // Set the color of the back button
          ),
      ),
      body: Column(
        children: [
          // Container(
          //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(10),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey.withOpacity(0.5),
          //             spreadRadius: 1,
          //             blurRadius: 5,
          //             offset: Offset(0, 3), // changes position of shadow
          //           ),
          //         ],
          //       ),
          //       child: Row(
          //         children: [
          //           Expanded(
          //             child: TextField(
          //               controller: _searchController,
          //               onChanged: (value) {
          //                 setState(() {});
          //               },
          //               decoration: InputDecoration(
          //                 border: InputBorder.none,
          //                 hintText: 'Search videos...',
          //                 hintStyle: TextStyle(
          //                   fontSize: 16,
          //                   // color: Colors.grey,
          //                 ),
          //               ),
          //             ),
          //           ),
          //           Icon(Icons.search, color: Colors.grey),
          //         ],
          //       ),
          //     ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: Container(
              height: 200, // Adjust the height as needed
              child: Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  if (_showControls)
                    Center(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videotitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 20),
                    SizedBox(width: 4),
                    Text("Likes"),
                    SizedBox(width: 16),
                    Icon(Icons.thumb_down, size: 20),
                    SizedBox(width: 4),
                    Text("Dislikes"),
                  ],
                ),
                SizedBox(height: 8),
                Text(widget.videoDescription),
                SizedBox(height: 16), // Adjust spacing as needed
                TextField(
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        }
                        String newComment = "Anonymous: " + _commentController.text;
                        _videoCommentsRef.push().set({
                          'comment': newComment,
                          'timestamp': ServerValue.timestamp,
                        });
                        setState(() {
                          comments.add(newComment);
                          _commentController.clear();
                        });
                      },
                      icon: Icon(Icons.send),
                    ),
                  ),
                  controller: _commentController,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Viewer Comments-",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: FirebaseAnimatedList(
              query: dbref,
              itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
                Map commentData = snapshot.value as Map;
                String commentText = commentData['comment'];
                return ListTile(
                  title: Text(commentText),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    fullscreenDialog: true, builder: (_) => PostVideoScreen()));
          },
          
          backgroundColor: Colors.black87,
          child: Icon(
            Icons.video_call_rounded,
            color: Colors.white,
          ),
          elevation: 0,
        ),
         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
         bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[ 
              Row( 
                
                children: [
                  // SizedBox(width: 20,),
                  MaterialButton(
                    minWidth: 20, 
                    onPressed: () {
                      setState(() {
                        // currentscreen=HomeScreen();
                        currenttab=0;
                      });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home,
                      color:currenttab ==0? Colors.black87:Colors.grey
                      ,size: 25,
                      ),
                      Text('Home',
                       style: TextStyle(
                        fontFamily: 'lexend',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color:currenttab ==0? Colors.black87:Colors.grey
                      ),
                      )
                    ],
                  ),
                  ),
                ],
              ),
              Row( 
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(width: 10,),
                  MaterialButton(
                    minWidth: 20, 
                    onPressed: () {
                      setState(() {
                        // currentscreen=Home();
                        currenttab=3;
                      });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_pin,size: 25,
                      color:currenttab ==3? Colors.black87:Colors.grey
                      ),
                      Text('Profile',
                       style: TextStyle(
                        fontFamily: 'lexend',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color:currenttab ==3? Colors.black87:Colors.grey
                      ),
                      )
                    ],
                  ),
                  ),
                  
                ],
              )
              
            ],
          ),
        ),
        ),
    );
  }

  TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
