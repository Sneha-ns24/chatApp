// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persoanlchatapp/chat_window.dart';
import 'package:persoanlchatapp/methods.dart';

class ChatData extends StatefulWidget {
  const ChatData({Key? key}) : super(key: key);

  @override
  State<ChatData> createState() => _ChatDataState();
}

class _ChatDataState extends State<ChatData> with WidgetsBindingObserver {
  late List<DocumentSnapshot> usersList = [];
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    WidgetsBinding.instance!.addObserver(this);
    setstatus("Online");
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void setstatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setstatus("Online");
    } else {
      setstatus("Offline");
    }
  }

  String chatWindowId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future<void> fetchUsers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        usersList = usersSnapshot.docs.where((doc) => doc.exists).toList();
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  void updateUserData() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await currentUser
            .updateDisplayName(_auth.currentUser?.displayName ?? '');

        await currentUser.updateEmail(_auth.currentUser?.email ?? '');

        await _firestore.collection('users').doc(currentUser.uid).update({
          "name": currentUser.displayName,
          "email": currentUser.email,
        });
        await fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
      }
    } catch (error) {
      print('Error updating user data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: $error')),
      );
    }
  }

// void deleteUser(BuildContext context) async {
//   try {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(_auth.currentUser!.uid)
//         .delete();

//     await _auth.currentUser!.delete();
//     await _auth.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const HomePage()),
//     );
//   } catch (error) {
//     print('Error deleting user: $error');

//   }
// }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatApp"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => showLogoutConfirmationDialog(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 35, left: 20),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: TextFormField(
                    initialValue: _auth.currentUser?.displayName ?? 'Unknown',
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _auth.currentUser?.updateDisplayName(value);
                      });
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: TextFormField(
                    initialValue: _auth.currentUser?.email ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _auth.currentUser?.updateEmail(value);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: size.height / 14,
                  width: size.width / 1.8,
                  child: ElevatedButton(
                    onPressed: () {
                      updateUserData();
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    child: const ListTile(
                      title: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // SizedBox(
                //   height: size.height / 14,
                //   width: size.width / 1.8,
                // child: ElevatedButton(
                //   onPressed: () {
                //     showDeleteAccountConfirmationDialog(context);
                //   },
                //   style: ButtonStyle(
                //     backgroundColor:
                //         MaterialStateProperty.all<Color>(const Color.fromARGB(255, 195, 67, 58)),
                //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                //       RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(30),
                //       ),
                //     ),
                //   ),
                // child: ListTile(
                //   title: const Align(
                //     alignment: Alignment.center,
                //     child: Text(
                //       'Delete Account',
                //       style: TextStyle(color: Colors.white, fontSize: 16),
                //     ),
                //   ),
                //   onTap: () {
                //     showDeleteAccountConfirmationDialog(context);
                //   },
                // ),
                // ),
                // ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : ListView.builder(
              itemCount: usersList.length + 1, // Add 1 for the current user
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Display the current user's data as the first tile
                  return ListTile(
                    onTap: () {
                      String? displayName = _auth.currentUser?.displayName;
                      String roomId = chatWindowId(
                          displayName ?? 'Unknown', displayName ?? 'Unknown');
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ChatWindow(chatWindowId: roomId, userMap: {
                          'name': displayName,
                          'email': _auth.currentUser?.email,
                        }),
                      ));
                    },
                    title: const Text(
                      "You",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    subtitle: Text(_auth.currentUser?.email ?? ""),
                    trailing: const Icon(Icons.chat, color: Colors.black),
                  );
                } else {
                  // Display other users' data starting from index 1
                  final userData =
                      usersList[index - 1].data() as Map<String, dynamic>;
                  return ListTile(
                    onTap: () {
                      String roomId = chatWindowId(
                          _auth.currentUser?.displayName ?? 'Unknown',
                          userData['name']);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChatWindow(
                              chatWindowId: roomId, userMap: userData)));
                    },
                    leading: const Icon(Icons.account_box, color: Colors.black),
                    title: Text(
                      userData['name'],
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    subtitle: Text(userData['email']),
                    trailing: const Icon(Icons.chat, color: Colors.black),
                  );
                }
              },
            ),
    );
  }

//   void showDeleteAccountConfirmationDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         content: const Text(
//           "Are you sure you want to delete your account? This action cannot be undone!",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//         actions: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(color: Colors.black, fontSize: 18),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Close the drawer
//                   Navigator.pop(context);
//                   // Show circular progress indicator
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (BuildContext context) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     },
//                   );
//                   deleteUser(context);
//                   barrierDismissible: true,
//                 },
//                 child: const Text("Delete",
//                     style: TextStyle(color: Colors.red, fontSize: 18)),
//               ),
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "No",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    logOut(context);
                  },
                  child: const Text("Yes",
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
