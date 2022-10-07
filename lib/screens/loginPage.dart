import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_picker/screens/mainPage.dart';

import '../widgets/loginInputField.dart';
import '../widgets/toggleButton.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const routeName = "/loginPage";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var isLoginstate = true;

  var btnText = " Login ";

  final emailTextController = TextEditingController();
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void onToggle(String state) {
    setState(() {
      btnText = state;
      if (state == "Signup") {
        isLoginstate = false;
      } else {
        isLoginstate = true;
      }
    });
  }

  Future<void> firebaseLogin() async {
    if (emailTextController.text.isNotEmpty &&
        passwordTextController.text.isNotEmpty) {
      try {
        loginProgress = true;
        var userCredentials = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailTextController.text,
                password: passwordTextController.text);
        var user = userCredentials.user;
        print(user?.uid);
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            print('User is currently signed out!');
            loginProgress = false;
          } else {
            print('User is signed in!');
            Navigator.popAndPushNamed(context, MainPage.routeName);
          }
        });
      } on FirebaseAuthException catch (e) {
        loginProgress = false;
        print(e.code);
        var error = "";
        if (e.code == 'invalid-email') {
          error = 'email entered not found!';
        } else if (e.code == 'wrong-password') {
          error = 'entered password is wrong!';
        }
        Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Color.fromARGB(255, 54, 54, 54),
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      } catch (e) {
        loginProgress = false;
        print(e);
      }
    }
  }

  Future<void> firebaseSignup() async {
    if (emailTextController.text.isNotEmpty &&
        passwordTextController.text.isNotEmpty &&
        usernameTextController.text.isNotEmpty) {
      try {
        loginProgress = true;
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text,
        );
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            print('User is currently signed out!');
          } else {
            print('User is signed in!');
            user.updateDisplayName(usernameTextController.text);
            Navigator.popAndPushNamed(context, MainPage.routeName);
          }
        });
      } on FirebaseAuthException catch (e) {
        loginProgress = false;
        print("error : ... ${e.code}");
        var error = "";
        if (e.code == 'weak-password') {
          error = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          error = 'The account already exists for that email.';
        }
        if (error.isNotEmpty) {
          Fluttertoast.showToast(
              msg: error,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Color.fromARGB(255, 54, 54, 54),
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
        }
      } catch (e) {
        loginProgress = false;
        print(e);
      }
    }
  }

  var loginProgress = false;

  @override
  Widget build(BuildContext context) {
    var topPadding = AppBar().preferredSize.height + 50;
    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, topPadding, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Grocery\n        Picker",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      fontFamily: "autumn_in_november"),
                ),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        ToggleButton(onToggle: onToggle),
                        if (!isLoginstate)
                          AnimatedScale(
                              duration: Duration(seconds: 1),
                              scale: !isLoginstate ? 1 : 0,
                              child: LoginInputField(
                                hintText: 'username',
                                controller: usernameTextController,
                              )),
                        LoginInputField(
                          hintText: 'email',
                          controller: emailTextController,
                        ),
                        LoginInputField(
                          hintText: 'password',
                          controller: passwordTextController,
                          isPassword: true,
                        ),
                        GestureDetector(
                          onTap: isLoginstate ? firebaseLogin : firebaseSignup,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              color: Colors.green,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                child: Text(
                                  btnText,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (loginProgress)
          Container(
            child: Center(child: CircularProgressIndicator()),
          )
      ]),
    );
  }
}
