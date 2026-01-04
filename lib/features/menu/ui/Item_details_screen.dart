import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wassena/features/cart/controller/cart_controller.dart';
import 'package:wassena/features/cart/model/item_cart.dart';
import 'package:wassena/features/menu/data/model/restaurants_menu.dart';
import 'package:wassena/features/menu/ui/item_card_screen.dart';
import 'package:wassena/utils/custom_widget/custom_detail_card.dart';
import 'package:wassena/utils/my_colors.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String restaurantId;
  final Meal meal;
  const ItemDetailsScreen({
    super.key,
    required this.meal,
    required this.restaurantId,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: MyColors.kMainColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(widget.meal.imageUrl),
          CustomDetailCard(
            title: 'اسم الوجبة',
            description: widget.meal.itemName,
          ),
          CustomDetailCard(
            title: 'الوصف',
            description: widget.meal.description,
          ),
          CustomDetailCard(
            title: 'السعر',
            description: widget.meal.price.toString(),
          ),
          Container(
            margin: EdgeInsets.all(5),
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                // Add to cart functionality
              },
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (index < 20) {
                        setState(() {
                          index++;
                        });
                      }
                    },
                    icon: Icon(Icons.add, color: Colors.green, size: 25),
                  ),
                  SizedBox(
                    width: 25.w,
                    child: Text(
                      index.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (index < 0) {
                        setState(() {
                          index = 0;
                        });
                      } else if (index > 0) {
                        setState(() {
                          index--;
                        });
                      }
                    },
                    icon: Icon(Icons.remove, color: Colors.red, size: 25),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      final ItemCart itemCart = ItemCart(
                        restaurantId: widget.restaurantId,
                        itemName: widget.meal.itemName,
                        price: widget.meal.price,
                        imageUrl: widget.meal.imageUrl,
                        qty: index,
                      );

                      context.read<CartController>().addToCart(itemCart);
                    },
                    child: Text(
                      'إضاقة للسلة',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
