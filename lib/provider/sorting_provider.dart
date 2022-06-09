import '../constants/channel_sort_type.dart';
import '../constants/tx_sort_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortingProvider {
  static StateProvider<TxSortType> txSortTypeProvider =
      StateProvider<TxSortType>((ref) => TxSortType.Date);
  static StateProvider<ChannelSortType> channelSortTypeProvider =
      StateProvider<ChannelSortType>((ref) => ChannelSortType.Id);
}
