import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';

class ChannelProvider {
  static LND _rpc = LND();
  static StateProvider<ListChannelsResponse> openChannels =
      StateProvider<ListChannelsResponse>((ref) => ListChannelsResponse());
  static FutureProvider<ListChannelsResponse> fetchChannels =
      FutureProvider<ListChannelsResponse>(
          (ref) async => await _rpc.getChannels());
  static StateProvider<PendingChannelsResponse> pendingChannels =
      StateProvider<PendingChannelsResponse>(
          (ref) => PendingChannelsResponse());
  static AutoDisposeStreamProvider<Future<bool>> channelStream =
      StreamProvider.autoDispose(
          (ref) => Stream.periodic(Duration(seconds: 15), ((_) async {
                ListChannelsResponse openChannels = await _rpc.getChannels();
                PendingChannelsResponse pendingChannels =
                    await _rpc.getPendingChannels();

                ListChannelsResponse currentOpenChannels =
                    ref.read(ChannelProvider.openChannels);
                PendingChannelsResponse currentPendingChannels =
                    ref.read(ChannelProvider.pendingChannels);

                if (currentOpenChannels != openChannels) {
                  //set the new channels
                  ref.read(ChannelProvider.openChannels.notifier).state =
                      openChannels;
                }

                if (currentPendingChannels != pendingChannels) {
                  ref.read(ChannelProvider.pendingChannels.notifier).state =
                      pendingChannels;
                }

                return true;
              })));
}
