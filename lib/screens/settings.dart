import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Services
import '../services/database.dart';
import '../services/auth.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Database _database = GetIt.I.get<Database>();
  final Auth _auth = GetIt.I.get<Auth>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back),
          splashRadius: 20,
        ),
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              _database.setup(enable: true);
              Navigator.of(context).pop();
            },
            leading: Icon(Icons.edit),
            title: Text("Edit Timetable"),
          ),
          ListTile(
            onTap: () {
              _auth.signOut();
              Navigator.of(context).pop();
            },
            leading: Icon(Icons.exit_to_app),
            title: Text("Sign out"),
          ),
        ],
      ),
    );
  }
}
