import 'package:bouf/screens/RestaurantMealsPage.dart';
import 'package:bouf/screens/checkout.dart';
import 'package:bouf/services/authservices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();

}


class _HomePageState extends State<HomePage> {
  // final _authService = AuthService();
  final customerNameController = TextEditingController();
  final contactNumberController = TextEditingController();
  final emailController = TextEditingController();
  final eventTypeController = TextEditingController();
  final eventDateController = TextEditingController();
  final guestCountController = TextEditingController();
  final menuPreferencesController = TextEditingController();
  final specialRequestsController = TextEditingController();
  final budgetEstimateController = TextEditingController();
  final venueLocationController = TextEditingController();
  final supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> meals = [];
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    // fetchMeals();
  }

  Future<PostgrestList> fetchMeals() async {
    return await supabaseClient.from('repas').select();
    // if (response.isEmpty) {
    //   setState(() {
    //     meals = List<Map<String, dynamic>>.from(response);
    //   });
    // }
  }

  Future<List<Map<String, dynamic>>> fetchRestaurants() async {
  final response = await supabaseClient.from('restaurants').select();
  if (response.isEmpty) {
    return [];
  }
  return List<Map<String, dynamic>>.from(response);
}


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(41, 91, 68,1),
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/images/logo.png', height: 40),
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Acceuil'),
              Tab(icon: Icon(Icons.assignment), text: 'Traiteur'),
              Tab(icon: Icon(Icons.history), text: 'Commandes'),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
        onPressed: () {
          const supportNumber = '+243810109292'; // Replace with your support number
          final whatsappUrl = 'https://wa.me/$supportNumber';
          launchUrl(Uri.parse(whatsappUrl));
        },
        child: const Icon(Icons.support_agent),
      ),
        body: TabBarView(
          children: [
            buildHomeTab(),
            buildOrderTab(),
            buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget buildHomeTab() {
    return FutureBuilder(
      future: fetchMeals(),
      builder: (context, snapshot) {
        print("Fetching meals***************");
        print(snapshot.hasData);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching meals'));
        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(child: Text('No meals available'));
        } else {
          meals = snapshot.data as List<Map<String, dynamic>>;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      meals = meals.where((meal) {
                        return meal['Name']
                            .toLowerCase()
                            .contains(value.toLowerCase());
                      }).toList();
                    });
                  },
                ),
              ),

                Container(
                height: 150,
                child: FutureBuilder(
                  future: fetchRestaurants(),
                  builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching restaurants'));
                  } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                    return Center(child: Text('No restaurants available'));
                  } else {
                    final restaurants = snapshot.data as List<Map<String, dynamic>>;
                    return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantMealsPage(restaurant: restaurant),
                        ),
                        );
                      },
                      child: Card(
                        child: Column(
                        children: [
                          Image.network(
                          restaurant['logo_url'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          ),
                          Text(restaurant['name']),
                        ],
                        ),
                      ),
                      );
                    },
                    );
                  }
                  },
                ),
                ),

              Expanded(
                child: Swiper(
                  itemCount: meals.length,
                  itemBuilder: (BuildContext context, int index) {
                    final meal = meals[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MealDetailPage(meal: meal),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'meal-${meal['ID']}',
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.5),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  meal['Image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Text(
                                  meal['Name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  // pagination: const SwiperPagination(),
                  control: const SwiperControl(),
                  viewportFraction: 0.8,
                  scale: 0.9,
                ),
              ),
            ],
          );
        }
      },
    );
  }

 
  Widget buildOrderTab() {
    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          child: Swiper(
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/images/RSshutterstock_218687860.jpg', height: 200),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Commandez Un Service Traiteur ${index + 1}',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
            // pagination: const SwiperPagination(),
            // control: const SwiperControl(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                   
                      children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Remplissez les champs ci-dessous pour passer une commande de service traiteur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      TextField(
                        decoration: InputDecoration(
                        labelText: 'Nom complet',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                        labelText: 'Contacts',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ),
                      ),
                      const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Type d\'événement',
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                          value: 'Mariage',
                          child: Text('Mariage'),
                          ),
                          DropdownMenuItem(
                          value: 'Anniversaire',
                          child: Text('Anniversaire'),
                          ),
                          DropdownMenuItem(
                          value: 'Réunion',
                          child: Text('Réunion'),
                          ),
                          DropdownMenuItem(
                          value: 'Autre',
                          child: Text('Autre'),
                          ),
                        ],
                        onChanged: (value) {
                          // Handle event type selection
                        },
                        ),
                      const SizedBox(height: 16),
                        TextField(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                          setState(() {
                            // Format the date as needed
                            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                            // Update the TextField with the selected date
                            // Assuming you have a TextEditingController for this TextField
                            // dateController.text = formattedDate;
                          });
                          }
                        },
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                        labelText: 'Nombre D\'invites',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                        labelText: 'Menu Preferences',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                        labelText: 'Requetes Speciales',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                        labelText: 'Estimatation du Budget',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                        // Handle order submission
                        final customerName = customerNameController.text;
                        final contactNumber = contactNumberController.text;
                        final email = emailController.text;
                        final eventType = eventTypeController.text;
                        final eventDate = eventDateController.text;
                        final guestCount = guestCountController.text;
                        final menuPreferences = menuPreferencesController.text;
                        final specialRequests = specialRequestsController.text;
                        final budgetEstimate = budgetEstimateController.text;
                        final venueLocation = venueLocationController.text;
                        final inquiryDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

                        final response = await supabaseClient.from('catering').insert({
                          'CustomerName': customerName,
                          'ContactNumber': contactNumber,
                          'Email': email,
                          'EventType': eventType,
                          'EventDate': eventDate,
                          'GuestCount': guestCount,
                          'MenuPreferences': menuPreferences,
                          'SpecialRequests': specialRequests,
                          'BudgetEstimate': budgetEstimate,
                          'VenueLocation': venueLocation,
                          'InquiryDate': inquiryDate,
                        });

                        if (response == null) {
                          Navigator.pop(context);
                          showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                            content: Row(
                              children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 10),
                              Flexible(child: Text('Votre commande a bien été enregistrée')),
                              ],
                            ),
                            actions: [
                              TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                              ),
                            ],
                            );
                          },
                          );
                        } else {
                          // Handle error
                        }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(41, 91, 68,1),
                        ),
                        child: const Text('Envoyer La Demande', style: TextStyle(color: Colors.white)),
                      ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Text('Remplir Le Formulaire De Commande'),
          ),
        ),
      ],
    );
  }


Widget buildHistoryTab() {
  return FutureBuilder(
    future: fetchOrders(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        print(snapshot.error);
        return Center(child: Text('Error fetching orders'));
      } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
        return Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 100, color: Colors.grey),
              Text('Pas de Commandes !', style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      } else {
        final orders = snapshot.data as List<Map<String, dynamic>>;
        return RefreshIndicator(
          onRefresh: fetchOrders,
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(order: order),
                    ),
                  );
                },
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24))),
          child: Icon(Icons.delivery_dining, color: Colors.white),
        ),
        title: Text(
          DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(order['Date'])),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        

        subtitle: Column(
          children: [
             Row(
              children: <Widget>[
                Icon(Icons.calendar_month, color: Colors.yellowAccent),
                Text( DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(order['Date'])), style: TextStyle(color: Colors.white))
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.pin_drop, color: Colors.yellowAccent),
                Text(order['order_address'], style: TextStyle(color: Colors.white))
              ],
            ),
          ],
        ),
        trailing: order['order_state'] == 3 ? Tag(color: Colors.green, text: 'Delivered') : order['order_state'] == 4 ? Tag(color: Colors.red, text: 'Canceled') : Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0));
            // Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)); 
              
              //  ListTile(
              //   title: Text('Order Date: ${order['Date']}'),
              //   subtitle: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('State: ${order['order_state']}'),
              //       Text('Address: ${order['order_address']}'),
              //     ],
              //   ),
              //   trailing: order['order_state'] == 'delivered'
              //       ? Tag(color: Colors.green, text: 'Delivered')
              //       : order['order_state'] == 'canceled'
              //           ? Tag(color: Colors.red, text: 'Canceled')
              //           : null,
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => OrderDetailPage(order: order),
                //     ),
                //   );
                // }
              // );
            },
          ),
        );
      }
    },
  );
}

Future<List<Map<String, dynamic>>> fetchOrders() async {
  final user = supabaseClient.auth.currentUser;
  if (user == null) {
    return [];
  }
  final response = await supabaseClient.from('orders').select();
  // .eq('user', user.id);
  if (response.isEmpty) {
    return [];
  }
  return List<Map<String, dynamic>>.from(response);
}
}

class Tag extends StatelessWidget {
final Color color;
final String text;

const Tag({Key? key, required this.color, required this.text}) : super(key: key);

@override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(color: Colors.white),
    ),
  );
}
}

class OrderDetailPage extends StatefulWidget {
final Map<String, dynamic> order;

 OrderDetailPage({Key? key, required this.order}) : super(key: key);


@override
_OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {


 List<Map<String, dynamic>> meals = [];
 List<Map<String, dynamic>> sideDishes = [];
 
 final supabase = Supabase.instance.client;

@override
  void initState() {
    // TODO: implement initState
    getOrderMealsAndsideDishes();
    super.initState();
  }

  Future<void> getOrderMealsAndsideDishes() async {
    // Implement the logic to fetch order meals and side dishes
   
  

    final mealResponse = await supabase
      .from('repas')
      .select()
      .eq('ID', widget.order['Meal_ID']);
    final sideDishResponse = await supabase
      .from('orders_side_dishes')
      .select('''
  side_dish_qty,
    side_dish (
      ID,
      Name,
      Price
    )
  ''')
      .eq('order_id', widget.order['Order_ID']);

    setState(() {
      meals = List<Map<String, dynamic>>.from(mealResponse);
      sideDishes = List<Map<String, dynamic>>.from(sideDishResponse);
      print(sideDishes);
    });
  }

@override
Widget build(BuildContext context) {
    print(widget.order['Order_ID']);
return Scaffold(
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
                      Text('Address: ${widget.order['order_address']}', style: TextStyle(color: Colors.white)),
                      Text('Nom Complet: ${widget.order['location']}', style: TextStyle(color: Colors.white)),
                      Text('Phone Number: ${widget.order['phone']}', style: TextStyle(color: Colors.white)),
                      Text('Payment Method: ${widget.order['payment_method']}', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text('Repas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...meals.map((meal) => Card(
                child: ListTile(
                  title: Text('${meal['Name']}'),
                  trailing: Text('\$${meal['Price']} x ${widget.order['Quantity']}'),
                ),
              )),
              Text('Accomp :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...sideDishes.map((sides) => Card(
                child: ListTile(
                  title: Text('${sides['side_dish']['Name']}'),
                  trailing: Text('\$${sides['side_dish']['Price']} x ${sides['side_dish_qty']}'),
                ),
              )),
              SizedBox(height: 16.0),
              Text('Prix Total: \$${widget.order['Total_Price']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Text('Statut Commande:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Expanded(
                child: Stepper(
                  
                  controlsBuilder: (BuildContext context, ControlsDetails details) {
                    return Row(
                      children: <Widget>[
                        if (widget.order['order_state'] < 3)
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: const Text('Continuer'),
                          ),
                        if (widget.order['order_state'] < 3)
                          TextButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmation'),
                                    content: Text('Etes vous sur de vouloir annuler ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Non'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final response = await supabase.from('orders')
                                              .update({'order_state': 4})
                                              .eq('Order_ID', widget.order['Order_ID']);
                                          if (response == null) {
                                            setState(() {
                                              widget.order['order_state'] = 4;
                                            });
                                            Navigator.of(context).pop();
                                          } else {
                                            // Handle error
                                          }
                                        },
                                        child: Text('Oui'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            //  final response = supabase.from('orders')
                            //       .update({'order_state': 4})
                            //       .eq('Order_ID', widget.order['Order_ID']);
                            //   if (response != null) {
                            //     setState(() {
                            //       widget.order['order_state'] = 4;
                            //     });
                            //   }
                            },
                            child: const Text('Annuler'),
                          ),
                      ],
                    );
                  },
                  steps: [
                    Step(
                      title: Text('Commande Placee'),
                      content: Text('Commande enregistrer.'),
                      isActive: widget.order['order_state'] ==0? true: false,
                      state: widget.order['order_state'] == 0 ? StepState.complete: StepState.indexed,
                    ),
                    Step(
                      title: Text('Preparation'),
                      content: Text('Votre Commande est en preparation.'),
                      isActive: widget.order['order_state'] > 0? true: false,
                      state: widget.order['order_state'] == 1 ? StepState.complete: StepState.indexed,
                    ),
                    Step(
                      title: Text('En Chemin'),
                      content: Text('Votre plat est en route'),
                      isActive: widget.order['order_state'] >1? true: false,
                      state: widget.order['order_state'] == 2 ? StepState.complete: StepState.indexed,
                    ),
                    Step(
                      title: Text('Deliverez'),
                      content: Text('Livraison Effectues.'),
                     isActive: widget.order['order_state'] >2? true: false,
                      state: widget.order['order_state'] == 3 ? StepState.complete: StepState.indexed,
                    ),
                    Step(
                      title: Text('Annuler'),
                      content: Text('Livraison Annulee.'),
                     isActive: widget.order['order_state'] >3? true: false,
                      state: widget.order['order_state'] == 3 ? StepState.complete: StepState.indexed,
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
      );
   
}
}


class MealDetailPage extends StatefulWidget {
  final Map<String, dynamic> meal;

  const MealDetailPage({Key? key, required this.meal}) : super(key: key);

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  late Map<String, dynamic> meal;
   final supabaseClient = Supabase.instance.client; 
  List<Map<String, dynamic>> sideDishes = [];


  double calculateTotalPrice(Map<String, dynamic> meal, List<Map<String, dynamic>> sideDishes) {
    double totalPrice = meal['Price'] * (meal['quantity'] ?? 1);
    for (var sideDish in sideDishes) {
      totalPrice += sideDish['Price'] * (sideDish['quantity'] ?? 0);
    }
    return totalPrice;
  }

  @override
  void initState() {
    super.initState();
    meal = widget.meal;
    getSideDishes();
  }

    Future<void> getSideDishes() async {
    final response = await supabaseClient.from('side_dish').select();
    setState(() {
      sideDishes = List<Map<String, dynamic>>.from(response);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(meal['Name']),
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            child: Hero(
              tag: 'meal-${meal['ID']}',
              child: Image.network(meal['Image']),
              
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal['Description']),
                const SizedBox(height: 8),
                Text('Prix: \$${meal['Price']} USD' , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Text('Availability: ${meal['availability']}'),
                TextField(
                  decoration: InputDecoration(
                  labelText: 'Qte',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                  setState(() {
                    meal['quantity'] = int.tryParse(value) ?? 1;
                  });
                  },
                ),
                
              ],
            ),
          ),
          const SizedBox(height: 16),
                
           Expanded(
                      child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Text('Selectionnez Un Accompagnement:'),
                        const SizedBox(height: 8),
                        ...sideDishes.map((sideDish) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                          children: [
                            Image.network(
                            sideDish['Image'],
                            width: 50,
                            height: 50,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                            child: Text(sideDish['Name']),
                            ),
                            const SizedBox(width: 8),
                            Checkbox(
                            value: sideDish['selected'] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                              sideDish['selected'] = value ?? false;
                              if (!sideDish['selected']) {
                                sideDish['quantity'] = 0;
                              }
                              });
                            },
                            ),
                            if (sideDish['selected'] ?? false)
                            Expanded(
                              child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                sideDish['quantity'] = int.tryParse(value) ?? 0;
                                });
                              },
                              ),
                            ),
                          ],
                          ),
                        );
                        }).toList(),
                      ],
                      ),
                    ),
                  
                  
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(41, 91, 68,1),
                  ),
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => CheckoutPage(
                  meals: [meal],
                  sideDishes: sideDishes.where((sideDish) => sideDish['selected'] ?? false).toList(),
                ),
                ),
              );
              },
              child: Text('Payer \$${calculateTotalPrice(meal, sideDishes)} USD', style: const TextStyle(color: Colors.white),),
            ),
        ],
      ),
    );
  }
}
