// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

abstract class IEnvironment {
  const IEnvironment();
  String get SERVER_URL;
  String get ANON_KEY;
  String get STRIPE_KEY;
  Duration get CONNECT_TIMEOUT;
  Duration get RECEIVE_TIMEOUT;
  String get VAPID_KEY;
}

final class Environment {
  static const SERVER_URL = String.fromEnvironment('SERVER_URL');
  static const ANON_KEY = String.fromEnvironment('ANON_KEY');
  static const gMapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const posDomain = String.fromEnvironment('POS_DOMAIN');
  static const appDomain = String.fromEnvironment('APP_DOMAIN');
  static const vapidKey = String.fromEnvironment('VAPID_KEY');
}

class ProductionEnv extends IEnvironment {
  const ProductionEnv();
  @override
  String get SERVER_URL => 'https://tgrtjlqehgpzdjrlrxxl.supabase.co';
  @override
  String get ANON_KEY =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRncnRqbHFlaGdwemRqcmxyeHhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE2NTcxMDYsImV4cCI6MjAzNzIzMzEwNn0.J9BnWfuLndIJlBJIpGA9qGGgKbrDhvc83ZJ8te3WjiE';
  @override
  String get STRIPE_KEY =>
      'sk_test_51OFEmRSDSxtynIS8ZFfIv7fWah40UmmYeO7CAzVXz8Znp8oUZMcwPYdhkRcaq0kEz1HOvx0onZghSsMEYjBvkxaJ00YbgMEZQj';

  @override
  Duration get CONNECT_TIMEOUT => const Duration(seconds: 5000);
  @override
  Duration get RECEIVE_TIMEOUT => const Duration(seconds: 3000);
  @override
  String get VAPID_KEY => 'BK8usg8S2Ma5pVhLHwAE54REfdh7bhqKsc0TwAE3ZQ6XFI9U8JqqwO1LdO88zaQrvnI0J9RFgO8ogNPBSNJH3E0';
}

class StagingEnv extends IEnvironment {
  const StagingEnv();
  @override
  String get SERVER_URL => 'https://acagaylcxrkpjrdldcie.supabase.co';
  @override
  String get ANON_KEY =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjYWdheWxjeHJrcGpyZGxkY2llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg5NzI5MjMsImV4cCI6MjA0NDU0ODkyM30.BkXBBNZcif-9hqUFu1oUNdcx_JrDlgqSTzcq7ktV-qI';
  @override
  String get STRIPE_KEY =>
      'sk_test_51OFEmRSDSxtynIS8ZFfIv7fWah40UmmYeO7CAzVXz8Znp8oUZMcwPYdhkRcaq0kEz1HOvx0onZghSsMEYjBvkxaJ00YbgMEZQj';

  @override
  Duration get CONNECT_TIMEOUT => const Duration(seconds: 5000);
  @override
  Duration get RECEIVE_TIMEOUT => const Duration(seconds: 3000);
  @override
  String get VAPID_KEY => 'BK8usg8S2Ma5pVhLHwAE54REfdh7bhqKsc0TwAE3ZQ6XFI9U8JqqwO1LdO88zaQrvnI0J9RFgO8ogNPBSNJH3E0';
}

class DevelopmentEnv extends IEnvironment {
  const DevelopmentEnv();
  @override
  String get SERVER_URL => 'https://awfbsiftpwpiczdxlmig.supabase.co';
  @override
  String get ANON_KEY =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3ZmJzaWZ0cHdwaWN6ZHhsbWlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY5Njg2NzYsImV4cCI6MjAxMjU0NDY3Nn0.RDOvnQ2Ld7e5bIGRSk_q2mIx3YIHNQrWg5iZdKnjLRE';
  @override
  String get STRIPE_KEY =>
      'sk_test_51OFEmRSDSxtynIS8ZFfIv7fWah40UmmYeO7CAzVXz8Znp8oUZMcwPYdhkRcaq0kEz1HOvx0onZghSsMEYjBvkxaJ00YbgMEZQj';

  @override
  Duration get CONNECT_TIMEOUT => const Duration(seconds: 5000);
  @override
  Duration get RECEIVE_TIMEOUT => const Duration(seconds: 3000);
  @override
  String get VAPID_KEY => 'BK8usg8S2Ma5pVhLHwAE54REfdh7bhqKsc0TwAE3ZQ6XFI9U8JqqwO1LdO88zaQrvnI0J9RFgO8ogNPBSNJH3E0';
}

class LocalEnv extends IEnvironment {
  const LocalEnv();
  @override
  // String get SERVER_URL => 'http://192.168.1.40:54321';
  String get SERVER_URL => 'http://localhost:54321';
  @override
  String get ANON_KEY =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
  @override
  String get STRIPE_KEY =>
      'sk_test_51OFEmRSDSxtynIS8ZFfIv7fWah40UmmYeO7CAzVXz8Znp8oUZMcwPYdhkRcaq0kEz1HOvx0onZghSsMEYjBvkxaJ00YbgMEZQj';

  @override
  Duration get CONNECT_TIMEOUT => const Duration(seconds: 5000);
  @override
  Duration get RECEIVE_TIMEOUT => const Duration(seconds: 3000);
  @override
  String get VAPID_KEY => 'BK8usg8S2Ma5pVhLHwAE54REfdh7bhqKsc0TwAE3ZQ6XFI9U8JqqwO1LdO88zaQrvnI0J9RFgO8ogNPBSNJH3E0';
}
