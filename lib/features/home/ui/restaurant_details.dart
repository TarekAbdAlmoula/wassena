import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wassena/features/home/data/model/restaurant.dart';
import 'package:wassena/features/menu/ui/Item_details_screen.dart';
import 'package:wassena/features/menu/ui/item_card_screen.dart';
import 'package:wassena/utils/custom_widget/custom_detail_card.dart';
import 'package:wassena/utils/my_colors.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key, required this.restaurant});
  final Restaurant restaurant;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: restaurant.id,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ItemCardScreen(restaurantId: restaurant.id);
                    },
                  ),
                );
                // MenuScreen(restaurantId: restaurant.id);
              },
              child: Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: Icon(Icons.restaurant_menu),
              ),
            ),
          ],
          centerTitle: true,
          title: Text(restaurant.name, style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: MyColors.kMainColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300.h,
                width: double.infinity,
                child: Image.network(restaurant.imageUrl),
              ),
              CustomDetailCard(
                title: ' : اسم المطعم',
                description: restaurant.name,
              ),
              CustomDetailCard(
                title: ': رقم الهاتف ',
                description: restaurant.phoneNumber.toString(),
              ),
              CustomDetailCard(
                title: ': نوع المطبخ',
                description: restaurant.cuisineType,
              ),
              CustomDetailCard(
                title: ': العنوان',
                description: restaurant.location,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
