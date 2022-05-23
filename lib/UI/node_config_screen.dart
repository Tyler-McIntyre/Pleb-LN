import 'dart:developer';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
            child: Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(
                  context,
                )),
      ),
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
    final String nodeInterface = 'LND';
    final String nickname = await SecureStorage.readValue('nickname') ?? '';
    final String host = await SecureStorage.readValue('host') ?? '';
    final String port = await SecureStorage.readValue('restPort') ?? '';
    final String macaroon = await SecureStorage.readValue('macaroon') ?? '';
    final String useTor = await SecureStorage.readValue('useTor') ?? 'false';

    setState(() {
      nicknameController.text = nickname;
      nodeInterfaceController.text = nodeInterface;
      hostController.text = host;
      portController.text = port;
      macaroonController.text = macaroon;
      useTorIsSwitched = useTor.toLowerCase() == 'true' ? true : false;
      configSettings = {
        'nickname': nicknameController,
        'nodeInterface': nodeInterfaceController,
        'host': hostController,
        'restPort': portController,
        'macaroon': macaroonController,
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
              height: MediaQuery.of(context).size.height * .73,
              color: AppColors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
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
                top: MediaQuery.of(context).size.height * .65,
                right: 20.0,
                left: 20.0),
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
        cursorColor: AppColors.white,
        decoration: InputDecoration(
          label: Text.rich(
            TextSpan(
              text: 'Nickname ',
              children: [
                TextSpan(
                  text: '(Optional)',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
              style: TextStyle(
                color: AppColors.greySecondary,
                fontSize: 21,
              ),
            ),
          ),
        ),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
        ),
      ),
      //*Interface
      TextFormField(
        enabled: false,
        controller: nodeInterfaceController,
        cursorColor: AppColors.white,
        decoration: const InputDecoration(
          label: Text.rich(
            TextSpan(
              text: 'Node Interface ',
              children: [
                TextSpan(
                  text: '(V0.1.0 supports LND only)',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
              style: TextStyle(
                color: AppColors.greySecondary,
                fontSize: 21,
              ),
            ),
          ),
          border: UnderlineInputBorder(),
          hintStyle: TextStyle(color: AppColors.grey),
          hintText: 'Nody_Montana',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your nodes interface';
          }
          return null;
        },
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
        ),
      ),
      //*Host
      TextFormField(
        controller: hostController,
        cursorColor: AppColors.white,
        decoration: const InputDecoration(
          label: Text(
            'Host',
            style: TextStyle(color: AppColors.greySecondary),
          ),
          border: UnderlineInputBorder(),
          hintStyle: TextStyle(color: AppColors.grey),
          hintText: 'https://...',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the host';
          }
          return null;
        },
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
        ),
      ),
      //*REST port
      TextFormField(
        controller: portController,
        cursorColor: AppColors.white,
        decoration: const InputDecoration(
          label: Text(
            'REST Port',
            style: TextStyle(color: AppColors.greySecondary),
          ),
          border: UnderlineInputBorder(),
          hintStyle: TextStyle(color: AppColors.grey),
          hintText: '8080',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the REST port';
          }
          return null;
        },
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
        ),
      ),
      //*Macaroon
      TextFormField(
        controller: macaroonController,
        cursorColor: AppColors.white,
        decoration: const InputDecoration(
          label: Text(
            'Macaroon (Hex Format)',
            style: TextStyle(color: AppColors.greySecondary),
          ),
          border: UnderlineInputBorder(),
          hintStyle: TextStyle(color: AppColors.grey),
          hintText: '020103...',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the macaroon in hex format';
          }
          return null;
        },
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
        ),
      ),
      //* Use Tor
      //TODO: This should automatically switch to enabled if tor is detected in the host URL after scanning the config
      SwitchListTile(
        activeColor: AppColors.blue,
        title: const Text(
          'Use Tor',
          style: TextStyle(
            color: AppColors.white,
          ),
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
            onPrimary: AppColors.white,
            textStyle: const TextStyle(fontSize: 20),
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
            children: const [
              Icon(
                Icons.qr_code_scanner,
                color: AppColors.white,
              ),
              Text(
                'LNDConfig',
                style: TextStyle(color: AppColors.white, fontSize: 17),
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
            children: const [
              Icon(
                Icons.restore,
                color: AppColors.white,
              ),
              Text(
                'Reset',
                style: TextStyle(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              bool saveWasSuccessful = await saveUserSettings();

              if (saveWasSuccessful) {
                const snackBar = SnackBar(
                  content: Text(
                    'Node Saved!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  backgroundColor: (AppColors.orange),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                //Navigate home
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              } else {
                const snackBar = SnackBar(
                  content: Text(
                    'An error occured while trying to save the settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
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
            children: const [
              Icon(
                Icons.save,
                color: AppColors.white,
              ),
              Text(
                'Save',
                style: TextStyle(
                  color: AppColors.white,
                ),
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
      await SecureStorage.writeValue('useTor', userTorSetting);
      await SecureStorage.writeValue('isConfigured', 'true');
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
      if (connectionParams.host == '' ||
          connectionParams.port == '' ||
          connectionParams.macaroonHexFormat == '') {
        //Show the snackbar
        const snackBar = SnackBar(
          content: Text(
            'Error parsing the LNDConfig',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          backgroundColor: (AppColors.red),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        //set the controller text states
        setState(() {
          hostController.text = connectionParams.host;
          portController.text = connectionParams.port;
          macaroonController.text = connectionParams.macaroonHexFormat;
        });
      }
    }
  }
}
