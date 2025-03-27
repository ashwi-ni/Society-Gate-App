import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:society_gate_app/authentication/phone.dart';
import 'package:society_gate_app/screens/profileupdateScreen.dart';
import 'package:society_gate_app/screens/visitor_arrival.dart';
import 'package:society_gate_app/widgets/setting_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SettingScreen extends StatefulWidget {
  final Function(Locale) setLocale; // Add this line

  const SettingScreen({Key? key, required this.setLocale}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String currentLanguage = "English";

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.logout),
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MyPhone()),
    );
  }

  void _changeLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('English'),
                onTap: () {
                  widget.setLocale(Locale('en'));
                  setState(() {
                    currentLanguage = "English";
                  });
                  print("Changed language to English"); // Add this line
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Spanish'),
                onTap: () {
                  widget.setLocale(Locale('es'));
                  setState(() {
                    currentLanguage = "Spanish";
                  });
                  print("Changed language to Spanish"); // Add this line
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('हिंदी'),
                onTap: () {
                  widget.setLocale(Locale('hi'));
                  setState(() {
                    currentLanguage = "हिंदी";
                  });
                  print("Changed language to हिंदी"); // Add this line
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('मराठी'),
                onTap: () {
                  widget.setLocale(Locale('mr'));
                  setState(() {
                    currentLanguage = "मराठी";
                  });
                  print("Changed language to मराठी "); // Add this line
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.chevron_left_outlined, color: Colors.blueGrey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileUpdateScreen()),
                  );
                },
                child: SettingItem(
                  title: AppLocalizations.of(context)!.editProfile,
                  icon: Ionicons.person,
                  bgColor: Colors.brown.shade100,
                  iconColor: Colors.brown,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _changeLanguage(context),
                child: SettingItem(
                  title: AppLocalizations.of(context)!.language,
                  icon: Ionicons.earth,
                  bgColor: Colors.orange.shade100,
                  iconColor: Colors.orange,
                  value: currentLanguage,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VisitorArrival()),
                  );
                },
                child: SettingItem(
                  title: AppLocalizations.of(context)!.notifications,
                  icon: Ionicons.notifications,
                  bgColor: Colors.blue.shade100,
                  iconColor: Colors.blue,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: AppLocalizations.of(context)!.help,
                icon: Ionicons.nuclear,
                bgColor: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _handleLogout(context),
                child: SettingItem(
                  title: AppLocalizations.of(context)!.logout,
                  icon: Ionicons.log_out,
                  bgColor: Colors.pink.shade100,
                  iconColor: Colors.pink,
                  onTap: () => _handleLogout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


