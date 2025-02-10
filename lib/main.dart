import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://tfdbmodprixwrkqefujf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmZGJtb2Rwcml4d3JrcWVmdWpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTQ0MjksImV4cCI6MjA1NDI5MDQyOX0.Qi_FzqKJdLzbEqiWsGweH0tcYPdrAt36tOcUqIWP8cc',
  );
  runApp(MyApp());
}
        
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}