// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:persoanlchatapp/chat_data.dart';
import 'package:persoanlchatapp/methods.dart';

class LoginTab extends StatefulWidget {
  final VoidCallback goToSignInTab;

  const LoginTab({Key? key, required this.goToSignInTab}) : super(key: key);

  @override
  LoginTabState createState() => LoginTabState();
}

class LoginTabState extends State<LoginTab> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;
  bool obscureText = true;

  String? emailErrorText;
  String? passwordErrorText;


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: size.width, child: emailField(size)),
                SizedBox(height: size.height / 20),
                SizedBox(width: size.width, child: passwordField(size)),
                SizedBox(height: size.height / 20),
                button(size),
                SizedBox(height: size.height / 20),
                GestureDetector(
                  onTap: widget.goToSignInTab,
                  child: const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget button(Size size) {
    return GestureDetector(
      onTap: () {
        if (_email.text.isNotEmpty &&
            _password.text.isNotEmpty &&
            emailErrorText == null &&
            passwordErrorText == null) {
          setState(() {
            isLoading = true;
          });
          logIn(_email.text, _password.text).then((user) {
            if (user != null) {
              print("Login success");
              setState(() {
                isLoading = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatData()),
              );
            } else {
              print("Login failed");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login failed. Invalid credentials'),
                ),
              );
              setState(() {
                isLoading = false;
              });
            }
          });
        }
      },
      child: Container(
        height: size.height / 14,
        width: size.width / 1.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const CircularProgressIndicator(
                
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget emailField(Size size) {
    return SizedBox(
      child: TextField(
        controller: _email,
        decoration: InputDecoration(
          hintText: "Email",
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          errorText: emailErrorText,
          errorStyle: const TextStyle(height: 0),
        ),
        onChanged: (value) {
          setState(() {
            if (value.isEmpty || !isValidEmail(value)) {
              emailErrorText = "Invalid email address";
            } else {
              emailErrorText = null;
            }
          });
        },
      ),
    );
  }

  Widget passwordField(Size size) {
    return SizedBox(
      child: TextField(
        controller: _password,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          errorText: passwordErrorText,
          errorStyle: const TextStyle(height: 0),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
        ),
        onChanged: (value) {
          setState(() {
            if (value.isEmpty || value.length < 6) {
              passwordErrorText = "Password must be at least 6 characters";
            } else {
              passwordErrorText = null;
            }
          });
        },
      ),
    );
  }

  bool isValidEmail(String email) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
