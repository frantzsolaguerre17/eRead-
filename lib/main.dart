import 'package:flutter/material.dart';
import 'package:memo_livre/views/book_screen.dart';
import 'package:memo_livre/views/main_screen_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/ChapterController.dart';
import 'controllers/ExcerptController.dart';
import 'controllers/book_controller.dart';
import 'controllers/vocabulary_controller.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();

  //Clés Supabase
  await Supabase.initialize(
    url: 'https://ujuswyzvftkkjklktwxv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqdXN3eXp2ZnRra2prbGt0d3h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3OTg5NTcsImV4cCI6MjA3MzM3NDk1N30.7QGTmDz_yaGo4B4XXHBA71PivmTElC5Zx4sjpuv_w8Y',
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookController()),
        ChangeNotifierProvider(create: (_) => VocabularyController()),
        ChangeNotifierProvider(create: (_) => ChapterController()),
        ChangeNotifierProvider(create: (_) => ExcerptController()),
      ],
      child: MaterialApp(
        title: 'Mémo Livre',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
      ),
    );
  }


}
