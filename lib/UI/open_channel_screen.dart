import 'package:convert/convert.dart';
import 'package:firebolt/UI/Widgets/qr_code_helper.dart';
import 'package:fixnum/fixnum.dart';
import '../UI/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import 'widgets/info_dialog.dart';
import 'widgets/snackbars.dart';

class OpenChannelScreen extends StatefulWidget {
  const OpenChannelScreen({Key? key}) : super(key: key);

  @override
  State<OpenChannelScreen> createState() => _OpenChannelScreenState();
}

class _OpenChannelScreenState extends State<OpenChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nodePubkeyController = TextEditingController();
  TextEditingController fundingAmountController = TextEditingController();
  TextEditingController fundingFeeController = TextEditingController();
  TextEditingController minConfsController = TextEditingController();
  TextEditingController pushAmountController = TextEditingController();
  bool _useDefaultFundingFee = true;
  bool _privateChannel = false;
  bool _useDefaultMinConf = true;
  InfoDialog dialog = InfoDialog();
  ButtonState stateTextWithIcon = ButtonState.idle;
  final double _formSpacing = 12;

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: _body(),
          ),
        ));
  }

  Widget _body() {
    return Center(
      child: Container(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.zero,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(
                                tabIndex: 1,
                              ),
                            ));
                      },
                      icon: Icon(Icons.arrow_back),
                    )
                  ],
                ),
                SizedBox(
                  height: _formSpacing,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _openChannelForm(),
                      _buttonBar(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _scanButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColors.green,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      height: MediaQuery.of(context).size.height / 14,
      child: ElevatedButton.icon(
        icon: Icon(Icons.qr_code_scanner),
        onPressed: () async {
          QrCodeHelper helper = QrCodeHelper();
          String data = await helper.scanQrCode(mounted);

          RegExpMatch? matches = RegExp('.*(?=@)').firstMatch(data);
          String? pubKeyMatch;
          pubKeyMatch = matches != null ? pubKeyMatch = matches.group(0) : null;

          pubKeyMatch != null ? data = pubKeyMatch : null;
          _setConfigFormFields(data);
        },
        label: Text('Scan'),
        style: ElevatedButton.styleFrom(
          elevation: 3,
          minimumSize: Size(double.infinity, 50),
          primary: Colors.transparent,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }

  _openButton() {
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
              text: 'Open',
              icon: Icon(Icons.open_in_browser),
              color: Colors.transparent,
            ),
            ButtonState.loading: IconedButton(
              text: 'Sending request',
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
              bool requestSuccessful;
              switch (stateTextWithIcon) {
                case ButtonState.idle:
                  stateTextWithIcon = ButtonState.loading;
                  try {
                    OpenChannelRequest openChannelRequest;

                    Int64 satsPerVbyte = _useDefaultFundingFee
                        ? Int64(2)
                        : Int64.parseInt(fundingFeeController.text).toInt64();
                    Int64 localFundingAmount =
                        Int64.parseInt(fundingAmountController.text).toInt64();
                    // List<int> nodePubKey = hex.decode(
                    //     '0296722cbe8e8ef3208f56c28d79fa52ef61cbe5421aaabc2ac78de7a2eadaec3b');
                    List<int> nodePubKey =
                        hex.decode(nodePubkeyController.text);
                    int? minConfs = _useDefaultMinConf
                        ? null
                        : int.parse(minConfsController.text);
                    bool spendUnconfirmed =
                        minConfsController.text.isNotEmpty &&
                                int.parse(minConfsController.text) == 0
                            ? true
                            : false;
                    bool private = _privateChannel;
                    Int64 pushSat = Int64.parseInt(pushAmountController.text);

                    openChannelRequest = OpenChannelRequest(
                      satPerVbyte: satsPerVbyte,
                      localFundingAmount: localFundingAmount,
                      private: private,
                      nodePubkey: nodePubKey,
                      minConfs: minConfs,
                      spendUnconfirmed: spendUnconfirmed,
                      pushSat: pushSat,
                    );

                    var response = await _openChannel(openChannelRequest);
                    requestSuccessful = response.hasChanPending();
                  } catch (ex) {
                    requestSuccessful = false;
                  }
                  Future.delayed(Duration(seconds: 1), () {
                    if (!mounted) return;
                    setState(() {
                      stateTextWithIcon = requestSuccessful
                          ? ButtonState.success
                          : ButtonState.fail;
                    });
                  });

                  if (requestSuccessful)
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardScreen(
                                    tabIndex: 1,
                                  )));
                    });

                  break;
                case ButtonState.loading:
                  break;
                case ButtonState.success:
                  stateTextWithIcon = ButtonState.idle;
                  break;
                case ButtonState.fail:
                  stateTextWithIcon = ButtonState.idle;
                  break;
              }
              if (!mounted) return;
              setState(() {
                stateTextWithIcon = stateTextWithIcon;
              });
              Future.delayed(Duration(seconds: 5), () {
                if (!mounted) return;
                setState(() {
                  stateTextWithIcon = ButtonState.idle;
                });
              });
            }
          },
          state: stateTextWithIcon,
        ),
      ),
    );
  }

  Widget _buttonBar() {
    return Column(
      children: [
        _scanButton(),
        SizedBox(
          height: _formSpacing,
        ),
        _openButton(),
        SizedBox(
          height: _formSpacing,
        ),
      ],
    );
  }

  void _setConfigFormFields(String data) {
    if (!mounted) return;
    setState(() {
      nodePubkeyController.text = data;
    });
  }

  Widget _openChannelForm() {
    return Column(
      children: [
        TextFormField(
          controller: nodePubkeyController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
          decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.paste,
                  color: AppColors.grey,
                ),
                onPressed: () async {
                  ClipboardData? clipboardData =
                      await Clipboard.getData(Clipboard.kTextPlain);
                  if (clipboardData!.text!.isNotEmpty) {
                    String nodePubkey = clipboardData.text!;

                    _setConfigFormFields(nodePubkey);
                  }
                },
              ),
              label: Text('Node PubKey'),
              hintText: '03f0ba19fd88e...'),
        ),
        SizedBox(
          height: _formSpacing,
        ),
        //Local Funding Amount
        TextFormField(
          controller: fundingAmountController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '...',
            label: Text('Local Funding Amount'),
          ),
        ),
        SizedBox(
          height: _formSpacing,
        ),
        //Push Amount
        TextFormField(
          controller: pushAmountController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '...',
            label: Text('Push Amount'),
          ),
        ),
        SizedBox(
          height: _formSpacing,
        ),
        //min confirmations
        SwitchListTile(
          activeColor: AppColors.blue,
          contentPadding: EdgeInsets.zero,
          onChanged: ((value) {
            if (!mounted) return;
            setState(() {
              _useDefaultMinConf = value;
            });
          }),
          value: _useDefaultMinConf,
          title: Row(
            children: [
              Text('Minimum confirmations'),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  String body = dialog.blurbs[DialogType.MinimumConfirmations]!;
                  await dialog.showMyDialog(body, context);
                },
              )
            ],
          ),
          subtitle: _useDefaultMinConf
              ? Text('Default = 1 confirmation')
              : TextFormField(
                  controller: minConfsController,
                  validator: (value) {
                    if (value!.isEmpty && !_useDefaultMinConf) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '...',
                  ),
                ),
        ),
        //Funding fee rate
        SwitchListTile(
          activeColor: AppColors.blue,
          contentPadding: EdgeInsets.zero,
          onChanged: ((value) {
            if (!mounted) return;
            setState(() {
              _useDefaultFundingFee = value;
            });
          }),
          value: _useDefaultFundingFee,
          title: Row(
            children: [
              Text('Funding fee rate'),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  String body = dialog.blurbs[DialogType.ChannelFee]!;
                  await dialog.showMyDialog(body, context);
                },
              )
            ],
          ),
          subtitle: _useDefaultFundingFee
              ? Text('Default = 2 sats per vbyte')
              : TextFormField(
                  controller: fundingFeeController,
                  validator: (value) {
                    if (value!.isEmpty && !_useDefaultFundingFee) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '...',
                  ),
                ),
        ),
        //Private channel
        SizedBox(
          height: _formSpacing,
        ),
        SwitchListTile(
          activeColor: AppColors.blue,
          contentPadding: EdgeInsets.zero,
          onChanged: ((value) {
            if (!mounted) return;
            setState(() {
              _privateChannel = value;
            });
          }),
          value: _privateChannel,
          title: Text('Private Channel'),
        ),
        SizedBox(
          height: _formSpacing,
        ),
      ],
    );
  }

  Future<OpenStatusUpdate> _openChannel(
    OpenChannelRequest params,
  ) async {
    LND rpc = LND();
    OpenStatusUpdate response;
    try {
      response = await rpc.openChannel(params);
    } catch (ex) {
      Snackbars.error(
        context,
        ex.toString(),
      );

      throw Exception(ex);
    }
    return response;
  }
}
