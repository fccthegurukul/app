import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          SwitchListTile(
            title: Text('Dark Mode (preview)'),
            value: false,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dark mode toggle placeholder')));
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('Hindi (default)'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
