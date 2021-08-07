import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase/supabase.dart';

import 'Screens/Auth/loginPage.dart';
import 'Screens/Home/home.dart';
import 'Services/AuthService/authService.dart';

final String _supaBaseUrl = 'https://dyynctzvbomcqosodtzu.supabase.co';
final String _supaBaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyODI2MzcyNSwiZXhwIjoxOTQzODM5NzI1fQ.NlCDrAAS6QeXnSCCVk9DJzLY-MryXifOKxwSX0aLAI4';

void main() {
  Get.put<SupabaseClient>(SupabaseClient(_supaBaseUrl, _supaBaseKey));
  Get.put<GetStorage>(GetStorage());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Wrapper(),
    );
  }
}

class Wrapper extends StatefulWidget {
  @override
  WrapperState createState() => WrapperState();
}

class WrapperState extends State<Wrapper> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sessionCheck();
  }

  void sessionCheck() async {
    await GetStorage.init();
    final box = Get.find<GetStorage>();
    AuthService _authService = AuthService();
    final session = box.read('user');
    if (session == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {
      final response = await _authService.recoverSession(session);
      await box.write('user', response.data.persistSessionString);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.green),
        ),
      ),
    );
  }
}
