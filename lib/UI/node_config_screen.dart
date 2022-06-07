import '../constants/node_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import '../util/app_colors.dart';
import '../database/secure_storage.dart';
import '../models/lnd_connect.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'widgets/snackbars.dart';

class NodeConfigScreen extends StatefulWidget {
  const NodeConfigScreen({Key? key}) : super(key: key);
  static late LNDConnect lndConnectParams;

  @override
  State<NodeConfigScreen> createState() => _NodeConfigScreenState();
}

class _NodeConfigScreenState extends State<NodeConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: NodeConfigForm(),
    );
  }
}

class NodeConfigForm extends StatefulWidget {
  const NodeConfigForm({Key? key}) : super(key: key);

  @override
  State<NodeConfigForm> createState() => _NodeConfigFormState();
}

class _NodeConfigFormState extends State<NodeConfigForm> {
  static final _formKey = GlobalKey<FormState>();
  static bool useTorIsSwitched = false;
  late String qrCode;
  TextEditingController nicknameController = TextEditingController();
  TextEditingController nodeInterfaceController = TextEditingController();
  TextEditingController hostController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController macaroonController = TextEditingController();
  LNDConnect connectionParams = LNDConnect();
  late Map<String, TextEditingController> configSettings;
  final double _formSpacing = 12;
  ButtonState stateTextWithIcon = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    final String nickname =
        await SecureStorage.readValue(NodeSetting.nickname.name) ?? '';
    final String host =
        await SecureStorage.readValue(NodeSetting.host.name) ?? '';
    final String port =
        await SecureStorage.readValue(NodeSetting.grpcport.name) ?? '';
    final String macaroon =
        await SecureStorage.readValue(NodeSetting.macaroon.name) ?? '';
    final String useTor =
        await SecureStorage.readValue(NodeSetting.useTor.name) ?? 'false';

    setState(() {
      nicknameController.text = nickname;
      hostController.text = host;
      portController.text = port;
      macaroonController.text = macaroon;
      useTorIsSwitched = useTor.toLowerCase() == 'true' ? true : false;
      configSettings = {
        NodeSetting.nickname.name: nicknameController,
        NodeSetting.host.name: hostController,
        NodeSetting.grpcport.name: portController,
        NodeSetting.macaroon.name: macaroonController,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SizedBox(
                height: _formSpacing,
              ),
              _configFormFields(),
              SizedBox(
                height: _formSpacing,
              ),
              _buttonBar(),
            ],
          ),
        )
      ],
    );
  }

  _buttonBar() {
    return Column(
      children: [
        _scanLndConfigButton(),
        SizedBox(
          height: _formSpacing,
        ),
        _saveButton(),
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

  Widget _configFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nicknameController,
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Please enter a value';
              }
              return null;
            },
            decoration: InputDecoration(
              label: Text('Nickname'),
            ),
          ),
          SizedBox(
            height: _formSpacing,
          ),
          TextFormField(
            controller: hostController,
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Please enter a value';
              }
              return null;
            },
            decoration: InputDecoration(
              label: Text('Host'),
            ),
          ),
          SizedBox(
            height: _formSpacing,
          ),
          TextFormField(
            controller: portController,
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Please enter a value';
              }
              return null;
            },
            decoration: InputDecoration(
              label: Text('gRPC Port'),
            ),
          ),
          SizedBox(
            height: _formSpacing,
          ),
          TextFormField(
            controller: macaroonController,
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Please enter a value';
              }
              return null;
            },
            decoration: InputDecoration(
              label: Text('Macaroon'),
            ),
          ),
          SizedBox(
            height: _formSpacing,
          ),
          SwitchListTile(
            activeColor: AppColors.blue,
            title: Text('Use Tor'),
            value: useTorIsSwitched,
            onChanged: (bool value) {
              setState(() {
                useTorIsSwitched = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _saveUserSettings() async {
    String userTorSetting = 'false';
    if (useTorIsSwitched) {
      userTorSetting = 'true';
      connectionParams.useTor = true;
    }
    try {
      for (MapEntry<String, TextEditingController> entry
          in configSettings.entries) {
        await SecureStorage.writeValue(entry.key, entry.value.text);
      }
      await SecureStorage.writeValue(NodeSetting.useTor.name, userTorSetting);
      await SecureStorage.writeValue(NodeSetting.isConfigured.name, 'true');
      return true;
    } catch (ex) {
      await Snackbars.error(
          context, 'An error occured while saving the node configuration');

      return false;
    }
  }

  void _setConfigFormFields(String qrCodeRawData) async {
    if (!qrCode.isEmpty &&
        !qrCodeRawData.contains('Error') &&
        qrCodeRawData.isNotEmpty) {
      connectionParams = await LNDConnect.parseConnectionString(qrCodeRawData);

      if (connectionParams.host.isEmpty ||
          connectionParams.port.isEmpty ||
          connectionParams.macaroonHexFormat.isEmpty) {
        Snackbars.error(
          context,
          'Error parsing the LNDConfig',
        );
      } else {
        bool enableTor = false;
        if (connectionParams.host.contains('.onion')) {
          enableTor = true;
        }
        setState(() {
          hostController.text = connectionParams.host;
          portController.text = connectionParams.port;
          macaroonController.text = connectionParams.macaroonHexFormat;
          useTorIsSwitched = enableTor;
        });
      }
    }
  }

  _saveButton() {
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
              text: 'Save',
              icon: Icon(Icons.save),
              color: Colors.transparent,
            ),
            ButtonState.loading: IconedButton(
              text: 'Saving',
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
              switch (stateTextWithIcon) {
                case ButtonState.idle:
                  stateTextWithIcon = ButtonState.loading;
                  bool saveSuccessful = await _saveUserSettings();
                  Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      stateTextWithIcon = saveSuccessful
                          ? ButtonState.success
                          : ButtonState.fail;
                    });
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
          try {
            await scanQrCode();
          } catch (ex) {
            Snackbars.error(context, ex.toString());
          }
          String qrCodeRawData = qrCode;
          _setConfigFormFields(qrCodeRawData);
        },
        label: Text('LNDConfig'),
        style: ElevatedButton.styleFrom(
          elevation: 3,
          minimumSize: Size(double.infinity, 50),
          primary: Colors.transparent,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
