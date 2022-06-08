import 'package:convert/convert.dart';
import '../UI/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import '../constants/channel_list_tile_icon.dart';
import '../database/secure_storage.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import 'package:fixnum/fixnum.dart';
import '../util/clipboard_helper.dart';
import 'widgets/future_builder_widgets.dart';

class ChannelDetailsScreen extends StatefulWidget {
  const ChannelDetailsScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);
  final Channel channel;

  @override
  State<ChannelDetailsScreen> createState() => _ChannelDetailsScreenState();
}

class _ChannelDetailsScreenState extends State<ChannelDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController channelLabelController = TextEditingController();
  TextEditingController remotePubkeyLabelController = TextEditingController();
  TextEditingController baseFeeController = TextEditingController();
  TextEditingController feeRateController = TextEditingController();
  bool userIsAddingLabel = false;
  bool userIsSure = false;
  late double _localBalancePercentage;
  late Int64 chanId;
  late String remotePubKey;
  late Int64 localBalance;
  late Int64 capacity;
  late String channelPoint;
  late Int64 lifetime;
  late Int64 uptime;
  late Int64 totalSatoshisSent;
  late Int64 totalSatoshisReceived;
  late Int64 commitFee;
  late Int64 feePerKw;
  late Int64 unsettledBalance;
  late Int64 pushAmountSat;
  late Int64 remoteBalance;
  late bool active;
  late bool private;
  final double _formSpacing = 12;
  ButtonState stateTextWithIcon_update = ButtonState.idle;
  ButtonState stateTextWithIcon_close = ButtonState.idle;

  @override
  void initState() {
    remotePubKey = widget.channel.remotePubkey;
    chanId = widget.channel.chanId;
    localBalance = widget.channel.localBalance;
    channelPoint = widget.channel.channelPoint;
    capacity = widget.channel.capacity;
    lifetime = widget.channel.lifetime;
    uptime = widget.channel.uptime;
    totalSatoshisSent = widget.channel.totalSatoshisSent;
    totalSatoshisReceived = widget.channel.totalSatoshisReceived;
    commitFee = widget.channel.commitFee;
    feePerKw = widget.channel.feePerKw;
    unsettledBalance = widget.channel.unsettledBalance;
    pushAmountSat = widget.channel.pushAmountSat;
    remoteBalance = widget.channel.remoteBalance;
    active = widget.channel.active;
    private = widget.channel.private;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      this.channelLabelController.text = await _fetchChannelLabel();
      this.remotePubkeyLabelController.text = await _fetchRemotePubkeyLabel();
      ChannelFeeReport _feeReport = await _fetchFeeReport();
      setState(() {
        baseFeeController.text = _feeReport.baseFeeMsat.toString();
        feeRateController.text = _feeReport.feeRate.toString();
      });
    });

    _localBalancePercentage =
        localBalance.toInt() / (localBalance.toInt() + remoteBalance.toInt());

    super.initState();
  }

  Future<ChannelFeeReport> _fetchFeeReport() async {
    LND rpc = LND();
    FeeReportResponse feeReport = await rpc.feeReport();

    ChannelFeeReport channelFeeReport =
        feeReport.channelFees.firstWhere((report) => report.chanId == chanId);
    return channelFeeReport;
  }

  Future<String> _fetchChannelLabel() async {
    return await SecureStorage.readValue(chanId.toString()) ?? '';
  }

  Future<String> _fetchRemotePubkeyLabel() async {
    return await SecureStorage.readValue(remotePubKey) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Center(
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
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
          ),
        ));
  }

  Widget _channelDetailsButtonBar() {
    return Column(
      children: [
        _closeButton(),
        SizedBox(
          height: _formSpacing,
        ),
        _updateButton()
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
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(
                        tabIndex: 1,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_back),
              ),
              Column(
                children: [
                  Text(
                    chanId.toString(),
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  Text(
                    'Channel Id',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: getChannelStatusIcon(active, private, false) as Icon,
              ),
            ],
          ),
        ),
        SizedBox(
          height: _formSpacing,
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
        SizedBox(
          height: _formSpacing,
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
        SizedBox(
          height: _formSpacing,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: Text(
                    remotePubKey.toString(),
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remote PubKey',
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
                    Text(
                      lifetime.toString(),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
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
                    Text(
                      uptime.toString(),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text(
                      'Uptime',
                      style: TextStyle(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
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
                    Text(
                      totalSatoshisSent.toString(),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
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
                    Text(
                      totalSatoshisReceived.toString(),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
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
                      Text(
                        commitFee.toString(),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
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
                      Text(
                        unsettledBalance.toString(),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
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
                    Text(
                      feePerKw.toString(),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
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
                    Text(
                      pushAmountSat.toString(),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
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
                        Text(
                          localBalance.toString(),
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
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
                        Text(
                          remoteBalance.toString(),
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
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
                    Text(
                      capacity.toString(),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
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
      chanId.toString(),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            }
                            return null;
                          },
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
            child = FutureBuilderWidgets.error(
              context,
              snapshot.error.toString(),
            );
          } else {
            child = FutureBuilderWidgets.circularProgressIndicator();
          }

          return child;
        }));
  }

  Future<PolicyUpdateResponse> _updateChannelPolicy(
      String channelPointStr) async {
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
    String channelPoint = this.channelPoint;
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
        backgroundColor: AppColors.white,
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
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.green,
              ),
            ),
            onPressed: () {
              userIsSure = false;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.red,
              ),
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

  Widget _closeButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColors.red,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      height: MediaQuery.of(context).size.height / 14,
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ProgressButton.icon(
          iconedButtons: {
            ButtonState.idle: IconedButton(
              text: 'Close Channel',
              icon: Icon(Icons.close),
              color: Colors.transparent,
            ),
            ButtonState.loading: IconedButton(
              text: 'Closing Channel',
              color: Colors.transparent,
            ),
            ButtonState.fail: IconedButton(
              text: 'Failed',
              icon: Icon(Icons.cancel),
              color: Colors.transparent,
            ),
            ButtonState.success: IconedButton(
              text: 'Success',
              icon: Icon(Icons.check_circle),
              color: Colors.transparent,
            )
          },
          radius: 10.0,
          textStyle: Theme.of(context).textTheme.labelMedium,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await closeChannelDialog(context);
              if (userIsSure) {
                switch (stateTextWithIcon_close) {
                  case ButtonState.idle:
                    stateTextWithIcon_close = ButtonState.loading;

                    CloseStatusUpdate closeSuccessful;

                    closeSuccessful = await _closeChannel();

                    Future.delayed(Duration(seconds: 1), () {
                      setState(() {
                        stateTextWithIcon_close =
                            closeSuccessful.hasClosePending()
                                ? ButtonState.success
                                : ButtonState.fail;
                      });

                      if (stateTextWithIcon_close == ButtonState.success) {
                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(
                                tabIndex: 1,
                              ),
                            ),
                          );
                        });
                      }
                    });

                    break;
                  case ButtonState.loading:
                    break;
                  case ButtonState.success:
                    stateTextWithIcon_close = ButtonState.idle;
                    break;
                  case ButtonState.fail:
                    stateTextWithIcon_close = ButtonState.idle;
                    break;
                }
                if (!mounted) return;
                setState(() {
                  stateTextWithIcon_close = stateTextWithIcon_close;
                });

                Future.delayed(Duration(seconds: 5), () {
                  if (!mounted) return;
                  setState(() {
                    stateTextWithIcon_close = ButtonState.idle;
                  });
                });
              }
            }
          },
          state: stateTextWithIcon_close,
        ),
      ),
    );
  }

  Widget _updateButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColors.blue,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      height: MediaQuery.of(context).size.height / 14,
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ProgressButton.icon(
          iconedButtons: {
            ButtonState.idle: IconedButton(
              text: 'Update Channel',
              icon: Icon(Icons.update),
              color: Colors.transparent,
            ),
            ButtonState.loading: IconedButton(
              text: 'Updating',
              color: Colors.transparent,
            ),
            ButtonState.fail: IconedButton(
              text: 'Failed',
              icon: Icon(Icons.cancel),
              color: Colors.transparent,
            ),
            ButtonState.success: IconedButton(
              text: 'Success',
              icon: Icon(Icons.check_circle),
              color: Colors.transparent,
            )
          },
          radius: 10.0,
          textStyle: Theme.of(context).textTheme.labelMedium,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              switch (stateTextWithIcon_update) {
                case ButtonState.idle:
                  stateTextWithIcon_update = ButtonState.loading;

                  _saveChannelLabel();
                  _saveRemotePubkeyLabel();

                  PolicyUpdateResponse updateSuccessful =
                      await _updateChannelPolicy(channelPoint);

                  Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      stateTextWithIcon_update =
                          updateSuccessful.failedUpdates.length <= 0
                              ? ButtonState.success
                              : ButtonState.fail;
                    });

                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(
                            tabIndex: 1,
                          ),
                        ),
                      );
                    });
                  });

                  break;
                case ButtonState.loading:
                  break;
                case ButtonState.success:
                  stateTextWithIcon_update = ButtonState.idle;
                  break;
                case ButtonState.fail:
                  stateTextWithIcon_update = ButtonState.idle;
                  break;
              }
              if (!mounted) return;
              setState(() {
                stateTextWithIcon_update = stateTextWithIcon_update;
              });
              Future.delayed(Duration(seconds: 5), () {
                if (!mounted) return;
                setState(() {
                  stateTextWithIcon_update = ButtonState.idle;
                });
              });
            }
          },
          state: stateTextWithIcon_update,
        ),
      ),
    );
  }
}
