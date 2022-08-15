import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_complete_guide/models/users.dart';
import 'package:flutter_complete_guide/reusable_widgets/reusable_widget.dart';
import 'package:flutter_complete_guide/screens/user_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './signin_screen.dart';
import 'package:flutter/material.dart';

import 'navigation_drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Users? user;
  String? userId;
  DateTime? selectedDate;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  String? selectedFieldOfStudy;
  String? selectedGender;

  List<String> genders = ['Male', 'Female'];

  List<String> majors = [
    'Business Adminstration',
    'Computer Science',
    'Medical',
    'Engineering',
    'Humanities',
    'Social Studies'
  ];

  Future<void> extractData() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();

    final updatedUser = Users(
        userName: user!.userName,
        email: user!.email,
        password: user!.password,
        firstName: firstNameController.text.isNotEmpty
            ? firstNameController.text
            : user!.firstName,
        lastName: lastNameController.text.isNotEmpty
            ? lastNameController.text
            : user!.lastName,
        id: docUser.id,
        major: majorController.text.isNotEmpty
            ? majorController.text
            : user!.major,
        birthDate: selectedDate != null
            ? DateFormat.yMd().format(selectedDate!)
            : user!.birthDate,
        fieldOfStudy: selectedFieldOfStudy != null
            ? selectedFieldOfStudy!
            : user!.fieldOfStudy,
        gender: selectedGender != null ? selectedGender! : user!.gender,
        imageUrl: user!.imageUrl,
        transcriptUrl: user!.transcriptUrl,
        resumeUrl: user!.resumeUrl);

    final json = updatedUser.toJson();
    await docUser.update(json).then((value) {
      print('user info has been updated');
    }).onError((error, stackTrace) {
      print("Error ${error.toString()}");
    });
    ;
  }

  Future<Users?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.get('id') as String;
    await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .get()
        .then((event) {
      if (event.docs.isNotEmpty) {
        Map<String, dynamic> documentData =
            event.docs.single.data(); //if it is a single document
        print(documentData.toString());
        user = Users.fromJson(documentData);
      }
    }).catchError((e) => print("error fetching data: $e"));
    return user;
  }

  void selectDate() {
    FocusScope.of(context).requestFocus(new FocusNode());
    showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 14)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(Duration(days: 365 * 14)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Column(
                children: [
                  FutureBuilder(
                    future: getUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print('We have an error ${snapshot.error}');
                        return Text(snapshot.error.toString());
                      } else if (snapshot.hasData) {
                        return myColumn(context);
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  firebaseUIButton(context, "Update", () async {
                    await extractData();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column myColumn(BuildContext context) {
    return Column(
      children: [
        profileStack(context, user!.imageUrl),
        const SizedBox(
          height: 90,
        ),
        Text(
          '${user!.firstName} ${user!.lastName}',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        myTextField(
            'First Name', 'Change Your First Name', firstNameController, () {}),
        myTextField(
            'Last Name', 'Change Your Last Name', lastNameController, () {}),
        myTextField('Major', 'Change Your Major', majorController, () {}),
        myTextField(
            'BirthDate',
            selectedDate == null
                ? 'Change Your Birth date'
                : DateFormat.yMd().format(selectedDate!),
            TextEditingController(),
            selectDate),
        myDropDownMenu(true),
        myDropDownMenu(false),
        Center(
          child: ElevatedButton(
            child: Text("Logout"),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget myTextField(String labelText, String hint,
      TextEditingController controller, VoidCallback selectDate) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 35),
      child: TextField(
        controller: controller,
        onTap: selectDate,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 5),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.black,
            )),
      ),
    );
  }

  Center myDropDownMenu(bool isMajor) {
    List<String> items;
    isMajor == true ? items = majors : items = genders;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: DropdownButtonFormField(
          dropdownColor: Colors.white,
          hint: Text(
            isMajor == true
                ? 'Change choose your field of study'
                : 'Change choose your gender',
            style: TextStyle(color: Colors.black),
          ), // Not necessary for Option 1
          value: isMajor == true ? selectedFieldOfStudy : selectedGender,
          onChanged: (newValue) {
            setState(() {
              isMajor == true
                  ? selectedFieldOfStudy = newValue.toString()
                  : selectedGender = newValue.toString();
              print(isMajor == true ? selectedFieldOfStudy : selectedGender);
            });
          },
          items: items.map((item) {
            return DropdownMenuItem(
              child: new Text(
                item,
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              value: item,
            );
          }).toList(),
        ),
      ),
    );
  }
}
