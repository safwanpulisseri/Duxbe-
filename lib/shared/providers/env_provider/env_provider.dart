import 'package:duxbe/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final envProvider = Provider<IEnvironment>((ref) => const DevelopmentEnv());
