import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:test1/login_widgets/login_ui.dart';
import 'firebase_options.dart';
import 'login_widgets/auth_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //db 연동
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

//Main 클래스
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태 표시줄 배경색을 투명하게 설정
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //앱 테마
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          backgroundColor: const Color.fromARGB(255, 206, 250, 226),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF232B55),
          ),
        ),
        primaryColorLight: const Color.fromARGB(255, 168, 255, 208),
        primaryColor: const Color.fromARGB(255, 75, 255, 195),
        primaryColorDark: const Color.fromARGB(124, 73, 236, 195),
        cardColor: const Color.fromARGB(255, 233, 255, 243),
      ),
      //InterFace 호출
      home: const LoginUI(),
    );
  }
}
