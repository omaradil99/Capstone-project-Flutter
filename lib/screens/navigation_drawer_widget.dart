import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'signin_screen.dart';

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Colors.lightBlue,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height - 100,
            ),
            Divider(
              color: Colors.white70,
              thickness: 2,
            ),
            const SizedBox(
              height: 2,
            ),
            buildMenuItem(text: 'logout', icon: Icons.logout, context: context)
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(
      {required String text,
      required IconData icon,
      required BuildContext context}) {
    final color = Colors.white;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: TextStyle(color: color),
      ),
      onTap: () {
        FirebaseAuth.instance.signOut().then((value) {
          print("Signed Out");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignInScreen()));
        });
      },
    );
  }
}
