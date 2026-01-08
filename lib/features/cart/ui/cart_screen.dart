import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wassena/features/cart/controller/cart_controller.dart';
import 'package:wassena/utils/my_colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(backgroundColor: MyColors.kMainColor),
        body: Center(child: Text('السلة فارغة')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.kMainColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 237, 201, 200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              cart.items[index].itemName,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'السعر: ${cart.items[index].price}  الكمية: ${cart.items[index].qty}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text('المطعم'),
                          ],
                        ),
                        SizedBox(width: 5),
                        Container(
                          padding: EdgeInsets.all(10),
                          height: 75,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(cart.items[index].imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),

                          // margin: EdgeInsets.all(8),
                        ),
                      ],
                    ),

                    Divider(color: Colors.white, height: 10),
                  ],
                );
              },
            ),
            GestureDetector(
              onTap: () {
                try {
                  context.read<CartController>().createOrdersTable();
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),
                              Text('اختر طريقة الدفع'),
                              SizedBox(height: 10),
                              PaymentCard(
                                paymentMethod: 'الدفع كاش',
                                onTap: () {
                                  context.read<CartController>().makePayment(
                                    paymentMethod: 'الدفع كاش',
                                  );
                                },
                              ),
                              PaymentCard(
                                onTap: () {
                                  context.read<CartController>().makePayment(
                                    paymentMethod: 'الدفع عن طريق البطاقة',
                                  );
                                },
                                paymentMethod: 'الدفع عن طريق البطاقة',
                              ),
                              PaymentCard(
                                onTap: () {
                                  context.read<CartController>().makePayment(
                                    paymentMethod: 'الدفع عن طريق paypal',
                                  );
                                },
                                paymentMethod: 'الدفع عن طريق paypal',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } on Exception catch (e) {
                  // TODO
                }
              },
              child: Container(
                height: 25,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: EdgeInsets.symmetric(vertical: 10),
                width: 90.w,
                child: Center(child: Text('إكمال الطلب ')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final String paymentMethod;
  final void Function()? onTap;
  const PaymentCard({
    super.key,
    required this.paymentMethod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50.h,
          width: double.infinity,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(paymentMethod),
        ),
      ),
    );
  }
}
