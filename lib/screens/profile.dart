import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:videofam/firebase/logout.dart';
import 'package:videofam/screens/postvid.dart';
import 'package:videofam/screens/recvid.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class UserProfile {
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
  });
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Please Update Your name';
  String email = 'Please Update Your Email';
  String? userPhoneNumber;
  String profileImageUrl = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isEditing = false; 
  late DatabaseReference info;
  Widget currentscreen = ProfilePage();
  int currenttab = 2;
  File? _profileImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userPhoneNumber = user.phoneNumber;
      info = FirebaseDatabase.instance.ref().child('userProfiles').child('$userPhoneNumber');
      print('$userPhoneNumber');
      loadUserProfile(userPhoneNumber);
    } else {
      print('User is not authenticated.');
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      final imageUrl = await uploadProfileImage(_profileImage!);

      if (imageUrl != null) {
        updateProfileImageUrl(imageUrl);
      }
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child('profile_images').child('$userPhoneNumber.jpg');
      final uploadTask = storageReference.putFile(imageFile);
      final taskSnapshot = await uploadTask.whenComplete(() => null);
      final downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (error) {
      print('Error uploading profile image: $error');
      return null;
    }
  }

  void updateProfileImageUrl(String imageUrl) {
    final databaseRef = FirebaseDatabase.instance.reference();
    databaseRef.child('userProfiles/$userPhoneNumber').update({
      'profileImageUrl': imageUrl,
    });
  }

  void updateProfile() {
    if (isEditing) {
      final updatedName = nameController.text;
      final updatedEmail = emailController.text;

      if (updatedName.isNotEmpty && updatedEmail.isNotEmpty) {
        final updatedProfile = UserProfile(
          name: updatedName,
          email: updatedEmail,
          phoneNumber: userPhoneNumber!,
          profileImageUrl: profileImageUrl,
        );
        saveUserProfile(updatedProfile);
        setState(() {
          name = updatedName;
          email = updatedEmail;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Name and email cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveUserProfile(UserProfile userProfile) {
    final databaseRef = FirebaseDatabase.instance.reference();
    databaseRef.child('userProfiles/${userProfile.phoneNumber}').set({
      'name': userProfile.name,
      'email': userProfile.email,
      'profileImageUrl': userProfile.profileImageUrl,
    });
  }

  void loadUserProfile(String? phoneNumber) {
    if (phoneNumber != null) {
      info.once().then((DatabaseEvent event) {
        final data = event.snapshot.value;
        print('Data from Firebase: $data');
        if (data is Map) {
          setState(() {
            name = data['name'] ?? '';
            email = data['email'] ?? '';
            profileImageUrl = data['profileImageUrl'] ?? '';
          });
        } else {
          print('User profile data not found in the database for userPhoneNumber: $userPhoneNumber');
        }
      }).catchError((error) {
        print('Error loading user profile: $error');
      });
    } else {
      print('User phone number is null');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(
            fontFamily: 'lexend',
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: const Text('Feedback'),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: const Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 1) {
                AuthenticationHelper.handleLogout(context);
              }
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        leading: WillPopScope(
          onWillPop: () async {
            if (isEditing) {
              setState(() {
                isEditing = false;
              });
              return false;
            }
            return true;
          },
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: FutureBuilder(
        future: Future.delayed(Duration(seconds: 2)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[300]!,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(50),
                          bottomLeft: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              if (isEditing) {
                                _pickProfileImage();
                              }
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blueGrey,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!) as ImageProvider<Object>?
                                  : (profileImageUrl != null && profileImageUrl.isNotEmpty)
                                  ? NetworkImage(profileImageUrl)
                                  : NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/videofam-c0f70.appspot.com/o/profile_images%2Fdefimage.jpg?alt=media&token=597aeb0d-f4a9-4243-8335-372105f340b8',
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (!isEditing)
                            Column(
                              children: [
                                Text(
                                  '$name',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '$email',
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                          if (isEditing)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Name',
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'lexend',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'lexend',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: updateProfile,
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              isEditing ? 'Save Profile' : 'Edit Profile',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'lexend',
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Add more Sliver widgets for the rest of your content here
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'My Posts',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('userPhoneNumber', isEqualTo: userPhoneNumber)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator(); // Display a loading indicator while fetching data.
                        }

                        final posts = snapshot.data!.docs;

                        if (posts.isEmpty) {
                          return Center(
                            child: Text(
                              'No posts found',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        return Column(
                          children: posts.map((post) {
                            final postTitle = post['title']; // Replace with your post field name.
                            final postContent = post['category']; // Replace with your post field name.

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: ListTile(
                                title: Text(postTitle),
                                subtitle: Text(postContent),
                                // You can customize the display of each post here.
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Once the delay is completed, show the actual profile content
            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(50),
                        bottomLeft: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            if (isEditing) {
                              _pickProfileImage();
                            }
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blueGrey,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!) as ImageProvider<Object>?
                                : (profileImageUrl != null && profileImageUrl.isNotEmpty)
                                ? NetworkImage(profileImageUrl)
                                : NetworkImage(
                              'https://firebasestorage.googleapis.com/v0/b/videofam-c0f70.appspot.com/o/profile_images%2Fdefimage.jpg?alt=media&token=597aeb0d-f4a9-4243-8335-372105f340b8',
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (!isEditing)
                          Column(
                            children: [
                              Text(
                                '$name',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '$email',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        if (isEditing)
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'lexend',
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'lexend',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: updateProfile,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'Save Profile' : 'Edit Profile',
                            style: TextStyle(
                                color: Colors.black54,
                                fontFamily: 'lexend',
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Add more Sliver widgets for the rest of your content here
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'My Posts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('userPhoneNumber', isEqualTo: userPhoneNumber)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator(); // Display a loading indicator while fetching data.
                      }

                      final posts = snapshot.data!.docs;

                      if (posts.isEmpty) {
                        return Center(
                          child: Text(
                            'No posts found',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return Column(
                        children: posts.map((post) {
                          final postTitle = post['title']; // Replace with your post field name.
                          final postContent = post['category']; // Replace with your post field name.

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(postTitle),
                              subtitle: Text(postContent),
                              // You can customize the display of each post here.
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  fullscreenDialog: true, builder: (_) => PostVideoScreen()));
        },
        backgroundColor: Colors.grey.shade900,
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
                  MaterialButton(
                    minWidth: 20,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: currenttab == 0 ? Colors.blueAccent : Colors.grey,
                          size: 25,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                            fontFamily: 'lexend',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: currenttab == 0 ? Colors.blueAccent : Colors.grey,
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
                  MaterialButton(
                    minWidth: 20,
                    onPressed: () {
                      setState(() {
                        currentscreen = ProfilePage();
                        currenttab = 0;
                      });
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
    );
  }
}
