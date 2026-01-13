import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wassena/features/delivery/data/controller/delivery_controller.dart';
import 'package:wassena/features/delivery/data/model/driver.dart';
import 'package:wassena/features/home/ui/home_screen.dart';
import 'package:wassena/utils/my_colors.dart';

class DeliveryScreen extends StatefulWidget {
  final String orderId;
  final String restaurantId;

  const DeliveryScreen({
    super.key,
    required this.orderId,
    required this.restaurantId,
  });

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  Driver? _driver;

  String deliveryId = '';
  int remainingTime = 0;
  bool _ratingShown = false;

  Timer? _timer;
  Timer? _driverMoveTimer;

  List<double> userLocation = [];

  final TextEditingController controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initDelivery();
    _loadUserLocation();
  }

  Future<void> _initDelivery() async {
    final driver = await DeliveryController.getDrivers();

    final docRef = await FirebaseFirestore.instance
        .collection('deliveries')
        .add({
          'driver_id': driver.diverId,
          'order_id': widget.orderId,
          'delivery_status': 0,
          'estimated_time': 10,
          'actual_time': 12,
          'created_at': Timestamp.now(),
        });

    final restaurantLocation = await DeliveryController.getRestaurantLocation(
      widget.restaurantId,
    );

    driver.latitude = restaurantLocation.latitude;
    driver.longitude = restaurantLocation.longitude;

    setState(() {
      _driver = driver;
      deliveryId = docRef.id;
      remainingTime = 12;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _loadUserLocation() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      userLocation = [
        (snapshot.get('latitude') as num).toDouble(),
        (snapshot.get('longitude') as num).toDouble(),
      ];
    });

    _startDriverMovement();
  }

  void _startDriverMovement() {
    _driverMoveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_driver == null || userLocation.isEmpty) return;

      if (_hasDriverArrived()) {
        _driverMoveTimer?.cancel();
        return;
      }

      _moveDriverTowardUser();
    });
  }

  void _moveDriverTowardUser() {
    const double speed = 0.3;

    setState(() {
      _driver!.latitude =
          _driver!.latitude! + (userLocation[0] - _driver!.latitude!) * speed;

      _driver!.longitude =
          _driver!.longitude! + (userLocation[1] - _driver!.longitude!) * speed;
    });
  }

  bool _hasDriverArrived() {
    const Distance distance = Distance();

    return distance(
          LatLng(_driver!.latitude!, _driver!.longitude!),
          LatLng(userLocation[0], userLocation[1]),
        ) <
        15; // متر
  }

  String _statusText(int status) {
    switch (status) {
      case 0:
        return 'تم تعيين السائق';
      case 1:
        return 'في الطريق';
      case 2:
        return 'تم التوصيل';
      default:
        return 'غير معروف';
    }
  }

  void _showRatingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) {
        double rating = 3;
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('قيّم تجربة التوصيل', style: TextStyle(fontSize: 20)),
              Slider(
                value: rating,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => setState(() => rating = v),
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'اكتب تعليقك'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('reviews').add({
                    'rating': rating,
                    'comment': controller.text,
                    'order_id': widget.orderId,
                    'restaurantId': widget.restaurantId,
                    'userId': user!.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text('إرسال'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _driverMoveTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_driver == null) {
      return const Scaffold(body: Center(child: Text('جاري البحث عن سائق...')));
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: MyColors.kMainColor,
        title: const Text('توصيل الطلب', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(228, 227, 227, 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'بيانات السائق',
                  style: TextStyle(fontSize: 20, color: Color(0xff094067)),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text(_driver!.driverName), const Text(' : الاسم')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_driver!.phoneNumber),
                    const Text(' : الهاتف'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_driver!.vehicleType),
                    const Text(' : نوع المركبة'),
                  ],
                ),
              ],
            ),
          ),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('deliveries')
                .doc(deliveryId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final status = data['delivery_status'] as int;

              if (status == 2 && !_ratingShown) {
                _ratingShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showRatingBottomSheet();
                });
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'حالة التوصيل: ${_statusText(status)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'الوقت المتبقي: $remainingTime ثانية',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_driver!.latitude!, _driver!.longitude!),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.wassena',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_driver!.latitude!, _driver!.longitude!),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                    if (userLocation.isNotEmpty)
                      Marker(
                        point: LatLng(userLocation[0], userLocation[1]),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                  ],
                ),

                if (userLocation.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          LatLng(_driver!.latitude!, _driver!.longitude!),
                          LatLng(userLocation[0], userLocation[1]),
                        ],
                        strokeWidth: 4,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
