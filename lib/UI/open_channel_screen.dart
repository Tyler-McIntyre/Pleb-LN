import 'package:convert/convert.dart';
import 'package:fixnum/fixnum.dart';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import 'widgets/info_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
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

  Widget _buttonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () async {
            await scanQrCode();
            String nodePubKey = qrCode;
            String? pubKeyMatch =
                RegExp('.*(?=@)').firstMatch(nodePubKey)!.group(0);
            if (pubKeyMatch!.isNotEmpty) {
              _setConfigFormFields(nodePubKey);
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(100, 71),
            primary: AppColors.black,
            textStyle: Theme.of(context).textTheme.bodyMedium,
            side: const BorderSide(
              color: AppColors.green,
              width: 1.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: AppColors.white,
              ),
              Text(
                'Scan',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              //TODO: reset all fields
              nodePubkeyController.text = '';
              fundingAmountController.text = '';
              fundingFeeController.text = '';
              minConfsController.text = '';
              pushAmountController.text = '';
              _useDefaultFundingFee = true;
              _useDefaultMinConf = true;
              _privateChannel = false;
            });
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(100, 71),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: const TextStyle(fontSize: 20),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restore,
                color: AppColors.white,
              ),
              Text(
                'Reset',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Int64 satsPerVbyte = _useDefaultFundingFee
                  ? Int64(40)
                  : Int64.parseInt(fundingFeeController.text).toInt64();
              Int64 localFundingAmount =
                  Int64.parseInt(fundingAmountController.text).toInt64();
              // List<int> nodePubKey = hex.decode(
              //     '0296722cbe8e8ef3208f56c28d79fa52ef61cbe5421aaabc2ac78de7a2eadaec3b');
              List<int> nodePubKey = hex.decode(nodePubkeyController.text);
              int? minConfs = _useDefaultMinConf
                  ? null
                  : int.parse(minConfsController.text);
              bool spendUnconfirmed = minConfsController.text.isNotEmpty &&
                      int.parse(minConfsController.text) == 0
                  ? true
                  : false;
              bool private = _privateChannel;
              Int64 pushSat = Int64.parseInt(pushAmountController.text);

              OpenChannelRequest openChannelRequest = OpenChannelRequest(
                satPerVbyte: satsPerVbyte,
                localFundingAmount: localFundingAmount,
                private: private,
                nodePubkey: nodePubKey,
                minConfs: minConfs,
                spendUnconfirmed: spendUnconfirmed,
                pushSat: pushSat,
              );

              try {
                await _openChannel(openChannelRequest);
              } catch (ex) {
                throw Exception(ex);
              }

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()));
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(100, 71),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: const TextStyle(fontSize: 20),
            side: const BorderSide(
              color: AppColors.orange,
              width: 1.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.open_in_browser,
                color: AppColors.white,
              ),
              Text(
                'Open',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
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
                  color: AppColors.orange,
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
              label: Text('Node pubkey',
                  style: Theme.of(context).inputDecorationTheme.labelStyle),
              hintText: '03f0ba19fd88e...'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        //Funding Amount
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
              errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
              focusedBorder:
                  Theme.of(context).inputDecorationTheme.focusedBorder,
              label: Text('Funding Amount',
                  style: Theme.of(context).inputDecorationTheme.labelStyle),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
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
            errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            label: Text('Push Amount',
                style: Theme.of(context).inputDecorationTheme.labelStyle),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        //min confirmations
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SwitchListTile(
            tileColor: AppColors.black,
            contentPadding: EdgeInsets.zero,
            onChanged: ((value) {
              setState(() {
                _useDefaultMinConf = value;
              });
            }),
            value: _useDefaultMinConf,
            title: Row(
              children: [
                Text(
                  'Minimum confirmations',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
                    'Default = 4 confirmations',
                    style: Theme.of(context).textTheme.displaySmall,
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
          ),
        ),
        //Channel Fee
        SwitchListTile(
          tileColor: AppColors.black,
          contentPadding: EdgeInsets.zero,
          onChanged: ((value) {
            setState(() {
              _useDefaultFundingFee = value;
            });
          }),
          value: _useDefaultFundingFee,
          title: Row(
            children: [
              Text(
                'Funding fee rate',
                style: Theme.of(context).textTheme.bodyMedium,
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
                  'Default = 40 sats per vbyte',
                  style: Theme.of(context).textTheme.displaySmall,
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
        ),
        //Private channel
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SwitchListTile(
            tileColor: AppColors.black,
            contentPadding: EdgeInsets.zero,
            onChanged: ((value) {
              setState(() {
                _privateChannel = value;
              });
            }),
            value: _privateChannel,
            title: Text(
              'Private channel',
              style: Theme.of(context).textTheme.bodyMedium,
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
    return response;
  }
}
