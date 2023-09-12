import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package
import 'package:videofam/firebase/logout.dart';
import 'package:videofam/screens/postvid.dart';
import 'package:videofam/screens/profile.dart';
import 'package:videofam/screens/videoplay.dart';
import 'package:videofam/utils/videoscard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
Widget currentscreen =HomeScreen();
  int currenttab =0;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.black87),
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          title: Text(
            "VideoFam",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'lexend',
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black12,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                AuthenticationHelper.handleLogout(context);
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _showCannotGoBackSnackbar();
            },
          ),
        ),
        
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                height: 50,
                width: MediaQuery.of(context).size.width / 1.1,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 5),
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
                            fontFamily: 'lexend',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.black),
                  ],
                ),
              ),
              Container(
                child: Center(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("posts").snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show shimmer effect for at least 2 seconds
                        return FutureBuilder(
                          future: Future.delayed(Duration(seconds: 2)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return buildShimmerVideoCards();
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        );
                      }

                      final filteredData = snapshot.data!.docs.where((doc) {
                        final title = doc.data()['title'].toString().toLowerCase();
                        final searchQuery = _searchController.text.toLowerCase();
                        return title.contains(searchQuery);
                      }).toList();

                      if (filteredData.isNotEmpty) {
                        return buildActualVideoCards(filteredData);
                      } else {
                        return Center(
                          child: Text("No videos found.",
                          style: TextStyle(
                            fontFamily: 'lexend',
                            color: Colors.white,
                          ),
                          ),
                        );
                      }
                    },
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
                fullscreenDialog: true,
                builder: (_) => PostVideoScreen(),
              ),
            );
          },
          backgroundColor: Colors.white,
          child: Icon(
            Icons.video_call_rounded,
            color: Colors.black,
          ),
          elevation: 0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 20,
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    MaterialButton(
                      minWidth: 20,
                      onPressed: () {
                        setState(() {
                          currentscreen = HomeScreen();
                          currenttab = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home,
                            color: currenttab == 0 ? Colors.black87 : Colors.grey,
                            size: 25,
                          ),
                          Text(
                            'Home',
                            style: TextStyle(
                              fontFamily: 'lexend',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: currenttab == 0 ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MaterialButton(
                      minWidth: 20,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_pin,
                            size: 25,
                            color: currenttab == 2 ? Colors.black87 : Colors.grey,
                          ),
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontFamily: 'lexend',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: currenttab == 2 ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCannotGoBackSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You can't go back at this stage."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget buildShimmerVideoCards() {
    return ListView.builder(
      itemCount: 5, // You can adjust the number of shimmering placeholders as needed
      shrinkWrap: true,
      primary: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return ShimmerVideoCard(); // Create a ShimmerVideoCard widget
      },
    );
  }

  Widget buildActualVideoCards(List<QueryDocumentSnapshot<Map<String, dynamic>>> data) {
    return ListView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      primary: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  videoUrl: data[index].data()['videoUrl'],
                  videoDescription: data[index].data()['des'],
                  videotitle: data[index].data()['title'],
                ),
              ),
            );
          },
          child: Container(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: VideoCards(
                  snap: data[index].data(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShimmerVideoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: Duration(seconds: 2), // Duration of the shimmer animation
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 200.0,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                width: 100.0,
                height: 10.0,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                width: 50.0,
                height: 10.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
