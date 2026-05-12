import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/keys.dart';

GetIt getIt = GetIt.instance;

void setUp() async {
  getIt.registerFactoryAsync(
    ()async{
     return  await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseannonKey,
      debug: kDebugMode,
    );
    }
  );
}
