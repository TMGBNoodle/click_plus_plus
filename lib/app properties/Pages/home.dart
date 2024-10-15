import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:click_plus_plus/app properties/routing/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _score = 0;
  String _name = "";

  @override
  void initState() {
    super.initState();
    _loadScore();
    _getName();
  }

  Future<void> _loadScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _score = doc.data()?['score'] ?? 0;
        });
      }
    }
  }

  Future<void> _getName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()?['name'] != null) {
        setState(() {
          _name = doc.data()?['name'] ?? "";
        });
      } else {
        setState(() {
          _name = "false";
        });
      }
    } else {
      setState(() {
        _name = "false";
      });
    }
  }

  Future<void> _incrementScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _score++;
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'score': _score,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _setName(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
      }, SetOptions(merge: true));
      _name = name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          TextButton(
            onPressed: () =>
                AppRouter.navigateTo(context, AppRouter.scoreboard),
            child: Text('$_score', style: const TextStyle(fontSize: 20)),
          ),
          PopupMenuButton<String>(
              icon: const Icon(Icons.settings),
              onSelected: (String result) {
                // Handle menu item selection
                switch (result) {
                  case 'profilePage':
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      AppRouter.navigateTo(context, AppRouter.userProfile,
                          arguments: {'userId': user.uid});
                    }
                    break;
                  case 'option2':
                    // Handles option 2
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'profilePage',
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'option2',
                      child: Text('Option 2'),
                    )
                  ])
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final myController = TextEditingController();
            if (_name == "false" || _name == "") {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text("Please enter your name."),
                        content:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          TextField(
                            controller: myController,
                          ),
                          ElevatedButton(
                              onPressed: () => {
                                    _setName(myController.text),
                                    Navigator.pop(context)
                                  },
                              child: const Text("Set Name"))
                        ]),
                      ));
            } else {
              _incrementScore();
            }
          },
          child: const Text('Increment Score'),
        ),
      ),
    );
  }
}

extension on Future<DocumentSnapshot<Map<String, dynamic>>> {
  data() {}
}
