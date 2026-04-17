import 'package:flutter/material.dart';
import 'package:front/presentation/screens/home/success_secreen.dart';

class MascotDialog extends StatelessWidget {
  final String videoPath;
  const MascotDialog({Key? key, required this.videoPath}) : super(key: key);

  static void show(BuildContext context, {String videoPath = "assets/mascot_success.mp4"}) {
    showDialog(
      context: context,
      builder: (context) => MascotDialog(videoPath: videoPath),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                   SizedBox(
                    height: 300,
                    child: MascotVideo(videoPath: videoPath),
                  ),

                  Positioned(
                    top: 10, right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const SizedBox(height: 16),
          // const Text(
          //   "C'EST REUSSI ! 🎉",
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //     letterSpacing: 2,
          //   ),
          // ),
        ],
      ),
    );
  }
}
