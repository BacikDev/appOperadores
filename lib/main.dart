import 'package:app_cabecera/custom/configurations.dart';
import 'package:app_cabecera/pages/bottom_navigattion_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async{
  await Supabase.initialize(
  url:Configurations.mSupabaseUrl,
  anonKey:Configurations.mSupabaseKey,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);

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
      home: const MainNavigationScreen(),
    );
  }
}