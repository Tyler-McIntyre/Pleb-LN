import '../generated/lightning.pb.dart';
import '../util/app_colors.dart';
import 'package:flutter/material.dart';
import '../rpc/lnd.dart';
import '../util/clipboard_helper.dart';
import 'dashboard_screen.dart';
import 'widgets/future_builder_widgets.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({
    Key? key,
    required this.tabIndex,
  }) : super(key: key);
  final int tabIndex;

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  double _formSpacing = 12;

  @override
  initState() {
    super.initState();
  }

  Future<GetInfoResponse> _getInfo() async {
    LND rpc = LND();
    GetInfoResponse response = await rpc.getInfo();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  tabIndex: widget.tabIndex,
                ),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: _formSpacing,
                  ),
                  _nodeInfoFutureBuilder(),
                  //TODO: configure any defaults across the app
                  // _setDefaultsForm()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _nodeInfoFutureBuilder() {
    return FutureBuilder(
        future: _getInfo(),
        builder: (context, AsyncSnapshot<GetInfoResponse> snapshot) {
          Widget child;
          late String alias = snapshot.data!.alias;
          late String version = snapshot.data!.version;
          late String pubkey = snapshot.data!.identityPubkey;
          late bool syncedToChain = snapshot.data!.syncedToChain;
          late int numPeers = snapshot.data!.numPeers;
          late int numActiveChannels = snapshot.data!.numActiveChannels;

          if (snapshot.hasData) {
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: alias,
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                  decoration: InputDecoration(
                    enabled: false,
                    label: Text('Alias',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
                SizedBox(
                  height: _formSpacing,
                ),
                TextFormField(
                  initialValue: version,
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                  decoration: InputDecoration(
                    enabled: false,
                    label: Text('Version',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
                SizedBox(
                  height: _formSpacing,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          enabled: false,
                          initialValue: pubkey,
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                          decoration: InputDecoration(
                            label: Text(
                              'PubKey',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          ClipboardHelper.copyToClipboard(pubkey, context);
                        },
                        icon: Icon(Icons.copy)),
                  ],
                ),
                SizedBox(
                  height: _formSpacing,
                ),
                TextFormField(
                  initialValue: syncedToChain.toString(),
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                  decoration: InputDecoration(
                    enabled: false,
                    label: Text('Synced to chain',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
                SizedBox(
                  height: _formSpacing,
                ),
                TextFormField(
                  initialValue: numPeers.toString(),
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                  decoration: InputDecoration(
                    enabled: false,
                    label: Text('Number of peers',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
                SizedBox(
                  height: _formSpacing,
                ),
                TextFormField(
                  initialValue: numActiveChannels.toString(),
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                  decoration: InputDecoration(
                    enabled: false,
                    label: Text('Active channels',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            child =
                FutureBuilderWidgets.error(context, snapshot.error.toString());
          } else {
            child = FutureBuilderWidgets.circularProgressIndicator();
          }
          return child;
        });
  }
}
