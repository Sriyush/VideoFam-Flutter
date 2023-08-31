import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoCards extends StatefulWidget {
  final snap;
  const VideoCards({super.key, required this.snap});

  @override
  State<VideoCards> createState() => _VideoCardsState();
}

class _VideoCardsState extends State<VideoCards> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  Future<void> _initializeVideoController() async {
    _videoController = VideoPlayerController.network(widget.snap['videoUrl']);
    await _videoController.initialize();
    Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _videoController.play();
          });
        }); // Mute the video
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  radius: 24,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    "${widget.snap['title']}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      overflow: TextOverflow.ellipsis,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                  ),
                )
              ],
            ),
            Text(
              "${widget.snap['category']}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
            ),
            SizedBox(height: 8),
            Container(
              height: 240,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  if (_videoController.value.isInitialized)
                    VideoPlayer(_videoController),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "${widget.snap['des']}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
            ),
            SizedBox(height: 4),
            Text(
              "${widget.snap['location']}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
