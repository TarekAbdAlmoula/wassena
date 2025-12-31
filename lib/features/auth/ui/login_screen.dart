import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wassena/features/auth/ui/components/cutsom_textfield.dart';
import 'package:wassena/features/auth/ui/register_screen.dart';
import 'package:wassena/features/home/ui/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: LoginScreenBody()));
  }
}

// ignore: must_be_immutable
class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  TextEditingController emailController = .new();
  TextEditingController passwordController = .new();
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

              SizedBox(height: 10.h),
              CustomButton(
                text: 'تسجيل',
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  try {
                    await _auth.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );

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
