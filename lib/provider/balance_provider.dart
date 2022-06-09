import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';

class BalanceProvider {
  static LND _rpc = LND();
  static StateProvider<WalletBalanceResponse> onChainBalance =
      StateProvider<WalletBalanceResponse>((ref) => WalletBalanceResponse());
  static StateProvider<ChannelBalanceResponse> channelBalance =
      StateProvider<ChannelBalanceResponse>((ref) => ChannelBalanceResponse());
  static AutoDisposeStreamProvider<Future<bool>> channelBalanceStream =
      StreamProvider.autoDispose(
          (ref) => Stream.periodic(Duration(seconds: 15), ((_) async {
                ChannelBalanceResponse channelBalanceResponse =
                    await _rpc.getChannelBalance();

                ChannelBalanceResponse currentChannelBalanceResponse =
                    ref.read(BalanceProvider.channelBalance);

                if (currentChannelBalanceResponse != channelBalanceResponse) {
                  ref.read(BalanceProvider.channelBalance.notifier).state =
                      channelBalanceResponse;
                }

                return true;
              })));
}
