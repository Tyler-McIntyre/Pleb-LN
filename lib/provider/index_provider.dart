import 'package:flutter_riverpod/flutter_riverpod.dart';

class IndexProvider {
  static StateProvider<int> bottomNavIndex = StateProvider<int>((ref) => 2);
  static StateProvider<int> balanceTypeIndex = StateProvider<int>((ref) => 0);
}
