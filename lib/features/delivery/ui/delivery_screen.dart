import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wassena/features/delivery/data/controller/delivery_controller.dart';
import 'package:wassena/features/delivery/data/model/driver.dart';
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
  Timer? _timer;
  int remainingTime = 0;
  bool _ratingShown = false;
  final TextEditingController controller = .new();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initDelivery();
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

    setState(() {
      _driver = driver;
      deliveryId = docRef.id;
      remainingTime = 12;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        _timer?.cancel();
      }
    });
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
      isScrollControlled: true,
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double rating = 3;

        return Padding(
          padding: EdgeInsets.only(
            top: 10,
            right: 10,
            left: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'قيّم تجربة التوصيل',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                StatefulBuilder(
                  builder: (context, setState) {
                    return Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toString(),
                      onChanged: (value) {
                        setState(() => rating = value);
                      },
                    );
                  },
                ),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
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

                    Navigator.pop(context);
                  },
                  child: const Text('إرسال التقييم'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_driver == null) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(backgroundColor: MyColors.kMainColor),
        body: const Center(child: Text('جاري البحث عن سائق...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('بيانات السائق', style: TextStyle(fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text(_driver!.driverName), const Text(': الاسم ')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_driver!.phoneNumber),
                    const Text(': الهاتف '),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_driver!.vehicleType),
                    const Text(': نوع السيارة '),
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
                margin: const EdgeInsets.all(10),
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
                      'الوقت المتبقي: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
