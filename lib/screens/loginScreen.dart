import 'package:flutter/material.dart';

import 'announScreen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  void goToMainPage(String nickname, BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AnnouncementScreen(nickname)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text("Login Page")),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Nickname"),
              onSubmitted: (nickname) => goToMainPage(nickname, context),
            ),
            ElevatedButton(
                onPressed: () => goToMainPage(controller.text, context),
                child: Text("Log In"))
          ],
        ),
      ));
}