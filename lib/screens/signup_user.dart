import 'package:bouf/screens/entrypoint.dart';
import 'package:bouf/screens/login.dart';
import 'package:bouf/screens/login_up_restaurant.dart';
import 'package:bouf/services/authservices.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
        import 'package:shared_preferences/shared_preferences.dart';
        import 'package:bouf/screens/homepage.dart';


class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  String selectedCountryCode = '+243'; // Default to Congo DRC

  final List<Map<String, String>> africanCountries = [
    {'name': 'Algeria', 'code': '+213'},
    {'name': 'Angola', 'code': '+244'},
    {'name': 'Benin', 'code': '+229'},
    {'name': 'Botswana', 'code': '+267'},
    {'name': 'Burkina Faso', 'code': '+226'},
    {'name': 'Burundi', 'code': '+257'},
    {'name': 'Cameroon', 'code': '+237'},
    {'name': 'Cape Verde', 'code': '+238'},
    {'name': 'Central African Republic', 'code': '+236'},
    {'name': 'Chad', 'code': '+235'},
    {'name': 'Comoros', 'code': '+269'},
    {'name': 'Congo DRC', 'code': '+243'},
    {'name': 'Djibouti', 'code': '+253'},
    {'name': 'Egypt', 'code': '+20'},
    {'name': 'Equatorial Guinea', 'code': '+240'},
    {'name': 'Eritrea', 'code': '+291'},
    {'name': 'Eswatini', 'code': '+268'},
    {'name': 'Ethiopia', 'code': '+251'},
    {'name': 'Gabon', 'code': '+241'},
    {'name': 'Gambia', 'code': '+220'},
    {'name': 'Ghana', 'code': '+233'},
    {'name': 'Guinea', 'code': '+224'},
    {'name': 'Kenya', 'code': '+254'},
    {'name': 'Lesotho', 'code': '+266'},
    {'name': 'Liberia', 'code': '+231'},
    {'name': 'Libya', 'code': '+218'},
    {'name': 'Madagascar', 'code': '+261'},
    {'name': 'Malawi', 'code': '+265'},
    {'name': 'Mali', 'code': '+223'},
    {'name': 'Mauritania', 'code': '+222'},
    {'name': 'Morocco', 'code': '+212'},
    {'name': 'Mozambique', 'code': '+258'},
    {'name': 'Namibia', 'code': '+264'},
    {'name': 'Niger', 'code': '+227'},
    {'name': 'Nigeria', 'code': '+234'},
    {'name': 'Rwanda', 'code': '+250'},
    {'name': 'Senegal', 'code': '+221'},
    {'name': 'Seychelles', 'code': '+248'},
    {'name': 'South Africa', 'code': '+27'},
    {'name': 'Sudan', 'code': '+249'},
    {'name': 'Tanzania', 'code': '+255'},
    {'name': 'Togo', 'code': '+228'},
    {'name': 'Tunisia', 'code': '+216'},
    {'name': 'Uganda', 'code': '+256'},
    {'name': 'Zambia', 'code': '+260'},
    {'name': 'Zimbabwe', 'code': '+263'},
  ];

  void sendOTP() async {
    try {
      print(emailController.text);
     var user = await supabase.auth.signUp(email: emailController.text,password: passwordController.text);
        // phone: '$selectedCountryCode${phoneController.text
        print(user); 
          Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: emailController.text),
        ),
      );
        
  
      
    } catch (e) {
      if (e.toString().contains('email already exists')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email already exists')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      
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
              Image.asset('assets/images/icon_white.png', width: 300),
              SizedBox(height: 20),
              Text('Entrez votre adresse Email pour creer un compte', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 20),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                     TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Votre Adresse Email', border: InputBorder.none),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    DropdownButtonFormField(
                      value: selectedCountryCode,
                      items: africanCountries.map((country) {
                        return DropdownMenuItem(
                          value: country['code'],
                          child: Text('${country['name']} (${country['code']})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCountryCode = value as String;
                        });
                      },
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Enter your mobile number', border: InputBorder.none),
                      keyboardType: TextInputType.phone,
                    ),
                     TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Mot de passe', border: InputBorder.none),
                      keyboardType: TextInputType.phone,
                    ),
                   
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom( padding: EdgeInsets.all(20), backgroundColor: Colors.orange),
                onPressed: sendOTP,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Creer Un Compte", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),

                   SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to restaurant login screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
                  );
                },
                child: Text(
                  'Vous avez deja un compte ? Connectez-vous ici',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class OtpVerificationScreen extends StatefulWidget {
  final String email;

  OtpVerificationScreen({required this.email});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> otpController = [];
  final supabase = Supabase.instance.client;
  final _authService = AuthService();

  void verifyOTP() async {
    try {
    //  var response =  await _authService.verifyOTP(
    //     widget.phone,
    //     otpController[0].text+otpController[1].text+otpController[2].text+otpController[3].text,
    //   );
    //   if (response.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP Verified Successfully!')));
        // Navigate to home screen or next step

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', widget.email);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => EntrypointScreen()),
          (Route<dynamic> route) => false,
        );
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
              Text('VERIFICATION', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Entrez le code 4 chiffres recu par email', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  otpController.add(TextEditingController());
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 50,
                    height: 50,
                    child: TextField(
                      controller: otpController[index],
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 24, color: Colors.black),
                        onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                        },
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
                child: Text('Verifier', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
