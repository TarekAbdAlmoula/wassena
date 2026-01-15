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

  Timer? _driverMoveTimer;
  List<double> userLocation = [];

  final Distance _distance = const Distance();
  final double driverSpeed = 5;

  final TextEditingController controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  bool _ratingShown = false;

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
    });
  }

  Future<void> _loadUserLocation() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    userLocation = [
      (snapshot.get('latitude') as num).toDouble(),
      (snapshot.get('longitude') as num).toDouble(),
    ];

    _updateRemainingTime();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _startDriverMovement();
    });
  }

  void _updateRemainingTime() {
    if (_driver == null || userLocation.isEmpty) return;

    final remainingDistance = _distance(
      LatLng(_driver!.latitude!, _driver!.longitude!),
      LatLng(userLocation[0], userLocation[1]),
    );

    setState(() {
      remainingTime = (remainingDistance / driverSpeed).ceil();
      if (remainingTime < 0) remainingTime = 0;
    });
  }

  void _startDriverMovement() {
    FirebaseFirestore.instance.collection('deliveries').doc(deliveryId).update({
      'delivery_status': 1,
    });

    _driverMoveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_driver == null || userLocation.isEmpty) return;

      if (_hasDriverArrived()) {
        _driverMoveTimer?.cancel();
        setState(() => remainingTime = 0);

        FirebaseFirestore.instance
            .collection('deliveries')
            .doc(deliveryId)
            .update({'delivery_status': 2});

        return;
      }

      _moveDriverTowardUser();
    });
  }

  void _moveDriverTowardUser() {
    const double step = 0.3;

    setState(() {
      _driver!.latitude =
          _driver!.latitude! + (userLocation[0] - _driver!.latitude!) * step;

      _driver!.longitude =
          _driver!.longitude! + (userLocation[1] - _driver!.longitude!) * step;
    });

    _updateRemainingTime();
  }

  bool _hasDriverArrived() {
    return _distance(
          LatLng(_driver!.latitude!, _driver!.longitude!),
          LatLng(userLocation[0], userLocation[1]),
        ) <
        15;
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
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'اكتب تعليقك'),
                ),
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

  String formatRemainingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes دقيقة و $remainingSeconds ثانية';
  }

  @override
  void dispose() {
    _driverMoveTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_driver == null || userLocation.isEmpty) {
      return const Scaffold(body: Center(child: Text('...جاري البحث عن سائق')));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: MyColors.kMainColor,
        title: const Text('توصيل الطلب', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                const Text('بيانات السائق', style: TextStyle(fontSize: 20)),
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

          Padding(
            padding: const EdgeInsets.all(10),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('deliveries')
                  .doc(deliveryId)
                  .snapshots(),
              builder: (context, snapshot) {
                int status = 0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  status = snapshot.data!['delivery_status'] ?? 0;

                  if (status == 2 && !_ratingShown) {
                    _ratingShown = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _showRatingBottomSheet();
                    });
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('حالة التوصيل', style: TextStyle(fontSize: 18)),
                    Text(
                      _statusText(status),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'الوقت المتبقي: ${formatRemainingTime(remainingTime)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
