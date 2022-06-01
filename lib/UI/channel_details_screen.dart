import 'package:convert/convert.dart';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:firebolt/models/channel_detail.dart';
import 'package:firebolt/models/channel_fee_report.dart';
import 'package:firebolt/models/fee_report.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../api/lnd.dart';
import '../constants/channel_list_tile_icon.dart';
import '../database/secure_storage.dart';
import '../models/channel_point.dart';
import '../models/update_channel_policy.dart';
import '../util/app_colors.dart';

class ChannelDetailsScreen extends StatefulWidget {
  const ChannelDetailsScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);
  final ChannelDetail channel;

  @override
  State<ChannelDetailsScreen> createState() => _ChannelDetailsScreenState();
}

class _ChannelDetailsScreenState extends State<ChannelDetailsScreen> {
  // final _formKey = GlobalKey<FormState>();
  TextEditingController channelLabelController = TextEditingController();
  TextEditingController remotePubkeyLabelController = TextEditingController();
  TextEditingController feePerKwController = TextEditingController();
  TextEditingController baseFeeController = TextEditingController();
  TextEditingController feeRateController = TextEditingController();
  bool userIsAddingLabel = false;
  late Future<ChannelFeeReport> _channelFeeReport;
  late double _localBalancePercentage;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      this.channelLabelController.text = await _fetchChannelLabel();
      this.remotePubkeyLabelController.text = await _fetchRemotePubkeyLabel();
      Future<ChannelFeeReport> futureFeeReport = _fetchFeeReport();
      setState(() {
        futureFeeReport
            .then((value) => baseFeeController.text = value.baseFeeMsat);
        futureFeeReport
            .then((value) => feeRateController.text = value.feeRate.toString());
        this._channelFeeReport = futureFeeReport;
      });
    });
    _localBalancePercentage =
        (int.parse(widget.channel.channel!.localBalance.toString()) /
            (int.parse(widget.channel.channel!.capacity.toString())));
    feePerKwController.text = widget.channel.channel!.feePerKw.toString();
    super.initState();
  }

  Future<ChannelFeeReport> _fetchFeeReport() async {
    LND api = LND();
    FeeReport feeReport = await api.getFeeReport();
    ChannelFeeReport? channelFeeReport = feeReport.channelFees
        .firstWhere((report) => report.chanId == widget.channel.chanId);
    return channelFeeReport;
  }

  Future<String> _fetchChannelLabel() async {
    return await SecureStorage.readValue(widget.channel.chanId) ?? '';
  }

  Future<String> _fetchRemotePubkeyLabel() async {
    return await SecureStorage.readValue(
            widget.channel.channel!.remotePubkey) ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _channelDetailsForm(),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: _channelPolicy(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _channelDetailsButtonBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _channelDetailsButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            LND api = LND();
            api.closeChannel(widget.channel.channel!.channelPoint);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          },
          child: Text(
            'Close Channel',
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(175, 50),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: Theme.of(context).textTheme.displaySmall,
            side: const BorderSide(
              color: AppColors.red,
              width: 1.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _saveChannelLabel();
            _saveRemotePubkeyLabel();
            _updateChannelPolicy(widget.channel.channel!.channelPoint);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          },
          child: Text(
            'Update channel',
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(175, 50),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: Theme.of(context).textTheme.displaySmall,
            side: const BorderSide(
              color: AppColors.blue,
              width: 1.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _channelDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: getChannelStatusIcon(widget.channel) as Icon,
              ),
              Column(
                children: [
                  Text(widget.channel.chanId),
                  Text(
                    'Channel id',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  //TODO: make this copyable
                },
                icon: Icon(Icons.copy),
                color: AppColors.grey,
              )
            ],
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.1,
            child: TextFormField(
              controller: channelLabelController,
              decoration: InputDecoration(
                focusedBorder:
                    Theme.of(context).inputDecorationTheme.focusedBorder,
                label: Text('Channel Label'),
                hintText: '...',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.1,
            child: TextFormField(
              controller: remotePubkeyLabelController,
              decoration: InputDecoration(
                focusedBorder:
                    Theme.of(context).inputDecorationTheme.focusedBorder,
                label: Text(
                  'Pubkey Label',
                  style: Theme.of(context).inputDecorationTheme.labelStyle,
                ),
                hintText: '...',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    enabled: false,
                    label: Text(
                      widget.channel.channel!.remotePubkey,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Text(
                  'Remote pubkey',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.lifetime.toString()),
                    Text(
                      'Lifetime',
                      style: TextStyle(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.channel.channel!.uptime.toString()),
                  Text(
                    'Uptime',
                    style: TextStyle(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.totalSatoshisSent.toString()),
                    Text(
                      'Sats sent',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.totalSatoshisReceived
                        .toString()),
                    Text(
                      'Sats received',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.channel.channel!.commitFee.toString()),
                      Text(
                        'Commit fee',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.channel.channel!.unsettledBalance.toString()),
                      Text(
                        'Unsettled balance',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.feePerKw.toString()),
                    Text(
                      'Fee per kw',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.pushAmountSat.toString()),
                    Text(
                      'Push amount sat',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(widget.channel.channel!.localBalance.toString()),
                        Text(
                          'Local balance',
                          style: TextStyle(color: AppColors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(widget.channel.channel!.remoteBalance.toString()),
                        Text(
                          'Remote balance',
                          style: TextStyle(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CircularPercentIndicator(
                radius: 100,
                animation: true,
                animationDuration: 1200,
                lineWidth: 15.0,
                percent: _localBalancePercentage,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.capacity.toString()),
                    Text(
                      'Capacity',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.square,
                backgroundColor: AppColors.red,
                progressColor: AppColors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveChannelLabel() async {
    await SecureStorage.writeValue(
      widget.channel.chanId,
      channelLabelController.text,
    );
  }

  void _saveRemotePubkeyLabel() async {
    await SecureStorage.writeValue(
      widget.channel.channel!.remotePubkey,
      remotePubkeyLabelController.text,
    );
  }

  _channelPolicy() {
    return FutureBuilder(
        future: _channelFeeReport,
        builder: ((context, AsyncSnapshot<ChannelFeeReport> snapshot) {
          Widget child;
          if (snapshot.hasData) {
            child = Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          controller: baseFeeController,
                          decoration: InputDecoration(
                            focusedBorder: Theme.of(context)
                                .inputDecorationTheme
                                .focusedBorder,
                            label: Text.rich(
                              TextSpan(
                                text: 'base fee ',
                                children: [
                                  TextSpan(
                                      text: '(msats)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall),
                                ],
                              ),
                            ),
                            hintText: '...',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          controller: feeRateController,
                          decoration: InputDecoration(
                            focusedBorder: Theme.of(context)
                                .inputDecorationTheme
                                .focusedBorder,
                            label: Text('fee rate'),
                            hintText: '...',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            child = Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).errorColor,
                  size: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).errorColor),
                  textAlign: TextAlign.center,
                ),
              )
            ]);
          } else {
            child = SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            );
          }

          return child;
        }));
  }

  void _updateChannelPolicy(String channelPointStr) {
    LND api = LND();
    List<String> splitChannelPoint = channelPointStr.split(':');
    List<int> fundingTxidBytes = hex.decode(splitChannelPoint[0]);

    ChannelPoint chanPoint = ChannelPoint(fundingTxidBytes,
        splitChannelPoint[0], int.parse(splitChannelPoint[1]));
    UpdateChannelPolicy params = UpdateChannelPolicy(
      false,
      chanPoint,
      baseFeeController.text,
      double.parse(feeRateController.text),
      timeLockDelta: 30,
    );
    api.updateChannelPolicy(params);
  }
}
