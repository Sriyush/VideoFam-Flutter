import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart';
import '../firebase/firestore.dart';



class PostVideoScreen extends StatefulWidget {
  const PostVideoScreen({super.key});

  @override
  State<PostVideoScreen> createState() => _PostVideoScreenState();
}

class _PostVideoScreenState extends State<PostVideoScreen> {
  Position? _currentPosition;
  String? _currentCity;
  bool _isLocation = false;
  bool _isLoading = false;
  XFile? pickedFile = null;
  String  downloadURL = "";
  String? profileImageUrl;
  String userPhoneNumber = '';
  TextEditingController _locationController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  late DatabaseReference info1;

  VideoPlayerController? _videoController;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickVideoFromCamera() async {
     pickedFile = await _imagePicker.pickVideo(source: ImageSource.camera);
     if (pickedFile != null) {
     String? fetchedProfileImageUrl = await fetchProfileImageUrl(userPhoneNumber);
       setState(() {
         _videoController = VideoPlayerController.file(File(pickedFile!.path))
           ..initialize().then((_) {
             // Ensure that the video starts playing once it's initialized
             _videoController!.play();
           });
           profileImageUrl = fetchedProfileImageUrl;
       });
       
     }
  }
  void showSuccessSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Your video has been successfully posted.'),
      duration: Duration(seconds: 2),
    ),
  );
}

  
 Future<String?> fetchProfileImageUrl(String userPhoneNumber) async {
  if (userPhoneNumber != null) {
    info1.once().then((DatabaseEvent event) {
      final data = event.snapshot.value;
      print('Data from Firebase: $data');
      if (data is Map) {
        setState(() {
          profileImageUrl = data['profileImageUrl'] ?? '';
        });
      } else {
        print('User profile data not found in the database for userPhoneNumber: $userPhoneNumber');
      }
    }).catchError((error) {
      print('Error loading user profile: $error');
    });
  } else {
  }
}



  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
  void _checkLocationPermission() async {
  final permissionStatus = await Permission.location.status;
  if (permissionStatus.isDenied) {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Location Permission Required"),
          content: Text("Please allow location access to use this feature."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Permission.location.request();
              },
              child: Text("Allow"),
            ),
          ],
        );
      },
    );
  }
}



  //camera

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _getCurrentLocation();
    final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final phoneNumber = user.phoneNumber;
  if (phoneNumber != null) {
    userPhoneNumber = phoneNumber;
    print('$userPhoneNumber');
    info1 = FirebaseDatabase.instance.ref().child('userProfiles').child('$userPhoneNumber');
    fetchProfileImageUrl(userPhoneNumber);
  } else {
    print('User does not have a linked phone number.');
  }
} else {
  print('User is not authenticated.');
}

  }
  void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3), // Adjust as needed
    ),
  );
}


  Future<void> _getCurrentLocation() async {
  setState(() {
    _isLocation = true;
  });
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
      _getCurrentCity(position.latitude, position.longitude);
    });
  } catch (e) {
    showSnackBar(context, e.toString());
    setState(() {
      _isLocation = false;
    });
  }
}

Future<void> _getCurrentCity(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      setState(() {
        _currentCity = placemarks[0].locality;
        _locationController.text =
            "$_currentCity";
        _isLocation = false;
      });
    }
  } catch (e) {
    showSnackBar(context, e.toString());
    setState(() {
      _isLocation = false;
    });
  }
}
void showLocationPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Services Required"),
          content: Text("Please enable location services to proceed."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black87));

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          title: Text(
            "Post Video",
            style: TextStyle(
              fontFamily: 'lexend',
              fontSize: 16,
              color: Colors.black54
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions:  [
            GestureDetector(
              onTap: _pickVideoFromCamera,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.video_call_rounded,
                  color: Colors.black54,
                ),
              ),
            )
          ],
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black54),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: _isLocation
            ? Center(
                child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black54,
              ))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                keyboardType: TextInputType.text,
                                controller: _titleController,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  label: Text("Video Title",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'lexend',
                                    fontWeight: FontWeight.w400
                                  ),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide:
                                          BorderSide(color: Colors.blue)),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                keyboardType: TextInputType.text,
                                controller: _descController,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  label: Text("Video Description",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'lexend',
                                    fontWeight: FontWeight.w400
                                  ),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide:
                                          BorderSide(color: Colors.blue)),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      controller: _locationController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        label: Text("Video Location",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontFamily: 'lexend',
                                          fontWeight: FontWeight.w400
                                        ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                              SizedBox(height: 10),
                              TextField(
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                controller: _categoryController,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  label: Text("Video category",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'lexend',
                                    fontWeight: FontWeight.w400
                                  ),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide:
                                          BorderSide(color: Colors.blue)),
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                height: 500,
                                child: _videoController != null
                                    ? AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      VideoPlayer(_videoController!,),
                                      VideoProgressIndicator(_videoController!, allowScrubbing: true,),
                                    ],
                                  ),
                                )
                                    : Center(child: Text('Record a Video to post',
                                    style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'lexend',
                                    fontWeight: FontWeight.w400
                                  ),
                                    )),
                              ),
                              SizedBox(
                                height: 26,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        if (_titleController.text.isEmpty) {
                                          } else if (_descController.text.isEmpty) {
                                          } else if (_locationController.text.isEmpty) {

                                          } else if (_categoryController.text.isEmpty) {
                                          } else if (pickedFile == null) {
                                          
                                          } else {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            final file = File(pickedFile!.path);
                                            final firebaseStorageRef =
                                                firebase_storage.FirebaseStorage.instance
                                                    .ref()
                                                    .child('videos')
                                                    .child(
                                                        DateTime.now().microsecondsSinceEpoch
                                                            .toString() + '.mp4');

                                            final uploadTask = firebaseStorageRef.putFile(file);

                                            try {
                                              await uploadTask.whenComplete(() async {
                                                try {
                                                  // Get the download URL
                                                  downloadURL =
                                                      await firebaseStorageRef.getDownloadURL();
                                                  await FireStoreMethods().postVideo(
                                                    title: _titleController.text.trim(),
                                                    des: _descController.text.trim(),
                                                    location: _locationController.text.trim(),
                                                    category: _categoryController.text.trim(),
                                                    url: downloadURL,
                                                    profileImageUrl: profileImageUrl,
                                                    userPhoneNumber: userPhoneNumber,
                                                  );
                                                  showSuccessSnackBar(context);
                                                } catch (e) {
                                                  showSnackBar(context, 'Download URL error: $e');
                                                } finally {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                }
                                              });
                                            } catch (e) {
                                              // Handle upload task completion error
                                              showSnackBar(context, 'Upload error: $e');
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          }
                                        },
                                      style: ElevatedButton.styleFrom(
                                          shape: StadiumBorder(),
                                          primary: Colors.blue.shade800,
                                          ),
                                      child: _isLoading
                                          ? CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            )
                                          : Text(
                                              "Post",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'lexend',
                                                  fontSize: 14),
                                            )),
                                ),
                              ),
                              // You can replace this with your video preview widget
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
