import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart';
import '../utils/firestore.dart';



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

  TextEditingController _locationController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();


  VideoPlayerController? _videoController;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickVideoFromCamera() async {
     pickedFile = await _imagePicker.pickVideo(source: ImageSource.camera);

     if (pickedFile != null) {
       setState(() {
         _videoController = VideoPlayerController.file(File(pickedFile!.path))
           ..initialize().then((_) {
             // Ensure that the video starts playing once it's initialized
             _videoController!.play();
           });
       });
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
            "$_currentCity  ${_currentPosition!.latitude} ${_currentPosition!.longitude}";
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Post Video",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.black87,
          actions:  [
            GestureDetector(
              onTap: _pickVideoFromCamera,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.video_call_rounded,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        body: _isLocation
            ? Center(
                child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black87,
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
                                  label: Text("Video Title"),
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
                                  label: Text("Video Description"),
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
                                        label: Text("Video Location"),
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
                                  label: Text("Video category"),
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
                                    : Center(child: Text('No video selected')),
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
                              // ... (showSnackBar for title)
                            } else if (_descController.text.isEmpty) {
                              // ... (showSnackBar for description)
                            } else if (_locationController.text.isEmpty) {
                              // ... (showSnackBar for location)
                            } else if (_categoryController.text.isEmpty) {
                              // ... (showSnackBar for category)
                            } else if (pickedFile == null) {
                              // ... (showSnackBar for video)
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
                                    );
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
                                          shape: StadiumBorder()),
                                      child: _isLoading
                                          ? CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            )
                                          : Text(
                                              "Post",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
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
