import 'package:bouf/screens/signup_user.dart';
import 'package:flutter/material.dart';
import 'package:bouf/services/authservices.dart';
import 'package:bouf/screens/login.dart';
import 'package:bouf/screens/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}





class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  OtpVerificationScreen({required this.phone});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
 final AuthService _authService = AuthService();

  void verifyOTP() async {
    try {

      final response = await _authService.verifyOTP(widget.phone, otpController.text);
      // if (response. != null) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP Verified Successfully!')));
      //   // Navigate to home screen or next step
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP')));
      // }
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
              Text('Enter OTP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 50,
                    height: 50,
                    child: TextField(
                      controller: otpController,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 24, color: Colors.black),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifyOTP,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('Verify', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}