import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wassena/features/menu/data/datasource/menue_remote_source.dart';
import 'package:wassena/features/menu/ui/item_card.dart';
import 'package:wassena/utils/my_colors.dart';

class MenuScreen extends StatefulWidget {
  final String restaurantId;
  const MenuScreen({super.key, required this.restaurantId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
        future: MenuRemoteSource.getRestaurantMenu(widget.restaurantId),
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
                  itemCount: asyncSnapshot.data![0].menu.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ItemCard(
                          press: () {},
                          menu: asyncSnapshot.data![0].menu[index],
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
