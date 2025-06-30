import 'package:duxbe/features/home/home.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@Riverpod(keepAlive: true)
IHomeRepository homeRepo(HomeRepoRef ref) => HomeRepository();

class HomeRepository implements IHomeRepository {
  HomeRepository();
}
