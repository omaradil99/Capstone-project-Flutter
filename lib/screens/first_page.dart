import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/organizations.dart';
import 'package:flutter_complete_guide/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Post.dart';
import 'package:http/http.dart' as http;

import 'navigation_drawer_widget.dart';

class FirstPage extends StatefulWidget {
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
  }

  Future sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final serviceId = 'service_o40uaw9';
    final templateId = 'template_yvsugon';
    final userId = '9AWRzCAU6l_Dwzb-r';
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'owner_email': email,
            'user_subject': subject,
            'from_name': name,
            'user_message': message,
          }
        }));
    print('email sent');
  }

  Future<Organizations> getUserData(organizationId) async {
    Organizations? organizations;
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.get('id') as String;
    await FirebaseFirestore.instance
        .collection('organizations')
        .where('id', isEqualTo: organizationId)
        .get()
        .then((event) {
      if (event.docs.isNotEmpty) {
        Map<String, dynamic> documentData =
            event.docs.single.data(); //if it is a single document
        print(documentData.toString());

        organizations = Organizations.fromJson(documentData);
      } else {
        return CircularProgressIndicator();
      }
    }).catchError((e) => print("error fetching data: $e"));

    return organizations!;
  }

  Widget buildPost(Post post) {
    Organizations? organizations;
    return FutureBuilder<Organizations>(
        future: getUserData(post.owner),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('We have an error ${snapshot.error}');
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            organizations = snapshot.data;
            return Container(
              padding: EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      child: Image.network(post.imageUrl,
                          loadingBuilder: ((context, child, loadingProgress) {
                        return loadingProgress == null
                            ? child
                            : LinearProgressIndicator();
                      }), height: 200, fit: BoxFit.fill
                          // width: MediaQuery.of(context).size.width,
                          ),
                    ),
                    ListTile(
                      isThreeLine: true,
                      subtitle: Text(
                        'valid until: ${post.validUntil} for ${post.availableFor}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.bold),
                      ),
                      title: Text(
                        post.description,
                        style: TextStyle(fontSize: 14),
                      ),
                      leading: ClipOval(
                        child: Container(
                          height: 30,
                          width: 30,
                          child: Image.network(organizations!.imageUrl,
                              loadingBuilder:
                                  ((context, child, loadingProgress) {
                            return loadingProgress == null
                                ? child
                                : LinearProgressIndicator();
                          }), height: 200, fit: BoxFit.fill
                              // width: MediaQuery.of(context).size.width,
                              ),
                        ),
                      ),
                    ),
                    Text(post.ownerEmail),
                    ElevatedButton(
                      child: Text('Apply'),
                      onPressed: () => sendEmail(
                          email: post.ownerEmail,
                          name: 'Scholarify',
                          message: post.toString(),
                          subject: 'new application'),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Stream<List<Post>> readPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('availableFor', whereIn: [
          'All',
        ])
        .snapshots()
        .map((snapshot) {
          // print(snapshot);
          return snapshot.docs.map((doc) {
            // print(doc.data());
            return Post.fromJson(doc.data());
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(
        title: Text(
          'HomePage',
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                StreamBuilder<List<Post>>(
                    stream: readPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.data == null) {
                          print(snapshot.error.toString());
                          return Text(snapshot.error.toString());
                        } else {
                          final posts = snapshot.data;
                          print('from streambuilder');
                          return Column(
                            children: posts!.map(buildPost).toList(),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
