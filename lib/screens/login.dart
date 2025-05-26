import 'package:bouf/screens/login_up_restaurant.dart';
import 'package:bouf/services/authservices.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
        import 'package:shared_preferences/shared_preferences.dart';
        import 'package:bouf/screens/homepage.dart';


class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController phoneController = TextEditingController();
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
      // await supabase.auth.signInWithOtp(phone: '$selectedCountryCode${phoneController.text}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(phone: '$selectedCountryCode${phoneController.text}'),
        ),
      );
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
              Text('Entrez votre numero de Telephone', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 20),
              
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
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
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.all(20), backgroundColor: Colors.orange),
                onPressed: sendOTP,
                child: Row(
                  children: [
                    Text("Se connecter"),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.all(20), backgroundColor: Colors.orange),
                onPressed: () {
                  // Navigate to signup screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RestaurantLoginSignupScreen()),
                  );
                },
                child: Row(
                  children: [
                    Text("Creer un Compte"),
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
                    MaterialPageRoute(builder: (context) => RestaurantLoginSignupScreen()),
                  );
                },
                child: Text(
                  'Vous êtes un restaurant? Connectez-vous ici',
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
  final String phone;

  OtpVerificationScreen({required this.phone});

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
        await prefs.setString('phone', widget.phone);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
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
              Text('Entrez le code 4 chiffres recu par sms', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
