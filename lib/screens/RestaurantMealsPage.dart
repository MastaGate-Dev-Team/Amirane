import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homepage.dart'; // Assuming MealDetailPage is in homepage.dart
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

class RestaurantMealsPage extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantMealsPage({Key? key, required this.restaurant}) : super(key: key);

  @override
  _RestaurantMealsPageState createState() => _RestaurantMealsPageState();
}

class _RestaurantMealsPageState extends State<RestaurantMealsPage> {
  final supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> meals = [];

  @override
  void initState() {
    super.initState();
    // fetchMeals();
  }

  // Future<void> fetchMeals() async {
  //   return  
  //   setState(() {
  //     meals = List<Map<String, dynamic>>.from(response);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant['name']),
      ),
      body: FutureBuilder(
        future:  supabaseClient.from('repas').select().eq('restaurant_id', widget.restaurant['ID']),
        builder: (context, snapshot) {
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
                    control: const SwiperControl(),
                    viewportFraction: 0.8,
                    scale: 0.9,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}