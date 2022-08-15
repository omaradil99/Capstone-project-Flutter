import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_complete_guide/reusable_widgets/date-picker_textfield.dart';
import 'package:flutter_complete_guide/reusable_widgets/discription_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Post.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'package:flutter/material.dart';

import '../utils/firebase_api.dart';

class AddPost extends StatefulWidget {
  String email;
  AddPost(this.email);

  @override
  _AddPost createState() => _AddPost(email);
}

class _AddPost extends State<AddPost> {
  String email;
  _AddPost(this.email);
  TextEditingController _descriptionTextController = TextEditingController();
  TextEditingController _pickedDateTextController = TextEditingController();
  File? image;
  DateTime? selectedDate;
  UploadTask? task;
  String? profilePictureUrl;
  String? selectedFieldOfStudy;

  List<String> majors = [
    'All',
    'Business Adminstration',
    'Computer Science',
    'Medical',
    'Engineering',
    'Humanities',
    'Social Studies'
  ];

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

  void selectDate() {
    FocusScope.of(context).requestFocus(new FocusNode());
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
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

  Future uploadFile(File file, String userId, String fileName) async {
    final destenation = 'files/$userId/$fileName';
    task = FirebaseApi.uploadFile(destenation, file);

    if (task == null) return;
    final snapshot = await task!.whenComplete(() {});

    profilePictureUrl = await snapshot.ref.getDownloadURL();
  }

  Future<void> extractData() async {
    final prefs = await SharedPreferences.getInstance();
    final owner = prefs.get('organizationId');
    final docUser = FirebaseFirestore.instance.collection('posts').doc();
    await uploadFile(image!, docUser.id, 'post picture');

    final user = Post(
        id: docUser.id,
        validUntil: DateFormat.yMd().format(selectedDate!),
        imageUrl: profilePictureUrl!,
        description: _descriptionTextController.text,
        owner: owner.toString(),
        availableFor: selectedFieldOfStudy!,
        ownerEmail: email);

    final json = user.toJson();
    await docUser.set(json).then((value) {
      print('the post has been added and the owner is $owner');
    }).onError((error, stackTrace) {
      print("Error ${error.toString()}");
    });
    ;
  }

  Center myDropDownMenu() {
    List<String> items;
    items = majors;
    return Center(
      child: SizedBox(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: DropdownButtonFormField(
          dropdownColor: Colors.lightBlue,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.school,
                color: Colors.white70,
              ),
              fillColor: Colors.white.withOpacity(0.3),
              // focusColor: Colors.amber,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3), width: 0.1))),
          hint: Text(
            'Please choose the field of study',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ), // Not necessary for Option 1
          value: selectedFieldOfStudy,
          onChanged: (newValue) {
            setState(() {
              selectedFieldOfStudy = newValue as String;
              print(selectedFieldOfStudy);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Add a post",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.amber,
            Colors.lightBlue,
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
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      child: image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                image!,
                                width: MediaQuery.of(context).size.width,
                                height: 160,
                                // fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade400,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.photo_outlined, size: 60),
                                  Text(
                                    'add picture',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 120,
                      child: descriptionTextField(
                          "Description", _descriptionTextController)),
                  const SizedBox(
                    height: 20,
                  ),
                  datePickerTextField(
                    selectedDate == null
                        ? 'valid until '
                        : DateFormat.yMd().format(selectedDate!),
                    Icons.calendar_today_outlined,
                    _pickedDateTextController,
                    selectDate,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  myDropDownMenu(),
                  const SizedBox(
                    height: 20,
                  ),
                  firebaseUIButton(context, "Post", () async {
                    await extractData();
                    setState(() {
                      Navigator.pop(context);
                    });
                  })
                ],
              ),
            )),
          )),
    );
  }
}
