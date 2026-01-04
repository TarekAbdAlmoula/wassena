// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wassena/features/menu/data/datasource/resataurant_menu_controller.dart';
import 'package:wassena/features/menu/data/model/restaurants_menu.dart';
import 'package:wassena/features/menu/ui/Item_details_screen.dart';
import 'package:wassena/utils/my_colors.dart';

class ItemCardScreen extends StatefulWidget {
  final String restaurantId;
  const ItemCardScreen({super.key, required this.restaurantId});

  @override
  State<ItemCardScreen> createState() => _ItemCardScreenState();
}

class _ItemCardScreenState extends State<ItemCardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.kMainColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: ResataurantMenuController.getRestaurantMenu(
          widget.restaurantId,
        ),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('حدث خطأ ما'));
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                ListView.builder(
                  itemCount: asyncSnapshot.data![0].meal.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ItemCard(
                          press: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ItemDetailsScreen(
                                    restaurantId: widget.restaurantId,
                                    meal: asyncSnapshot.data![0].meal[index],
                                  );
                                },
                              ),
                            );
                          },
                          menu: asyncSnapshot.data![0].meal[index],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final GestureTapCallback? press;
  final Meal menu;
  const ItemCard({super.key, required this.press, required this.menu});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        // height: 110.h,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
        margin: EdgeInsets.symmetric(vertical: 3.h, horizontal: 1.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    SizedBox(width: 30.w),

                    SizedBox(
                      width: 150.w,
                      child: Text(
                        textAlign: TextAlign.end,
                        menu.itemName,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff094067),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 35.h,
                  width: 160.h,
                  child: Text(
                    textAlign: TextAlign.end,
                    menu.description,
                    style: TextStyle(fontSize: 12.sp),
                    maxLines: 2,
                  ),
                ),

                SizedBox(height: 5.h),
                Row(
                  children: [
                    SizedBox(
                      width: 62.w,
                      height: 18.h,
                      child: Text('${menu.price}\$'),
                    ),
                    SizedBox(width: 65.w),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.156,
                      child: Text(
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        menu.availabilityStatus ? 'متوفر' : 'غير متوفر',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: menu.availabilityStatus
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(left: 5.w),
              child: Container(
                width: 110.w,
                height: 110.h,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffA3A3A3)),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(menu.imageUrl),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
