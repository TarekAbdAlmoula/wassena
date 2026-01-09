import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wassena/features/delivery/data/controller/delivery_controller.dart';
import 'package:wassena/features/delivery/data/model/driver.dart';
import 'package:wassena/utils/my_colors.dart';

class DeliveryScreen extends StatefulWidget {
  final String orderId;
  const DeliveryScreen({super.key, required this.orderId});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  Driver? _driver;
  String deliveryId = '';
  Timer? _timer;
  int remainingTime = 0;

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
        });

    setState(() {
      _driver = driver;
      deliveryId = docRef.id;
      remainingTime = 12;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        _timer?.cancel();
        // _updateDeliveryStatus(2); // 2 = delivered
      }
    });
  }

  // void _updateDeliveryStatus(int status) {
  //   if (deliveryId.isNotEmpty) {
  //     FirebaseFirestore.instance
  //         .collection('deliveries')
  //         .doc(deliveryId)
  //         .update({'delivery_status': status});
  //   }
  // }

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_driver == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: MyColors.kMainColor),
        body: Center(child: Text('جاري البحث عن سائق...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.kMainColor,
        title: Text('توصيل الطلب'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('بيانات السائق', style: TextStyle(fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text(_driver!.driverName), Text(': الاسم ')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text(_driver!.phoneNumber), Text(': الهاتف ')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_driver!.vehicleType),
                    Text(': نوع السيارة '),
                  ],
                ),
              ],
            ),
          ),

          // StreamBuilder لمتابعة حالة التوصيل
          if (deliveryId.isNotEmpty)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('deliveries')
                  .doc(deliveryId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final status = data['delivery_status'] as int;

                return Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'حالة التوصيل: ${_statusText(status)}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'الوقت المتبقي: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 16),
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
