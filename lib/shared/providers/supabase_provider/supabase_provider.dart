import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

@Riverpod(keepAlive: true)
SupabaseClient supabase(SupabaseRef ref) => Supabase.instance.client;

@Riverpod(keepAlive: true)
Stream<AuthState> authState(AuthStateRef ref) => ref.watch(supabaseProvider).auth.onAuthStateChange;

@Riverpod(keepAlive: true)
SupabaseStorageService supabaseStorage(SupabaseStorageRef ref) => SupabaseStorageService(ref.watch(supabaseProvider));
