import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wassena/features/auth/ui/components/cutsom_textfield.dart';
import 'package:wassena/features/home/ui/home_screen.dart';
import 'package:wassena/utils/my_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Builds a [Scaffold] widget with a [RegisterScreeBody] as its body
  /// and centers it in the given [BuildContext].
  /*******  63ae34f1-1e60-4a50-886b-483e0ee81a2c  *******/
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: RegisterScreeBody()));
  }
}

// ignore: must_be_immutable
class RegisterScreeBody extends StatefulWidget {
  const RegisterScreeBody({super.key});

  @override
  State<RegisterScreeBody> createState() => _RegisterScreeBodyState();
}

class _RegisterScreeBodyState extends State<RegisterScreeBody> {
  TextEditingController nameController = .new();
  TextEditingController phoneController = .new();
  TextEditingController emailController = .new();
  TextEditingController passwordController = .new();
  TextEditingController addressController = .new();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  User? _user;
  Position? position;
  // this function to get user location {eng.Abdullah}
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء تفعيل خدمة الموقع')));
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      addressController.text = position.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/images/wassena logo.png',
                height: 200.h,
                width: 200.w,
              ),
              CutsomTextField(
                hintText: ' الاسم',
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الاسم مطلوب';
                  }
                  return null;
                },
              ),
              CutsomTextField(
                hintText: 'رقم الهاتف',
                controller: phoneController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم الهاتف مطلوب';
                  }
                  return null;
                },
              ),

              CutsomTextField(
                hintText: ' الايميل',
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الرجاء إدخال البريد الإلكتروني";
                  }

                  // تحقق بسيط باستخدام regex
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return "الرجاء إدخال بريد إلكتروني صالح";
                  }

                  return null;
                },
              ),
              CutsomTextField(
                hintText: ' كلمة السر',
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'كلمة السر مطلوبة';
                  }
                  return null;
                },
              ),
              CutsomTextField(
                hintText: 'العنوان',
                controller: addressController,
                readOnly: true,
                suffixIcon: Icons.location_on,
                onTap: () {
                  getCurrentLocation();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'العنوان مطلوب';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10.h),
              CustomButton(
                text: 'تسجيل',
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: MyColors.kMainColor,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'يرجى الانتظار',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    await _auth.createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );

                    await _firebaseFirestore
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
                        .set({
                          'name': nameController.text,
                          'phone': phoneController.text,
                          'email': emailController.text,
                          'address': addressController.text,
                          'password': passwordController.text,
                          'createdAt': FieldValue.serverTimestamp(),
                          'latitude': position!.latitude,
                          'longitude': position!.longitude,
                        });
                    Navigator.of(context, rootNavigator: true).pop();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } catch (e) {
                    print('Failed to create a new user%:$e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.h),
        height: 45.h,
        // width: 130.w,
        decoration: BoxDecoration(
          color: Color(0xffDC5C35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18.sp),
          ),
        ),
      ),
    );
  }
}
