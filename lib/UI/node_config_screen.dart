import 'dart:developer';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:firebolt/constants/node_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/node_interface.dart';
import '../util/app_colors.dart';
import '../database/secure_storage.dart';
import '../models/lnd_connect.dart';
import 'Widgets/curve_clipper.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
      appBar: AppBar(),
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

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    final String nodeInterface = NodeInterface.LND.name;
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
      nodeInterfaceController.text = nodeInterface;
      hostController.text = host;
      portController.text = port;
      macaroonController.text = macaroon;
      useTorIsSwitched = useTor.toLowerCase() == 'true' ? true : false;
      configSettings = {
        NodeSetting.nickname.name: nicknameController,
        NodeInterface.LND.name: nodeInterfaceController,
        NodeSetting.host.name: hostController,
        NodeSetting.grpcport.name: portController,
        NodeSetting.macaroon.name: macaroonController,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stack(
        children: [
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * .83,
              color: AppColors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Column(
                      children: _configFormFields(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .75,
                right: 5.0,
                left: 5.0),
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

  _configFormFields() {
    return [
      //*Nickname (optional)
      TextFormField(
        controller: nicknameController,
        decoration: InputDecoration(
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            label: Text.rich(
              TextSpan(
                  text: 'Nickname ',
                  children: [
                    TextSpan(
                      text: '(Optional)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                  style: Theme.of(context).inputDecorationTheme.labelStyle),
            ),
            hintText: 'Nody_Montana'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      //*Interface
      TextFormField(
        enabled: false,
        controller: nodeInterfaceController,
        decoration: InputDecoration(
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
          label: Text.rich(
            TextSpan(
                text: 'Node Interface ',
                children: [
                  TextSpan(
                      text: '(V0.1.0 supports LND only)',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
                style: Theme.of(context).inputDecorationTheme.labelStyle),
          ),
          border: UnderlineInputBorder(),
          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
          hintText: 'Nody_Montana',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your nodes interface';
          }
          return null;
        },
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      //*Host
      TextFormField(
        controller: hostController,
        decoration: InputDecoration(
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
          label: Text('Host',
              style: Theme.of(context).inputDecorationTheme.labelStyle),
          border: UnderlineInputBorder(),
          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
          hintText: 'https://...',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the host';
          }
          return null;
        },
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      //*Port
      TextFormField(
        controller: portController,
        decoration: InputDecoration(
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
          label: Text(
            'gRPC Port',
            style: Theme.of(context).inputDecorationTheme.labelStyle,
          ),
          border: UnderlineInputBorder(),
          hintStyle: TextStyle(color: AppColors.grey),
          hintText: '10009',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the gRPC port';
          }
          return null;
        },
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      //*Macaroon
      TextFormField(
          controller: macaroonController,
          decoration: InputDecoration(
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            label: Text.rich(TextSpan(
              text: 'Macaroon ',
              children: [
                TextSpan(
                  text: '(Hex Format)',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
              style: Theme.of(context).inputDecorationTheme.labelStyle,
            )),
            border: UnderlineInputBorder(),
            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
            hintText: '020103...',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the macaroon in hex format';
            }
            return null;
          },
          style: Theme.of(context).textTheme.bodyMedium),
      //* Use Tor
      SwitchListTile(
        activeColor: AppColors.blue,
        title: Text(
          'Use Tor',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        value: useTorIsSwitched,
        onChanged: (bool value) {
          setState(() {
            useTorIsSwitched = value;
          });
        },
        secondary: const Icon(
          Icons.private_connectivity,
          color: AppColors.white,
        ),
      )
    ];
  }

  _buttonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () async {
            await scanQrCode();
            String qrCodeRawData = qrCode;
            _setConfigFormFields(qrCodeRawData);
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
                'LNDConfig',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              //reset form fields
              nicknameController.clear();
              hostController.clear();
              portController.clear();
              macaroonController.clear();
              useTorIsSwitched = false;
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
              bool saveWasSuccessful = await saveUserSettings();

              if (saveWasSuccessful) {
                /* TODO:
                Attempt to make a valid connection,
                if we are unable to make a successful connection
                display an error to the user with more details
                */
                //Navigate home
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              } else {
                final snackBar = SnackBar(
                  content: Text(
                    'An error occured while trying to save the settings',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  backgroundColor: (AppColors.red),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
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
                Icons.save,
                color: AppColors.white,
              ),
              Text(
                'Save',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> saveUserSettings() async {
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
      log('An error occured while saving the node configuration');
      return false;
    }
  }

  void _setConfigFormFields(String qrCodeRawData) async {
    //TODO: Fix this error handling
    if (!qrCode.isEmpty && !qrCodeRawData.contains('Error')) {
      connectionParams = await LNDConnect.parseConnectionString(qrCodeRawData);

      //TODO: Move to a function?
      if (connectionParams.host.isEmpty ||
          connectionParams.port.isEmpty ||
          connectionParams.macaroonHexFormat.isEmpty) {
        //Show the snackbar
        final snackBar = SnackBar(
          content: Text(
            'Error parsing the LNDConfig',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: (AppColors.red),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        bool enableTor = false;
        if (connectionParams.host.contains('.onion')) {
          enableTor = true;
        }
        //set the controller text states
        setState(() {
          hostController.text = connectionParams.host;
          portController.text = connectionParams.port;
          macaroonController.text = connectionParams.macaroonHexFormat;
          useTorIsSwitched = enableTor;
        });
      }
    }
  }
}
