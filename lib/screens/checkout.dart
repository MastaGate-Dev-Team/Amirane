import 'dart:convert';

import 'package:bouf/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;


class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> meals;
  final List<Map<String, dynamic>> sideDishes;

  const CheckoutPage({super.key, required this.meals, required this.sideDishes});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _numberController = TextEditingController();
  bool _isLoading = false;
    DateTime? _selectedDate;
                    TimeOfDay? _selectedTime;

  double getTotalPrice() {
  double totalPrice = widget.meals[0]['Price'] * (widget.meals[0]['quantity'] ?? 1);
    for (var sideDish in widget.sideDishes) {
      totalPrice += sideDish['Price'] * (sideDish['quantity'] ?? 0);
    }
    return totalPrice;
  }

  void _handleSubmit(wcontext) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      showModalBottomSheet(
        context: wcontext,
        builder: (BuildContext context) {
          return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
          children: [
            Icon(Icons.payment, size: 24.0),
            SizedBox(width: 8.0),
            Flexible(child: Text('Selectionnez votre Moyen de payment', style: TextStyle(fontSize: 16.0))),
          ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () async {
            Navigator.pop(context);
            final supabase = Supabase.instance.client;
            // Trigger API call to Flexpay Mobile Money API
            final flexpayApiUrl = 'https://api.flexpay.com/mobile-money';
            final response = await http.post(
              Uri.parse(flexpayApiUrl),
              headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer YOUR_FLEXPAY_API_KEY',
              },
              body: jsonEncode({
            'amount': getTotalPrice(),
            'phone_number': _numberController.text,
              }),
            );

            if (response.statusCode == 200) {
              // Handle successful payment
              print('Payment successful');
                supabase.from('orders').insert({
            'order_address': _addressController.text,
          'location': _locationController.text,
          'phone': _numberController.text,
          'Meal_ID': widget.meals[0]['ID'],
          'Quantity': widget.meals[0]['quantity'],
          'payment_method': 'cash',
          'delivery': _selectedDate!.toLocal().toString() + ' ' + _selectedTime!.toString(),
          'Total_Price': getTotalPrice(),
              }).select();
            } else {
              // Handle payment error
              print('Payment failed');
            }
          },
          child: Text('Payer avec Mobile-Money', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          onPressed: () async {
            Navigator.pop(context);
            // Save order with payment option selected
            final supabase = Supabase.instance.client;

            
              setState(() {
            _isLoading = false;
              });


      try {
        final response = await supabase.from('orders').insert({
          'order_address': _addressController.text,
          'location': _locationController.text,
          'phone': _numberController.text,
          'Meal_ID': widget.meals[0]['ID'],
          'payment_method': 'cash',
           'delivery': _selectedDate!.toLocal().toString() + ' ' + _selectedTime!.format(context),
          'Quantity': widget.meals[0]['quantity'],
          'Total_Price': getTotalPrice(),
        }).select();

widget.sideDishes.forEach((sideDish) async {
  print(sideDish);
        final sdresponse = await supabase.from('orders_side_dishes').insert({
          'side_dish_id': sideDish['ID'],
          'side_dish_qty': sideDish['quantity'],
          'order_id': response[0]['Order_ID'],
        }).select();
});
        print(response[0]);
        // if (response. != null) {
        //   throw response.error!;
        // }
      } catch (error) {
        // Handle error
        print('Error saving order: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
    
         WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(wcontext, rootNavigator: true).push(
          MaterialPageRoute(
        builder: (context) => OrderSummaryPage(
          meals: widget.meals,
          sideDishes: widget.sideDishes,
          address: _addressController.text,
          location: _locationController.text,
          number: _numberController.text,
        ),
          ),
        );

         });
        
      }
      // Send confirmation message
      // Send confirmation message on WhatsApp using WhatsApp Business API
      final whatsappApiUrl = 'https://graph.facebook.com/v13.0/243810109292/messages';
      final accessToken = 'EAASeB6fWhRcBO7AGOWgPO0SqZATvYblUAoEQ4gjVjZAuVu4qanQ3ZBZAL2ktwE1pUcNzcZBQOTZAlvfxZBPZA8bXCUeehVs0OB6zEXJlWFHicjbjDmYwFgUBStix4FArrPBPZBazpjKZAXglqx1hIbei3pFKgzhEcnjew2Jl37I640G0L1RI4QL1WehvE655mjPZBz7j9T4Jvy0v3e6NlpRaltTMOUOPdYZD';

      final messageData = {
        'messaging_product': 'whatsapp',
        'to': _numberController.text,
        'type': 'template',
        'template': {
          'name': 'order_confirmation',
          'language': {'code': 'en_US'},
          'components': [
        {
          'type': 'body',
          'parameters': [
            {'type': 'text', 'text': _addressController.text},
            {'type': 'text', 'text': _locationController.text},
            {'type': 'text', 'text': getTotalPrice().toStringAsFixed(2)},
          ],
        },
          ],
        },
      };

      try {
        final response = await http.post(
          Uri.parse(whatsappApiUrl),
          headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(messageData),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to send WhatsApp message');
        }
      } catch (error) {
        print('Error sending WhatsApp message: $error');
      }
         
          },
          child: Text('Payer a la livraison' , style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
          );
        },
      );

      // Save data to Supabase


      

     
    }
  }

  void _selectDateTime(BuildContext context) async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: 10, minute: 0),
                          builder: (BuildContext context, Widget? child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null && pickedTime.hour >= 10 && pickedTime.hour <= 22) {
                          setState(() {
                            _selectedDate = pickedDate;
                            _selectedTime = pickedTime;
                          });
                        } else {
                          // Show error if time is not within the allowed range
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selectionnez une heure entre 10:00 and 22:00')),
                          );
                        }
                      }
                    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(41, 91, 68,1),
        title: Text('Payement' , style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Prix Totale: \$${getTotalPrice().toStringAsFixed(2)}' , style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.meals.map((meal) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(meal['Image'], width: 60, height: 60),
                              Text('${meal['Name']} x${meal['quantity'] ?? 1}', style: TextStyle(fontSize: 16)),
                              Text('\$${(meal['Price'] * (meal['quantity'] ?? 1)).toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),
                    Text('Accompagnement:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.sideDishes.map((sideDish) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Image.network(sideDish['Image'], width: 60, height: 60),
                          Text('${sideDish['Name']} x${sideDish['quantity'] ?? 1}', style: TextStyle(fontSize: 16)),
                          Text('\$${(sideDish['Price'] * (sideDish['quantity'] ?? 1)).toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                        ],
                        ),
                      );
                      }).toList(),
                    ),

                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Addresse'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Votre address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: 'Nom Complet'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Entrez votre Noms';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _numberController,
                      decoration: InputDecoration(labelText: 'Contact (Whatsapp)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Numero de telephone';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                  

                    

                    TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Color.fromRGBO(41, 91, 68,1)),
                      ),
                      onPressed: () => _selectDateTime(context),
                      child: Text(
                        _selectedDate == null || _selectedTime == null
                            ? 'Selectionnez la date et l\'heure de livraison'
                            : 'Livraison: ${_selectedDate!.toLocal()} ${_selectedTime!.format(context)}',
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(41, 91, 68,1)),
                      onPressed: () => _handleSubmit(context),
                      child: Text('Passer La Commande', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class OrderSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> meals;
  final List<Map<String, dynamic>> sideDishes;
  final String address;
  final String location;
  final String number;
  

  OrderSummaryPage({
    required this.meals,
    required this.sideDishes,
    required this.address,
    required this.location,
    required this.number,
  });

    double getTotalPrice() {
  double totalPrice = meals[0]['Price'] * (meals[0]['quantity'] ?? 1);
    for (var sideDish in sideDishes) {
      totalPrice += sideDish['Price'] * (sideDish['quantity'] ?? 0);
    }
    return totalPrice;
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      
  onPopInvokedWithResult: (bool didPop, Object? result) async {
    if (didPop) {
      return;
    }

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (context) => HomePage(),
  ),
  (Route<dynamic> route) => false,
);
    
    }
  },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Commande'),
          backgroundColor: Color.fromRGBO(41, 91, 68,1),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Color.fromRGBO(41, 91, 68,1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Address: $address', style: TextStyle(color: Colors.white)),
                      Text('Location: $location', style: TextStyle(color: Colors.white)),
                      Text('Phone Number: $number', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text('Repas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...meals.map((meal) => Card(
                child: ListTile(
                  title: Text('${meal['Name']}'),
                  trailing: Text('\$${meal['Price']}'),
                ),
              )),
              Text('Accomp :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...sideDishes.map((sides) => Card(
                child: ListTile(
                  title: Text('${sides['Name']}'),
                  trailing: Text('\$${sides['Price']}'),
                ),
              )),
              SizedBox(height: 16.0),
              Text('Prix Total: \$${getTotalPrice()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Text('Statut Commande:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Expanded(
                child: Stepper(
                  
                  steps: [
                    Step(
                      title: Text('Commande Placee'),
                      content: Text('Commande enregistrer.'),
                      isActive: true,
                      state: StepState.complete,
                    ),
                    Step(
                      title: Text('Preparation'),
                      content: Text('Votre Commande est en preparation.'),
                      isActive: true,
                      state: StepState.indexed,
                    ),
                    Step(
                      title: Text('En Chemin'),
                      content: Text('Votre plat est en route'),
                      isActive: false,
                      state: StepState.indexed,
                    ),
                    Step(
                      title: Text('Deliverez'),
                      content: Text('Livraison Effectues.'),
                      isActive: false,
                      state: StepState.indexed,
                    ),
                  ],
                  currentStep: 1,
                  onStepContinue: () {},
                  onStepCancel: () {},
                  onStepTapped: (step) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}