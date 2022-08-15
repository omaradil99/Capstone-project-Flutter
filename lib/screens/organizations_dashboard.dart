import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_complete_guide/models/organizations.dart';
import 'package:flutter_complete_guide/reusable_widgets/reusable_widget.dart';
import 'package:flutter_complete_guide/screens/add_post_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Post.dart';
import 'package:flutter/material.dart';

import 'navigation_drawer_widget.dart';

class OrganizationsDashboard extends StatefulWidget {
  final String email;
  OrganizationsDashboard(this.email);

  @override
  _OrganizationsDashboardState createState() =>
      _OrganizationsDashboardState(email);
}

class _OrganizationsDashboardState extends State<OrganizationsDashboard> {
  String email;
  _OrganizationsDashboardState(this.email);

  File? image;
  String? owner;
  Organizations? organizations;

  Stream<List<Post>> readPosts() {
    print('the  of the post owneris       $owner');
    return FirebaseFirestore.instance
        .collection('posts')
        .where('owner', isEqualTo: owner)
        .snapshots()
        .map((snapshot) {
      // print(snapshot);
      return snapshot.docs.map((doc) {
        // print(doc.data());
        return Post.fromJson(doc.data());
      }).toList();
    });
  }

  Future<Organizations?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    owner = await prefs.get('organizationId') as String;

    await FirebaseFirestore.instance
        .collection('organizations')
        .where('id', isEqualTo: owner.toString())
        .get()
        .then((event) {
      if (event.docs.isNotEmpty) {
        Map<String, dynamic> documentData =
            event.docs.single.data(); //if it is a single document
        print(documentData.toString());
        organizations = Organizations.fromJson(documentData);
      }
    }).catchError((e) => print("error fetching data: $e"));
    return organizations;
  }

  Widget buildAddButton() => FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.green,
        icon: Icon(Icons.add),
        label: Text('Add a Scholarship'),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddPost(email)));
        },
      );

  Widget buildPost(Post post) {
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
              leading: ClipOval(
                child: Container(
                  height: 30,
                  width: 30,
                  child: Image.network(organizations!.imageUrl,
                      loadingBuilder: ((context, child, loadingProgress) {
                    return loadingProgress == null
                        ? child
                        : LinearProgressIndicator();
                  }), height: 200, fit: BoxFit.fill
                      // width: MediaQuery.of(context).size.width,
                      ),
                ),
              ),
              title: Text(
                post.description,
                style: TextStyle(fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(title: Text('Dashboard')),
      floatingActionButton: buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('We have an error ${snapshot.error}');
                      return Text(snapshot.error.toString());
                    } else if (snapshot.hasData) {
                      return myProfileColumn();
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column myProfileColumn() {
    return Column(
      children: [
        profileStack(context, organizations!.imageUrl),
        const SizedBox(
          height: 90,
        ),
        Text(
          organizations!.userName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        StreamBuilder<List<Post>>(
            stream: readPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data == null) {
                  print(snapshot.error.toString());
                  return Text(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  final posts = snapshot.data;
                  return Column(
                    children: posts!.map(buildPost).toList(),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            })
      ],
    );
  }
}
