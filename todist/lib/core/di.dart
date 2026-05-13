import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/keys.dart';



Future<void> setUp() async {
   await Hive.initFlutter();
  await Hive.openBox<dynamic>('app_hive');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseannonKey,
      debug: kDebugMode,
    );
    
  
}
