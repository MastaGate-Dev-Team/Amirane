import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class DashboardPage extends StatefulWidget {


  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}



class _DashboardPageState extends State<DashboardPage> {
  final supabaseClient = Supabase.instance.client;
  bool isValidated = false;
  String userId = '';
  Map<String, dynamic> restaurantProfile = {};
  List<Map<String, dynamic>> orders = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final ingredientsController = TextEditingController();
  late PlatformFile file;


  @override
  void initState() {
    super.initState();
  getCurrentSessionAndRestaurantDetails();
  }

void refreshAllPages() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => DashboardPage()),
  );
}


  Future<void> getCurrentSessionAndRestaurantDetails() async {
    final session = supabaseClient.auth.currentSession;
    if (session != null) {
      userId = session.user.id;
      print( session.user);
      if (userId != null) {

        final response = await supabaseClient
            .from('restaurants')
            .select()
            .eq('user_id', userId)
            .single();
        setState(() {
          restaurantProfile = response;
        });

    checkValidation();
    fetchOrders();
    fetchProfile();
      }
    }
  }

  Future<void> checkValidation() async {
    final response = await supabaseClient
        .from('restaurants')
        .select('is_validated')
        .eq('user_id', userId)
        .single();
    setState(() {
      isValidated = response['is_validated'];
    });
  }

  Future<void> fetchOrders() async {
    final response = await supabaseClient
        .from('orders')
        .select()
        .eq('restaurant_id', restaurantProfile['ID']);
    setState(() {
      orders = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fetchProfile() async {
    final response = await supabaseClient
        .from('restaurants')
        .select()
        .eq('user_id', userId)
        .single();
    setState(() {
      restaurantProfile = response;
    });
  }
      void pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = result.files.first;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${file.name}');
      await tempFile.writeAsBytes(file.bytes!);
      final response = await supabaseClient.storage.from('logos').upload(file.name, tempFile);

    }
  }

  @override
  Widget build(BuildContext context) {
    print(restaurantProfile);

    if (!isValidated) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
        ),
        body: Center(
          child: Padding(
            padding:  const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
              'Your restaurant profile is not validated yet. Confirm your email address and wait for the admin to validate your account.',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
             ElevatedButton(
                onPressed: refreshAllPages,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('Recharge la page', style: TextStyle(color: Colors.white)),
              ),
              ],
            ) 
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Resumer'),
              Tab(icon: Icon(Icons.list), text: 'Commandes'),
              Tab(icon: Icon(Icons.person), text: 'Profil'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildOverviewTab(),
            buildOrdersTab(),
            buildProfileTab(),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextField(
                            decoration: InputDecoration(labelText: 'Meal Name'),
                            controller: nameController,
                            ),
                            TextField(
                            decoration: InputDecoration(labelText: 'Price'),
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            ),
                            TextField(
                            decoration: InputDecoration(labelText: 'Description'),
                            controller:descriptionController,
                            ),
                            TextField(
                            decoration: InputDecoration(labelText: 'Category'),
                            controller: categoryController,
                            ),
                            TextField(
                            decoration: InputDecoration(labelText: 'Ingredients'),
                            controller: ingredientsController,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                            onPressed: () async {
                              // add logic to select image
                                final result = await FilePicker.platform.pickFiles(type: FileType.image);
                                if (result != null) {
                                  file = result.files.first;
                                  
                                  
                                }
                            
                            },
                            child: Text('Select Image'),
                            ),
                            SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              // Implement the logic to add a new meal to the database
                              final tempDir = await getTemporaryDirectory();
                                  final tempFile = File('${tempDir.path}/${file.name}');
                              await tempFile.writeAsBytes(file.bytes!);
                                  final response = await supabaseClient.storage.from('meal_images').upload(file.name, tempFile);
                                  if (response == null) {
                                    final imageUrl = supabaseClient.storage.from('meal_images').getPublicUrl(file.name);
                                    // Use the imageUrl to save the image URL to the database
                                    final response = await supabaseClient.from('repas').insert([
                                      {
                                        'name': nameController.text,
                                        'price': priceController.text,
                                        'description': descriptionController.text,
                                        'category': categoryController.text,
                                        'ingredients': ingredientsController.text,
                                        'restaurant_id': userId,
                                        'is_visible': true,
                                        'image_url': imageUrl,
                                      }
                                    ]);
                                    print(response); 
                                    Navigator.pop(context);
                                  }
                              // final response = await supabaseClient.from('repas').insert([
                              //   {
                              //     'name': nameController.text,
                              //     'price': priceController.text,
                              //     'description': descriptionController.text,
                              //     'category': categoryController.text,
                              //     'ingredients': ingredientsController.text,
                              //     'restaurant_id': userId,
                              //     'is_visible': true,
                              //   }
                              // ]);

                              
                            },
                            child: Text('Add Meal'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Icon(Icons.add),
              tooltip: 'Add Meal',
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return FutureBuilder(
                        future: supabaseClient.from('repas').select().eq('restaurant_id', restaurantProfile['ID']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final meals = snapshot.data as List<Map<String, dynamic>>;
                        if (meals.isEmpty) {
                          return Center(child: Text('Pas de Repas! Creez un repas pour acceder a la liste.'));
                        }
                        return ListView.builder(
                          itemCount: meals.length,
                          itemBuilder: (context, index) {
                            final meal = meals[index];
                            return ListTile(
                              title: Text(meal['name']),
                              subtitle: Text('\$${meal['price']}'),
                              trailing: IconButton(
                              icon: Icon(
                                meal['is_visible'] ? Icons.visibility : Icons.visibility_off,
                                color: meal['is_visible'] ? Colors.green : Colors.red,
                              ),
                              onPressed: () async {
                                final newVisibility = !meal['is_visible'];
                                final response = await supabaseClient
                                  .from('repas')
                                  .update({'is_visible': newVisibility})
                                  .eq('ID', meal['ID']);
                                if (response != null) {
                                setState(() {
                                  meal['is_visible'] = newVisibility;
                                });
                                }
                              },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
              child: Icon(Icons.list),
              tooltip: 'View Meals',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOverviewTab() {
    int currentOrders = orders.where((order) => order['order_state'] == 0).length;
    int deliveredOrders = orders.where((order) => order['order_state'] == 3).length;
    int canceledOrders = orders.where((order) => order['order_state'] == 4).length;
    double totalAmount = orders.fold(0, (sum, order) => sum + order['Total_Price']);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          buildCard('Commandes', currentOrders, Icons.shopping_cart),
          buildCard('Livraisons', deliveredOrders, Icons.check_circle),
          buildCard('Solde', totalAmount, Icons.attach_money),
          buildCard('Annulations', canceledOrders, Icons.cancel),
        ],
      ),
    );
  }

  Widget buildCard(String title, dynamic value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrdersTab() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text('Order Date: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(order['Date']))}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('State: ${order['order_state']}'),
              Text('Address: ${order['order_address']}'),
            ],
          ),
          trailing: order['order_state'] == 3
              ? Tag(color: Colors.green, text: 'Delivered')
              : order['order_state'] == 4
                  ? Tag(color: Colors.red, text: 'Canceled')
                  : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(order: order),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          buildProfileField('Name', restaurantProfile['name']),
          buildProfileField('Phone', restaurantProfile['phone']),
          buildProfileField('Description', restaurantProfile['description']),
          buildProfileField('Address', restaurantProfile['location']),
          Row(
            children: [
              Text('Logo:'),
              SizedBox(width: 10),
              restaurantProfile['logo'] != null
                  ? Image.network(
                      restaurantProfile['logo'],
                      width: 50,
                      height: 50,
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey,
                      child: Icon(Icons.image),
                    ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: pickLogo,
              ),
            ],
          ),
    
          ElevatedButton(
            onPressed: () {
              // Handle profile update
            },
            child: Text('Metre a jour le Profil'),
          ),
        ],
      ),
    );
  }

  Widget buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: TextEditingController(text: value),
      ),
    );
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
