import 'package:flutter/material.dart';
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
      appBar: AppBar(backgroundColor: MyColors.kMainColor),
      body: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 237, 201, 200),
        ),
        child: ListView.builder(
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
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          'السعر: ${cart.items[index].price}  الكمية: ${cart.items[index].qty}',
                          style: TextStyle(color: Colors.white, fontSize: 18),
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
                GestureDetector(
                  onTap: () {
                    context.read<CartController>().createOrdersTable();
                  },
                  child: Container(
                    height: 25,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: 75,
                    child: Center(child: Text('إكمال الطلب ')),
                  ),
                ),

                // Divider(color: Colors.white, height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}
