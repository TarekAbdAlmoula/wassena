import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  TextEditingController emailController = .new();
  TextEditingController passwordController = .new();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Image.asset(
              'assets/images/wassena logo.png',
              height: 200.h,
              width: 200.w,
            ),
            CutsomTextField(
              hintText: 'أدخل الايميل ',
              controller: emailController,
            ),
            SizedBox(height: 20.h),
            CutsomTextField(
              hintText: 'أدخل كلمة السر  ',
              controller: passwordController,
            ),
            SizedBox(height: 20.h),

            CustomButton(
              text: 'تسجيل',
              onPressed: () async {
                try {
                  await _auth.createUserWithEmailAndPassword(
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

class CutsomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  const CutsomTextField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            //change border color
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
