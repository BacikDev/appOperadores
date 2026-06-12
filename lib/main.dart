import 'package:app_cabecera/custom/configurations.dart';
import 'package:app_cabecera/pages/home_screen.dart';
import 'package:app_cabecera/pages/sensor_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async{
  await Supabase.initialize(
  url:Configurations.mSupabaseUrl,
  anonKey:Configurations.mSupabaseKey,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState()=> _MyAppState();
}

class _MyAppState extends State<MyApp>{
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}