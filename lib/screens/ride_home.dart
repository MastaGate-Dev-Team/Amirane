import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride App'),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Book Ride'),
            Tab(text: 'Previous Rides'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Book Ride Tab
          Stack(
            children: [
              // Map Placeholder
                Container(
                color: Colors.grey[300],
                child: Stack(
                  children: [
                  // Map Placeholder
                    GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(37.7749, -122.4194), // Example coordinates (San Francisco)
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                      markerId: MarkerId('car1'),
                      position: LatLng(37.7749, -122.4194),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                      infoWindow: InfoWindow(title: 'Sedan'),
                      ),
                      Marker(
                      markerId: MarkerId('car2'),
                      position: LatLng(37.7849, -122.4094),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                      infoWindow: InfoWindow(title: 'SUV'),
                      ),
                      Marker(
                      markerId: MarkerId('car3'),
                      position: LatLng(37.7649, -122.4294),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      infoWindow: InfoWindow(title: 'Luxury'),
                      ),
                    },
                    ),
                  // Example of drivers and car types
                  Positioned(
                    top: 100,
                    left: 50,
                    child: Column(
                    children: [
                      Icon(Icons.directions_car, color: Colors.blue, size: 30),
                      Text('Sedan', style: TextStyle(fontSize: 12)),
                    ],
                    ),
                  ),
                  
                  
                  ],
                ),
                ),
              // Booking Form
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Pickup Location',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Destination',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Car Type',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Sedan', 'SUV', 'Luxury']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {},
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('Send Inquiry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Previous Rides Tab
          ListView.builder(
            itemCount: 5, // Example data
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.history),
                title: Text('Ride #$index'),
                subtitle: Text('Pickup: Location A, Destination: Location B'),
                trailing: Text('\$20'),
              );
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserHomeScreen(),
  ));
}