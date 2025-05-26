import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bouf/screens/dashboard.dart';

import 'package:path_provider/path_provider.dart';

class RestaurantLoginSignupScreen extends StatefulWidget {
  @override
  _RestaurantLoginSignupScreenState createState() => _RestaurantLoginSignupScreenState();
}

class _RestaurantLoginSignupScreenState extends State<RestaurantLoginSignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLogin = true;

  void toggleFormType() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void login() async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (response.session != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void signup() async {
    try {
      final response = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );
      if (response.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(userId: response.user!.id)),
        );
        print(response.user);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(41, 91, 68,1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/icon_white.png', width: 200),
              Text(
                isLogin ? 'Login to your Restaurant' : 'Sign up your Restaurant',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email', border: InputBorder.none, filled: true, fillColor: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password', border: InputBorder.none, filled: true, fillColor: Colors.white),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLogin ? login : signup,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(isLogin ? 'Login' : 'Sign Up', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: toggleFormType,
                child: Text(isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String? logoUrl;
  final supabase = Supabase.instance.client;

  void pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = result.files.first;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${file.name}');
      await tempFile.writeAsBytes(file.bytes!);
      final response = await supabase.storage.from('logos').upload(file.name, tempFile);
      setState(() {
        logoUrl = response;
      });
    }
  }

  void saveProfile() async {
    try {
      final response = await supabase.from('restaurants').insert({
        'user_id': widget.userId,
        'phone': phoneController.text,
        'name': nameController.text,
        'description': descriptionController.text,
        'location': locationController.text,
        'logo_url': logoUrl,
      }).select();
      if (response.isNotEmpty) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: Failed to save profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(41, 91, 68,1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Complete your Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 20),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number', border: InputBorder.none, filled: true, fillColor: Colors.white),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name', border: InputBorder.none, filled: true, fillColor: Colors.white),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description', border: InputBorder.none, filled: true, fillColor: Colors.white),
              ),
              SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location', border: InputBorder.none, filled: true, fillColor: Colors.white),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickLogo,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('Pick Logo', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('Save Profile', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}