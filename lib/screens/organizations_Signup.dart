import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_complete_guide/models/organizations.dart';
import 'package:flutter_complete_guide/screens/organizations_dashboard.dart';
import 'package:image_picker/image_picker.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../utils/firebase_api.dart';
import '../utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrganizationsSignUp extends StatefulWidget {
  const OrganizationsSignUp({Key? key}) : super(key: key);

  @override
  _OrganizationsSignUpState createState() => _OrganizationsSignUpState();
}

class _OrganizationsSignUpState extends State<OrganizationsSignUp> {
  File? image;
  UploadTask? task;
  String? profilePictureUrl;

  Future uploadFile(File file, String userId, String fileName) async {
    final destenation = 'files/$userId/$fileName';
    task = FirebaseApi.uploadFile(destenation, file);

    if (task == null) return;
    final snapshot = await task!.whenComplete(() {});

    profilePictureUrl = await snapshot.ref.getDownloadURL();
  }

  Future<void> extractData() async {
    final docUser =
        FirebaseFirestore.instance.collection('organizations').doc();
    uploadFile(image!, docUser.id, 'profilePicture').then((value) async {
      final organization = Organizations(
          userName: _organizationNameTextController.text,
          email: _emailTextController.text,
          password: _passwordTextController.text,
          id: docUser.id,
          imageUrl: profilePictureUrl!,
          role: 'organization');

      final prefs = await SharedPreferences.getInstance();

      prefs.setString('organizationId', docUser.id);
      prefs.setString('organizationEmail', _emailTextController.text);

      FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text);

      final json = organization.toJson();
      await docUser.set(json).then((value) {
        print("Created New Account");
      }).onError((error, stackTrace) {
        print("Error ${error.toString()}");
      });
      ;
    });
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick an image: $e');
    }
  }

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _organizationNameTextController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () => pickImage(),
                    child: Column(
                      children: [
                        ClipOval(
                          child: image != null
                              ? Image.file(
                                  image!,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  child: Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 50,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  width: 160,
                                  height: 160,
                                  color: Colors.grey.withOpacity(0.55),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        image == null
                            ? Text(
                                'Click Here to Add a Logo',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField(
                      "Enter your Organization's name",
                      Icons.person_outline,
                      false,
                      _organizationNameTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter Email", Icons.person_outline, false,
                      _emailTextController),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'This email will be used to recieve the applicants information',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  reusableTextField("Enter Password", Icons.lock_outlined, true,
                      _passwordTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  firebaseUIButton(context, "Sign Up", () {
                    extractData().then((value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrganizationsDashboard(
                                  _emailTextController.text)));
                    });
                  })
                ],
              ),
            )),
          )),
    );
  }
}
