import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:persoanlchatapp/home_page.dart';

Future<User?> createAccount(String name, String email, String password) async{
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;


try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      print("Account registered successfully!");
      await userCredential.user!.updateDisplayName(name); 
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "status": "Unavailable",
        "uid" : _auth.currentUser?.uid,
      });
      return userCredential.user;
    } else {
      print("Account registration failed");
      return userCredential.user; 
    }
  } catch (e) {
    print("Error creating account: $e");
    return null; 
  }
}

Future<User?> logIn(String email, String password) async{
  FirebaseAuth _auth = FirebaseAuth.instance;

try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      print("Loginsuccessfully!");
      return userCredential.user;
    } else {
      print("Login failed");
      return userCredential.user; 
    }
  } catch (e) {
    print("Error creating account: $e");
    return null; 
  }
}

Future logOut(BuildContext context) async{
  FirebaseAuth _auth = FirebaseAuth.instance;
try {
   await _auth.signOut().then((value){
    Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
   });
  } catch (e) {
    print("Error signingout $e");
   
  }
}