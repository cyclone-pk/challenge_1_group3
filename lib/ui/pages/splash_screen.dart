import 'package:challenge1_group3/provider/user_provider.dart';
import 'package:challenge1_group3/ui/pages/home_page.dart';
import 'package:challenge1_group3/ui/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      UserProvider provider = Provider.of<UserProvider>(context, listen: false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => provider.currentUser == null ? LoginScreen() : HomePage()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
