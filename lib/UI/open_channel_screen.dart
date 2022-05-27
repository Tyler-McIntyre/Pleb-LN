import 'package:convert/convert.dart';
import 'package:firebolt/models/open_channel.dart';
import 'package:firebolt/models/open_channel_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../api/lnd.dart';
import '../util/app_colors.dart';
import 'Widgets/curve_clipper.dart';

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
  TextEditingController channelFeeController = TextEditingController();
  bool _useDefaultChannelFee = true;
  bool _privateChannel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            ClipPath(
              clipper: CurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * .80,
                color: AppColors.black,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 30.0),
                            child: TextFormField(
                              controller: nodePubkeyController,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.paste,
                                      color: AppColors.orange,
                                    ),
                                    onPressed: () async {
                                      ClipboardData? clipboardData =
                                          await Clipboard.getData(
                                              Clipboard.kTextPlain);
                                      if (clipboardData!.text!.isNotEmpty) {
                                        String nodePubkey = clipboardData.text!;

                                        _setConfigFormFields(nodePubkey);
                                      }
                                    },
                                  ),
                                  focusedBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .focusedBorder,
                                  label: Text('Node pubkey',
                                      style: Theme.of(context)
                                          .inputDecorationTheme
                                          .labelStyle),
                                  hintText: '03f0ba19fd88e...'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          //Funding Amount
                          TextFormField(
                            controller: fundingAmountController,
                            decoration: InputDecoration(
                              focusedBorder: Theme.of(context)
                                  .inputDecorationTheme
                                  .focusedBorder,
                              label: Text('Funding Amount',
                                  style: Theme.of(context)
                                      .inputDecorationTheme
                                      .labelStyle),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          //Channel Fee
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 0, 8),
                            child: SwitchListTile(
                              onChanged: ((value) {
                                setState(() {
                                  _useDefaultChannelFee = value;
                                });
                              }),
                              value: _useDefaultChannelFee,
                              title: Text(
                                'Channel fee',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              subtitle: _useDefaultChannelFee
                                  ? Text(
                                      'Default = 0 sats per vbyte',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    )
                                  : TextFormField(
                                      controller: channelFeeController,
                                      decoration: InputDecoration(
                                          focusedBorder: Theme.of(context)
                                              .inputDecorationTheme
                                              .focusedBorder,
                                          hintText: '...'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                            ),
                          ),
                          //Channel Fee
                          SwitchListTile(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .73,
                  right: 10.0,
                  left: 10.0),
              child: SizedBox(
                height: 100.0,
                width: MediaQuery.of(context).size.width,
                child: SizedBox(
                  child: _buttonBar(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buttonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () async {
            await scanQrCode();
            String nodePubKey = qrCode;
            _setConfigFormFields(nodePubKey);
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
              channelFeeController.text = '';
              _useDefaultChannelFee = true;
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
              //? Should we either navigate to success splash screen or display error within form?
              _openChannel();
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

  Future<OpenChannelResponse> _openChannel() async {
    //open channel
    LND api = LND();
    OpenChannel params = OpenChannel(
      _privateChannel,
      fundingAmountController.text,
      hex.decode(nodePubkeyController.text),
      satPerVbyte: _useDefaultChannelFee ? '0' : channelFeeController.text,
    );
    return await api.openChannel(params);
  }
}
