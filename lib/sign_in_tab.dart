import 'package:flutter/material.dart';
import 'package:persoanlchatapp/chat_data.dart';
import 'package:persoanlchatapp/methods.dart';

class SignInTab extends StatefulWidget {
  const SignInTab({
    Key? key,
  }) : super(key: key);

  @override
  SignInTabState createState() => SignInTabState();
}

class SignInTabState extends State<SignInTab> {
  bool showOtpField = false;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  String? emailErrorText;
  String? passwordErrorText;
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: size.width, child: field(size, "Name", _name)),
                SizedBox(height: size.height / 20),
                SizedBox(
                    width: size.width, child: emailField(size)),
                SizedBox(height: size.height / 20),
                SizedBox(
                    width: size.width,
                    child: passwordField(size)),
                SizedBox(height: size.height / 20),
                button(size),
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
        if (_name.text.isNotEmpty &&
            _email.text.isNotEmpty &&
            _password.text.isNotEmpty &&
            emailErrorText == null &&
            passwordErrorText == null) {
          setState(() {
            isLoading = true;
          });
          createAccount(_name.text, _email.text, _password.text)
              .then((user) => {
                    if (user != null)
                      {
                        setState(() {
                          isLoading = false;
                        }),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatData())),
                        print("signIn succes!")
                      }
                    else
                      {
                        print("signIn failed"),
                        setState(() {
                          isLoading = false;
                        })
                      }
                  });
        } else {
          print("Please enter valid fields");
        }
      },
      child: Container(
          height: size.height / 14,
          width: size.width / 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.black),
          alignment: Alignment.center,
        child: isLoading
            ? const CircularProgressIndicator(
                
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text(
                "Cretae Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
    );
  }

  Widget field(Size size, String hintText, TextEditingController cont) {
    return SizedBox(
      height: size.height / 14,
      width: size.width / 1.1,
      child: TextField(
        controller: cont,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
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
          suffixIcon: IconButton(onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          }, icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,))
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
