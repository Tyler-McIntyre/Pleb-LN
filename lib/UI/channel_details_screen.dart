import 'package:convert/convert.dart';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:firebolt/models/channel_detail.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constants/channel_list_tile_icon.dart';
import '../database/secure_storage.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import 'package:fixnum/fixnum.dart';
import '../util/clipboard_helper.dart';

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
  late double _localBalancePercentage;
  bool userIsSure = false;
  late String chanId;
  late String remotePubKey;
  late Int64 localBalance;
  late Int64 capacity;

  @override
  void initState() {
    remotePubKey = widget.channel.channel!.remotePubkey;
    chanId = widget.channel.chanId;
    localBalance = widget.channel.channel!.localBalance;
    capacity = widget.channel.channel!.capacity;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      this.channelLabelController.text = await _fetchChannelLabel();
      this.remotePubkeyLabelController.text = await _fetchRemotePubkeyLabel();
      ChannelFeeReport _feeReport = await _fetchFeeReport();
      setState(() {
        baseFeeController.text = _feeReport.baseFeeMsat.toString();
        feeRateController.text = _feeReport.feeRate.toString();
      });
    });

    _localBalancePercentage = localBalance.toInt() / capacity.toInt();
    feePerKwController.text = widget.channel.channel!.feePerKw.toString();
    super.initState();
  }

  Future<ChannelFeeReport> _fetchFeeReport() async {
    LND rpc = LND();
    FeeReportResponse feeReport = await rpc.feeReport();

    ChannelFeeReport channelFeeReport = feeReport.channelFees
        .firstWhere((report) => report.chanId.toString() == chanId);
    return channelFeeReport;
  }

  Future<String> _fetchChannelLabel() async {
    return await SecureStorage.readValue(chanId) ?? '';
  }

  Future<String> _fetchRemotePubkeyLabel() async {
    return await SecureStorage.readValue(remotePubKey) ?? '';
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
          onPressed: () async {
            await closeChannelDialog(context);

            if (userIsSure) {
              _closeChannel();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            }
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
          onPressed: () async {
            _saveChannelLabel();
            _saveRemotePubkeyLabel();

            try {
              await _updateChannelPolicy(widget.channel.channel!.channelPoint);
            } catch (ex) {
              String message = ex.toString().replaceAll('Exception:', '');

              final snackBar = SnackBar(
                duration: Duration(seconds: 5),
                content: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                backgroundColor: (AppColors.red),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              throw Exception(ex);
            }

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
                  Text(chanId),
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
                  ClipboardHelper.copyToClipboard(chanId, context);
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
                      remotePubKey,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remote pubkey',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ClipboardHelper.copyToClipboard(
                              remotePubKey, context);
                        },
                        icon: Icon(Icons.copy),
                        color: AppColors.grey,
                      )
                    ],
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
                        Text(localBalance.toString()),
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
                    Text(capacity.toString()),
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
      chanId,
      channelLabelController.text,
    );
  }

  void _saveRemotePubkeyLabel() async {
    await SecureStorage.writeValue(
      remotePubKey,
      remotePubkeyLabelController.text,
    );
  }

  _channelPolicy() {
    return FutureBuilder(
        future: _fetchFeeReport(),
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
                          keyboardType: TextInputType.number,
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
                          keyboardType: TextInputType.number,
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

  _updateChannelPolicy(String channelPointStr) async {
    LND rpc = LND();
    List<String> splitChannelPoint = channelPointStr.split(':');
    List<int> fundingTxidBytes = hex.decode(splitChannelPoint[0]);
    PolicyUpdateResponse response = PolicyUpdateResponse();
    ChannelPoint chanPoint = ChannelPoint(
      fundingTxidBytes: fundingTxidBytes,
      fundingTxidStr: splitChannelPoint[0],
      outputIndex: int.parse(
        splitChannelPoint[1],
      ),
    );

    PolicyUpdateRequest policyUpdateRequest = PolicyUpdateRequest(
      chanPoint: chanPoint,
      baseFeeMsat: Int64.parseInt(baseFeeController.text).toInt64(),
      feeRate: double.parse(feeRateController.text),
      timeLockDelta: 18,
    );
    try {
      response = await rpc.updateChannelPolicy(policyUpdateRequest);
    } catch (ex) {
      throw Exception(ex);
    }
    return response;
  }

  Future<CloseStatusUpdate> _closeChannel() async {
    LND rpc = LND();
    String channelPoint = widget.channel.channel!.channelPoint;
    List<String> splitChannelPoint = channelPoint.split(':');
    List<int> fundingTxidBytes = hex.decode(splitChannelPoint[0]);
    ChannelPoint chanPoint = ChannelPoint(
      fundingTxidBytes: fundingTxidBytes,
      fundingTxidStr: splitChannelPoint[0],
      outputIndex: int.parse(
        splitChannelPoint[1],
      ),
    );
    CloseChannelRequest closeChannelRequest =
        CloseChannelRequest(channelPoint: chanPoint);
    return await rpc.closeChannel(closeChannelRequest);
  }

  Future<void> closeChannelDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Icon(
          Icons.info_outline,
          color: AppColors.blue,
          size: 35,
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Are you sure you want to close this channel?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.black, fontSize: 20),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              userIsSure = false;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              userIsSure = true;
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
