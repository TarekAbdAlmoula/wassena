import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wassena/features/home/ui/home_screen.dart';
import 'package:wassena/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          ),
          home: child,
        );
      },
      child: HomeScreen(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  Future<void> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      setState(() {
        _user = userCredential.user;
      });
      print('Signed in anonymously as: ${_user!.uid}');
    } catch (e) {
      print('Failed to sign in anonymously: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue),
      body: Center(
        child: IconButton(
          onPressed: () async {
            await _auth.createUserWithEmailAndPassword(
              email: 'abdalmooulatare@gmail.com',
              password: '123456',
            );
          },
          icon: Icon(Icons.add_ic_call),
        ),
      ),
    );
  }
}
