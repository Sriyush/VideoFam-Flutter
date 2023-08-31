
// import 'package:blackcoffer/widgets/post_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videofam/screens/postvid.dart';
import 'package:videofam/screens/videoplay.dart';
import 'package:videofam/utils/videoscard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget currentscreen =HomeScreen();
  int currenttab =0;
  TextEditingController _searchController = TextEditingController();
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black87)
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "VideoFam",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.black87,
          elevation: 0,
          actions: [
            IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications,
            color: Colors.white,
          ),
        ),
          ]
          
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
             Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search videos...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            // color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.grey),
                  ],
                ),
              ),
              Container(
                child: Center(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("posts").snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2,),
                          );
                        }
                        final filteredData = snapshot.data!.docs.where((doc) {
                        final title = doc.data()['title'].toString().toLowerCase();
                        final searchQuery = _searchController.text.toLowerCase();
                        return title.contains(searchQuery);
                      }).toList();
                        return   ListView.builder(
                            itemCount:filteredData.length,
                            shrinkWrap: true,
                            primary: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) =>
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayerScreen(
                                          videoUrl: snapshot.data!.docs[index].data()['videoUrl'],
                                          videoDescription: snapshot.data!.docs[index].data()['des'],
                                          videotitle: snapshot.data!.docs[index].data()['title'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(

                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                                        child: VideoCards(
                                          snap: snapshot.data!.docs[index].data(),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                );

                      }
                  ),
                ),
              ),
            ],
          ),
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
                        currentscreen=HomeScreen();
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
      ),
    );
  }
}
