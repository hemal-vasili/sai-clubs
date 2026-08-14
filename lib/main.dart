import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const SaiClubsApp());
}

class SaiClubsApp extends StatelessWidget {
  const SaiClubsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaiClubs',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SaiClubs'),
        ),
        body: const Center(
          child: Text(
            'Connected to SaiClubs',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}