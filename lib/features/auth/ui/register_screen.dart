import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wassena/features/auth/ui/components/cutsom_textfield.dart';
import 'package:wassena/features/home/ui/home_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
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
                    return 'الايميل مطلوب';
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
                hintText: ' العنوان',
                controller: addressController,
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
                        });
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
        height: 35.h,
        width: 130.w,
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
