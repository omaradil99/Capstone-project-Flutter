import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_complete_guide/screens/first_page.dart';
import 'package:flutter_complete_guide/reusable_widgets/date-picker_textfield.dart';
import 'package:flutter_complete_guide/screens/user_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/users.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../utils/firebase_api.dart';
import '../utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreInfo extends StatefulWidget {
  final String userName;
  final String email;
  final String password;
  MoreInfo({
    required this.email,
    required this.userName,
    required this.password,
  });

  @override
  State<MoreInfo> createState() =>
      _MoreInfoState(email: email, userName: userName, password: password);
}

class _MoreInfoState extends State<MoreInfo> {
  File? image;
  File? transcript;
  File? resume;
  UploadTask? task;
  String? transcriptUrl;
  String? resumeUrl;
  String? profilePictureUrl;
  DateTime? birthDate;
  String? selectedFieldOfStudy;
  String? selectedGender;
  DateTime? selectedDate;

  List<String> genders = ['Male', 'Female'];

  List<String> majors = [
    'Business Adminstration',
    'Computer Science',
    'Medical',
    'Engineering',
    'Humanities',
    'Social Studies'
  ];

  void selectDate() {
    FocusScope.of(context).requestFocus(new FocusNode());
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedDate = pickedDate;
        print(selectedDate);
      });
    });
  }

  Center myDropDownMenu(bool isMajor) {
    List<String> items;
    isMajor == true ? items = majors : items = genders;
    return Center(
      child: SizedBox(
        height: 60,
        width: 355,
        child: DropdownButtonFormField(
          dropdownColor: Colors.black,
          decoration: InputDecoration(
              prefixIcon: isMajor == true
                  ? Icon(
                      Icons.school,
                      color: Colors.white70,
                    )
                  : Icon(Icons.family_restroom, color: Colors.white70),
              fillColor: Colors.white.withOpacity(0.3),
              // focusColor: Colors.amber,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3), width: 0.1))),
          hint: Text(
            isMajor == true
                ? 'Please choose your field of study'
                : 'please choose your gender',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ), // Not necessary for Option 1
          value: isMajor == true ? selectedFieldOfStudy : selectedGender,
          onChanged: (newValue) {
            setState(() {
              isMajor == true
                  ? selectedFieldOfStudy = newValue as String
                  : selectedGender = newValue as String?;
              print(isMajor == true ? selectedFieldOfStudy : selectedGender);
            });
          },
          items: items.map((item) {
            return DropdownMenuItem(
              child: new Text(
                item,
                style: TextStyle(
                    fontSize: 16, color: Colors.white.withOpacity(0.9)),
                textAlign: TextAlign.center,
              ),
              value: item,
            );
          }).toList(),
        ),
      ),
    );
  }

  Future uploadFile(File file, String userId, String fileName) async {
    final destenation = 'files/$userId/$fileName';
    task = FirebaseApi.uploadFile(destenation, file);

    if (task == null) return;
    final snapshot = await task!.whenComplete(() {});
    if (fileName == 'transcript') {
      transcriptUrl = await snapshot.ref.getDownloadURL();
    }
    if (fileName == 'resume') {
      resumeUrl = await snapshot.ref.getDownloadURL();
    }
    if (fileName == 'profilePicture') {
      profilePictureUrl = await snapshot.ref.getDownloadURL();
    }
  }

  Future selectFile(bool isTranscript) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;

    final path = result.files.single.path;
    isTranscript == true
        ? setState(() {
            transcript = File(path!);
          })
        : setState(() {
            resume = File(path!);
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

  Future<void> extractData() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    uploadFile(transcript!, docUser.id, 'transcript');
    uploadFile(resume!, docUser.id, 'resume');
    uploadFile(image!, docUser.id, 'profilePicture');

    final user = Users(
        userName: userName,
        email: email,
        password: password,
        firstName: _firstNameTextController.text,
        lastName: _lastNameTextController.text,
        id: docUser.id,
        major: _majorTextController.text,
        birthDate: DateFormat.yMd().format(selectedDate!),
        fieldOfStudy: selectedFieldOfStudy!,
        gender: selectedGender!,
        imageUrl: profilePictureUrl!,
        transcriptUrl: transcriptUrl!,
        resumeUrl: resumeUrl!);
    print('hi');
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('id', docUser.id);
    prefs.setString('userEmail', email);
    print(user);

    final json = user.toJson();
    await docUser.set(json).then((value) {
      print("Created New Account");
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserNavigationBar()));
    }).onError((error, stackTrace) {
      print("Error ${error.toString()}");
    });
    ;
  }

  final String userName;
  final String email;
  final String password;
  _MoreInfoState({
    required this.email,
    required this.userName,
    required this.password,
  });

  TextEditingController _firstNameTextController = TextEditingController();
  TextEditingController _lastNameTextController = TextEditingController();
  TextEditingController _majorTextController = TextEditingController();
  TextEditingController _pickedDateTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Personal info",
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
                  ClipOval(
                    child: image != null
                        ? Image.file(
                            image!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 160,
                            height: 160,
                            color: Colors.grey.withOpacity(0.55),
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter First Name", Icons.person_outline,
                      false, _firstNameTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter Last Name", Icons.person_outline,
                      false, _lastNameTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  datePickerTextField(
                    selectedDate == null
                        ? 'Choose BirthDate '
                        : DateFormat.yMd().format(selectedDate!),
                    Icons.calendar_today_outlined,
                    _pickedDateTextController,
                    selectDate,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  myDropDownMenu(false),
                  const SizedBox(
                    height: 20,
                  ),
                  myDropDownMenu(true),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter your Major", Icons.school, false,
                      _majorTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  buttonTitle('Profile Picture'),
                  const SizedBox(
                    height: 10,
                  ),
                  filesButton(
                    title: 'Pick a Picture',
                    icon: Icons.image_outlined,
                    onClicked: () => pickImage(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buttonTitle('upload your transcript'),
                  const SizedBox(
                    height: 10,
                  ),
                  filesButton(
                    title: 'Select a File',
                    icon: Icons.image_outlined,
                    onClicked: () => selectFile(true),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buttonTitle('upload your resume'),
                  const SizedBox(
                    height: 10,
                  ),
                  filesButton(
                    title: 'Select a File',
                    icon: Icons.image_outlined,
                    onClicked: () => selectFile(false),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  firebaseUIButton(context, "Sign Up", extractData),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            )),
          )),
    );
  }
}
