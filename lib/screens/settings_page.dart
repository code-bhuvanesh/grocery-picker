import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_picker/screens/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const routeName = "/settongsPage";
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).popAndPushNamed(LoginPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("logout"),
          onPressed: () async {
            debugPrint("hello");
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginPage.routeName, (Route<dynamic> route) => false);
            }
          },
        ),
      ),
    );
  }
}
