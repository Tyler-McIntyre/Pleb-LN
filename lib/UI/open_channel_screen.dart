import 'package:convert/convert.dart';
import 'package:fixnum/fixnum.dart';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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
  late String qrCode;
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

//TODO remove me
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
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
                  ),
                  SizedBox(
                    height: _formSpacing,
                  ),
                  Form(
                    key: _formKey,
                    child: _openChannelForm(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  _scanLndConfigButton() {
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
          await scanQrCode();
          String nodePubKey = qrCode;
          String? pubKeyMatch =
              RegExp('.*(?=@)').firstMatch(nodePubKey)!.group(0);
          if (pubKeyMatch!.isNotEmpty) {
            _setConfigFormFields(nodePubKey);
          }
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
        _scanLndConfigButton(),
        SizedBox(
          height: _formSpacing,
        ),
        _openButton(),
      ],
    );
  }

  Future<void> scanQrCode() async {
    try {
      String qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#E62119', 'Cancel', true, ScanMode.QR);

      if (!mounted) return;

      setState(() {
        this.qrCode = qrCode;
      });
    } on PlatformException {
      this.qrCode = 'Failed to get platform version.';
    }
  }

  void _setConfigFormFields(String nodePubkey) {
    if (!mounted) return;
    setState(() {
      nodePubkeyController.text = nodePubkey;
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
              errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
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
              focusedBorder:
                  Theme.of(context).inputDecorationTheme.focusedBorder,
              label: Text('Node PubKey',
                  style: Theme.of(context).inputDecorationTheme.labelStyle),
              hintText: '03f0ba19fd88e...'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        //Local Funding Amount
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: TextFormField(
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
              errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
              focusedBorder:
                  Theme.of(context).inputDecorationTheme.focusedBorder,
              label: Text('Local Funding Amount',
                  style: Theme.of(context).inputDecorationTheme.labelStyle),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
            errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            label: Text('Push Amount',
                style: Theme.of(context).inputDecorationTheme.labelStyle),
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        //min confirmations
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SwitchListTile(
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
                Text('Minimum confirmations',
                    style: Theme.of(context).textTheme.bodySmall),
                IconButton(
                  padding: EdgeInsets.only(bottom: 5),
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    String body =
                        dialog.blurbs[DialogType.MinimumConfirmations]!;
                    await dialog.showMyDialog(body, context);
                  },
                )
              ],
            ),
            subtitle: _useDefaultMinConf
                ? Text(
                    'Default = 1 confirmation',
                    style: Theme.of(context).textTheme.labelSmall,
                  )
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
                        errorStyle:
                            Theme.of(context).inputDecorationTheme.errorStyle,
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder,
                        hintText: '...'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
          ),
        ),
        //Channel Fee
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
              Text(
                'Funding fee rate',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              IconButton(
                padding: EdgeInsets.only(bottom: 4),
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
              ? Text(
                  'Default = 2 sats per vbyte',
                  style: Theme.of(context).textTheme.labelSmall,
                )
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
                      errorStyle:
                          Theme.of(context).inputDecorationTheme.errorStyle,
                      contentPadding: EdgeInsets.zero,
                      focusedBorder:
                          Theme.of(context).inputDecorationTheme.focusedBorder,
                      hintText: '...'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
        ),
        //Private channel
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SwitchListTile(
            activeColor: AppColors.blue,
            contentPadding: EdgeInsets.zero,
            onChanged: ((value) {
              if (!mounted) return;
              setState(() {
                _privateChannel = value;
              });
            }),
            value: _privateChannel,
            title: Text(
              'Private Channel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        _buttonBar()
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
