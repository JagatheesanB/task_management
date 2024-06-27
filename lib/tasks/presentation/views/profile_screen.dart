import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';

import '../../domain/models/task.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final String email;

  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Tasks> tasks = ref.watch(taskProvider);
    final userId = ref.watch(currentUserProvider) as int;
    String emailPrefix = email.split('@').first;
    emailPrefix = emailPrefix.replaceAll(RegExp(r'[0-9]'), '');

    String capitalize(String s) =>
        s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';

    String firstLetterOfName = capitalize(emailPrefix);

    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50),
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),
                    Hero(tag: 'Hero', child: ProfilePicture(userId: userId)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(padding: EdgeInsets.only(top: 10)),
                          Text(
                            firstLetterOfName,
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 35,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'email : $email',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                    ),
                                  ),
                                  Consumer(
                                    builder: (context, watch, _) {
                                      final completedCount = tasks
                                          .where((task) => task.isCompleted)
                                          .length;
                                      return Text(
                                        '$completedCount',
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontSize: 25,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 8,
                                ),
                                child: Container(
                                  height: 50,
                                  width: 3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Pending',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                    ),
                                  ),
                                  Consumer(
                                    builder: (context, watch, _) {
                                      final pendingCount = tasks
                                          .where((task) => !task.isCompleted)
                                          .length;
                                      return Text(
                                        '$pendingCount',
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontSize: 25,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePicture extends StatefulWidget {
  final int userId;
  const ProfilePicture({Key? key, required this.userId}) : super(key: key);
  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  StorageService storage = StorageService();
  Uint8List? pickedImage;
  bool hasImage = false;
  Offset position = Offset.zero;
  double _scale = 1.0;
  double _previousScale = 1.0;
  late int userID;
  @override
  void initState() {
    super.initState();
    userID = widget.userId;
    getProfilePicture();
    // getSavedImageState();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.75;
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        setState(() {
          _previousScale = _scale;
        });
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        setState(() {
          _scale = _previousScale * details.scale;
          _scale = _scale.clamp(1.0, 3.0);
        });
      },
      onTap: onProfileTapped,
      child: Container(
        height: size,
        width: size,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        child: pickedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Transform.scale(
                  scale: _scale,
                  child: Image.memory(
                    pickedImage!,
                    fit: BoxFit.cover,
                    width: size * _scale,
                    height: size * _scale,
                  ),
                ),
              )
            : const Center(
                child: Icon(
                  Icons.person_2_rounded,
                  color: Colors.black38,
                  size: 35,
                ),
              ),
      ),
    );
  }

  Future<void> onProfileTapped() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageBytes = await image.readAsBytes();
    await storage.uploadFile("user_${widget.userId}.jpg", imageBytes);
    setState(() {
      pickedImage = imageBytes;
      hasImage = true;
      position = Offset.zero;
      _scale = 1.0;
      // saveImageState();
    });
  }

  Future<void> removeProfilePicture() async {
    await storage.deleteFile("user_${widget.userId}.jpg");
    setState(() {
      pickedImage = null;
      hasImage = false;
    });
  }

  Future<void> getProfilePicture() async {
    final imageBytes = await storage.getFile("user_${widget.userId}.jpg");
    if (imageBytes != null) {
      setState(() {
        pickedImage = imageBytes;
        hasImage = true;
      });
    }
  }

  Future<void> saveImageState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_userIdScale, _scale);
    prefs.setDouble('$_userIdPosition.dx', position.dx);
    prefs.setDouble('$_userIdPosition.dy', position.dy);
  }

  Future<void> getSavedImageState() async {
    final prefs = await SharedPreferences.getInstance();
    double? savedScale = prefs.getDouble(_userIdScale);
    double? savedPositionX = prefs.getDouble('$_userIdPosition.dx');
    double? savedPositionY = prefs.getDouble('$_userIdPosition.dy');
    if (savedScale != null &&
        savedPositionX != null &&
        savedPositionY != null) {
      setState(() {
        _scale = savedScale;
        position = Offset(savedPositionX, savedPositionY);
      });
    }
  }

  String get _userIdScale => '$userID-scale';
  String get _userIdPosition => '$userID-position';
}

class StorageService {
  Future<void> uploadFile(String fileName, Uint8List fileBytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String base64Image = base64Encode(fileBytes);
      await prefs.setString(fileName, base64Image);
    } catch (e) {
      // print('Could not Upload file.$e');
    }
  }

  Future<Uint8List?> getFile(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? base64Image = prefs.getString(fileName);
      if (base64Image == null) return null;
      return base64Decode(base64Image);
    } catch (e) {
      // print('Could not get file.$e');
    }
    return null;
  }

  Future<void> deleteFile(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(fileName);
    } catch (e) {
      // print('Could not delete file.$e');
    }
  }
}
