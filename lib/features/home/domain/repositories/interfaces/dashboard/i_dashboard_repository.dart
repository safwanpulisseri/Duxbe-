import 'package:duxbe/features/home/home.dart';

// ignore: one_member_abstracts
abstract class IDashboardRepository {
  Future<HomeModel> getDashboard();
}
