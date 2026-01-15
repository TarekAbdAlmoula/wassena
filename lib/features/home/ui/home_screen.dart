import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wassena/features/cart/ui/cart_screen.dart';
import 'package:wassena/features/home/data/datasource/restaurant_controller.dart';
import 'package:wassena/features/home/ui/restaurant_details.dart';
import 'package:wassena/utils/my_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> addsImages = [
    'assets/images/ad1.png',
    'assets/images/ad2.png',
    'assets/images/ad3.jpg',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CartScreen();
                    },
                  ),
                );
              },
              icon: Icon(Icons.shopping_cart, color: Colors.white),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        toolbarHeight: 50.h,
        backgroundColor: MyColors.kMainColor,
        title: Text(
          'الرئيسية',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: RestaurantController.getRestaurants(),

        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: MyColors.kMainColor),
            );
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('حدث خطأ ما'));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        // height: 200,
                        autoPlay: true,
                        viewportFraction: 1.0,
                      ),

                      items: [
                        for (var addImage in addsImages)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage(addImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            textAlign: TextAlign.right,
                            'المطاعم',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GridView.builder(
                      itemCount: asyncSnapshot.data!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return RestaurantDetailsScreen(
                                    restaurant: asyncSnapshot.data![index],
                                  );
                                },
                              ),
                            );
                          },
                          child: Hero(
                            tag: asyncSnapshot.data![index].id,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                        asyncSnapshot.data![index].imageUrl,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      asyncSnapshot.data![index].name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
