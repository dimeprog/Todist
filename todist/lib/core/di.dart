import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/keys.dart';

GetIt getIt = GetIt.instance;

Future<void> setUp() async {
   await Hive.initFlutter();
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseannonKey,
      debug: kDebugMode,
    );
    
  
}
