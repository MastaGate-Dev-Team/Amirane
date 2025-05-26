import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryInquiryPage extends StatefulWidget {
  const DeliveryInquiryPage({Key? key}) : super(key: key);

  @override
  _DeliveryInquiryPageState createState() => _DeliveryInquiryPageState();
}

class _DeliveryInquiryPageState extends State<DeliveryInquiryPage> {
  final supabaseClient = Supabase.instance.client;
  final packageDescriptionController = TextEditingController();
  final packageWeightController = TextEditingController();
  final pickupLocationController = TextEditingController();
  final destinationController = TextEditingController();
  final priceController = TextEditingController();

  late GoogleMapController mapController;
  final Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _loadDeliverers();
  }

  Future<void> _loadDeliverers() async {
    // Fetch deliverers' locations and vehicle types from Supabase
    final response = await supabaseClient.from('deliverers').select().eq('status', 'online');
    if (response != null) {
      setState(() {
        for (var deliverer in response) {

          markers.add(
            Marker(
              markerId: MarkerId(deliverer['id'].toString()),
              position: LatLng(deliverer['latitude'], deliverer['longitude']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                deliverer['vehicle_type'] == 'bike' ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(title: deliverer['name']),
            ),
          );
        }
      });
    }
  }

  Future<void> _submitInquiry() async {
    final inquiry = {
      'package_description': packageDescriptionController.text,
      'package_weight': packageWeightController.text,
      'pickup_location': pickupLocationController.text,
      'destination': destinationController.text,
      'price': priceController.text,
    };

    // Save inquiry to Supabase
    await supabaseClient.from('inquiries').insert(inquiry);

    // Send push notification to deliverers
    await supabaseClient.rpc('send_push_notification', params: {'message': 'New delivery inquiry available!'});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inquiry submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Delivery Inquiry'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default location
                zoom: 12,
              ),
              markers: markers,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: packageDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Package Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: packageWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Package Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pickupLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Pickup Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price Estimate (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitInquiry,
                  child: const Text('Submit Inquiry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}