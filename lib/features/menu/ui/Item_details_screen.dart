import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wassena/features/cart/controller/cart_controller.dart';
import 'package:wassena/features/cart/model/item_cart.dart';
import 'package:wassena/features/menu/data/model/restaurants_menu.dart';
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
  int qty = 0;

  void showToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 50.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: MyColors.kMainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'تفاصيل الوجبة',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.meal.imageUrl,
              width: double.infinity,
              height: 220.h,
              fit: BoxFit.cover,
            ),
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
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 55.h),
                ),
                onPressed: () {
                  if (qty == 0) {
                    showToast('الرجاء اختيار الكمية');
                    return;
                  }

                  if (widget.meal.availabilityStatus != true) {
                    showToast('الوجبة غير متوفرة');
                    return;
                  }

                  final itemCart = ItemCart(
                    restaurantId: widget.restaurantId,
                    itemName: widget.meal.itemName,
                    price: widget.meal.price,
                    imageUrl: widget.meal.imageUrl,
                    qty: qty,
                  );

                  context.read<CartController>().addToCart(itemCart);

                  showToast('تمت إضافة الوجبة إلى السلة');
                },
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (qty < 20) setState(() => qty++);
                      },
                      icon: const Icon(Icons.add, color: Colors.green),
                    ),
                    SizedBox(
                      width: 35.w,
                      child: Text(
                        qty.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (qty > 0) setState(() => qty--);
                      },
                      icon: const Icon(Icons.remove, color: Colors.red),
                    ),
                    const Spacer(),
                    const Text(
                      'إضافة للسلة',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
