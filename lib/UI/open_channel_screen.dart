import 'package:convert/convert.dart';
import 'package:firebolt/models/open_channel.dart';
import 'package:firebolt/models/open_channel_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../api/lnd.dart';
import '../util/app_colors.dart';
import 'Widgets/curve_clipper.dart';
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
  TextEditingController channelFeeController = TextEditingController();
  TextEditingController minConfsController = TextEditingController();
  TextEditingController nodeAliasController = TextEditingController();
  bool _useDefaultChannelFee = true;
  bool _privateChannel = false;
  bool _useDefaultMinConf = true;
  InfoDialog dialog = InfoDialog();

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _openChannelForm(),
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
              nodeAliasController.text = '';
              nodePubkeyController.text = '';
              fundingAmountController.text = '';
              channelFeeController.text = '';
              minConfsController.text = '';
              _useDefaultChannelFee = true;
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
              //? Should we either navigate to success splash screen or display error within form?
              await _openChannel();
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
    LND api = LND();
    OpenChannel params = OpenChannel(
      _privateChannel,
      fundingAmountController.text,
      hex.decode(nodePubkeyController.text),
      satPerVbyte: _useDefaultChannelFee ? '0' : channelFeeController.text,
      minConfs: int.parse(minConfsController.text),
    );
    return await api.openChannel(params);
  }

  _openChannelForm() {
    return [
      TextFormField(
        controller: nodeAliasController,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                Icons.info_outline,
                color: AppColors.blue,
              ),
              onPressed: () async {
                String body = dialog.blurbs[DialogType.OpenChannelNodeAlias]!;
                await dialog.showMyDialog(body, context);
              },
            ),
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            label: Text.rich(
              TextSpan(
                  text: 'Node alias',
                  children: [
                    TextSpan(
                        text: ' (Optional)',
                        style: Theme.of(context).textTheme.displaySmall),
                  ],
                  style: Theme.of(context).inputDecorationTheme.labelStyle),
            ),
            hintText: 'My neighbor...'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      TextFormField(
        controller: nodePubkeyController,
        decoration: InputDecoration(
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
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            label: Text('Node pubkey',
                style: Theme.of(context).inputDecorationTheme.labelStyle),
            hintText: '03f0ba19fd88e...'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      //Funding Amount
      TextFormField(
        controller: fundingAmountController,
        decoration: InputDecoration(
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
          label: Text('Funding Amount',
              style: Theme.of(context).inputDecorationTheme.labelStyle),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      //min confirmations
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 8),
        child: SwitchListTile(
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
                  String body = dialog.blurbs[DialogType.MinimumConfirmations]!;
                  await dialog.showMyDialog(body, context);
                },
              )
            ],
          ),
          subtitle: _useDefaultMinConf
              ? Text(
                  'Default = 3 confirmations',
                  style: Theme.of(context).textTheme.displaySmall,
                )
              : TextFormField(
                  controller: minConfsController,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      focusedBorder:
                          Theme.of(context).inputDecorationTheme.focusedBorder,
                      hintText: '...'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
        ),
      ),
      //Channel Fee
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        onChanged: ((value) {
          setState(() {
            _useDefaultChannelFee = value;
          });
        }),
        value: _useDefaultChannelFee,
        title: Row(
          children: [
            Text(
              'Channel fee',
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
        subtitle: _useDefaultChannelFee
            ? Text(
                'Default = 0 sats per vbyte',
                style: Theme.of(context).textTheme.displaySmall,
              )
            : TextFormField(
                controller: channelFeeController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    focusedBorder:
                        Theme.of(context).inputDecorationTheme.focusedBorder,
                    hintText: '...'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
      ),
      //Private channel
      SwitchListTile(
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
    ];
  }
}
