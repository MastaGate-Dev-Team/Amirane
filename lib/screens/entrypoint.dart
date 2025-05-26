import 'package:flutter/material.dart';

class EntrypointScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Que voulez vous faire ?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            ServiceCard(
              icon: "assets/icons/ride.png",
              text: 'Cab',
              onTap: () {
                // Handle Cab tap
              },
            ),
            ServiceCard(
              icon: "assets/icons/food_order.png",
              text: 'Restaurant',
              onTap: () {
                // Handle Restaurant tap
              },
            ),
            ServiceCard(
              icon: "assets/icons/delivery.png",
              text: 'Box Delivery',
              onTap: () {
                // Handle Box Delivery tap
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback onTap;

  const ServiceCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 100, height: 100),
            SizedBox(height: 12.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
