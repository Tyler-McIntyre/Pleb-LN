import 'package:firebolt/UI/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../util/app_colors.dart';
import '../database/secure_storage.dart';
import '../models/lnd_connect.dart';
import 'Widgets/curve_clipper.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class NodeConfig extends StatefulWidget {
  const NodeConfig({Key? key}) : super(key: key);
  static late LNDConnect lndConnectParams;

  @override
  State<NodeConfig> createState() => _NodeConfigState();
}

class _NodeConfigState extends State<NodeConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redPrimary,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Node Configuration'),
        centerTitle: true,
      ),
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
  TextEditingController nicknameController = TextEditingController();
  TextEditingController nodeInterfaceController = TextEditingController();
  TextEditingController hostController = TextEditingController();
  TextEditingController restPortController = TextEditingController();
  TextEditingController macaroonController = TextEditingController();
  static bool useTorIsSwitched = false;
  late String qrCode;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    final String nickname = await SecureStorage.readValue('nickname') ?? '';
    final String nodeInterface =
        await SecureStorage.readValue('nodeInterface') ?? '';
    final String host = await SecureStorage.readValue('host') ?? '';
    final String restPort = await SecureStorage.readValue('restPort') ?? '';
    final String macaroon = await SecureStorage.readValue('macaroon') ?? '';

    setState(() {
      nicknameController.text = nickname;
      nodeInterfaceController.text = nodeInterface;
      hostController.text = host;
      restPortController.text = restPort;
      macaroonController.text = macaroon;
      //TODO: Add useTor here
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
              height: MediaQuery.of(context).size.height * .75,
              color: AppColors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Column(
                      children: [
                        //*Nickname (optional)
                        TextFormField(
                          controller: nicknameController,
                          cursorColor: AppColors.white,
                          decoration: const InputDecoration(
                            label: Text(
                              'Nickname (Optional)',
                              style: TextStyle(color: AppColors.white),
                            ),
                            border: UnderlineInputBorder(),
                            hintStyle: TextStyle(color: AppColors.grey),
                            hintText: 'Nody_Montana',
                          ),
                          style: const TextStyle(
                            color: AppColors.orange,
                            fontSize: 20,
                          ),
                        ),
                        //*Interface
                        TextFormField(
                          controller: nodeInterfaceController,
                          cursorColor: AppColors.white,
                          decoration: const InputDecoration(
                            label: Text(
                              'Node Interface',
                              style: TextStyle(color: AppColors.white),
                            ),
                            border: UnderlineInputBorder(),
                            hintStyle: TextStyle(color: AppColors.grey),
                            hintText: 'lnd',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your interface';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            color: AppColors.orange,
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
                              style: TextStyle(color: AppColors.white),
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
                            color: AppColors.orange,
                            fontSize: 20,
                          ),
                        ),
                        //*REST port
                        TextFormField(
                          controller: restPortController,
                          cursorColor: AppColors.white,
                          decoration: const InputDecoration(
                            label: Text(
                              'REST Port',
                              style: TextStyle(color: AppColors.white),
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
                            color: AppColors.orange,
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
                              style: TextStyle(color: AppColors.white),
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
                            color: AppColors.orange,
                            fontSize: 20,
                          ),
                        ),
                        //* Use Tor
                        SwitchListTile(
                          title: const Text(
                            'Use Tor',
                            style: TextStyle(
                              color: Colors.white,
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
                            color: Colors.white,
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
                top: MediaQuery.of(context).size.height * .65,
                right: 20.0,
                left: 20.0),
            child: SizedBox(
              height: 100.0,
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                child: NodeConfigButtonBar(),
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

  NodeConfigButtonBar() {
    Map<String, TextEditingController> configSettings = {
      'nickname': nicknameController,
      'nodeInterface': nodeInterfaceController,
      'host': hostController,
      'restPort': restPortController,
      'macaroon': macaroonController,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () async {
            //Scan the QRCode
            scanQrCode();
            String qrCodeResponse = qrCode;

            //TODO: Fix this error handling
            if (!qrCodeResponse.contains('Error')) {
              //Parse the raw data
              LNDConnect connectionParams =
                  await LNDConnect.parseConnectionString(qrCodeResponse);

              //set the controller text states
              setState(() {
                hostController.text = connectionParams.host ?? '';
                restPortController.text = connectionParams.port ?? '';
                macaroonController.text =
                    connectionParams.macaroonHexFormat ?? '';
              });
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(100, 71),
            primary: Colors.black,
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
                Icons.qr_code_scanner,
                color: AppColors.white,
              ),
              Text(
                'LNDConfig',
                style: TextStyle(color: Colors.white, fontSize: 17),
              )
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              nicknameController.clear();
              nodeInterfaceController.clear();
              hostController.clear();
              restPortController.clear();
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
              color: AppColors.redPrimary,
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              for (MapEntry<String, TextEditingController> entry
                  in configSettings.entries) {
                await SecureStorage.writeValue(entry.key, entry.value.text);
              }

              await SecureStorage.writeValue('isConfigured', 'true');
              //TODO: Save 'useTor' value here

              //TODO: Check if the save was successful and display the appropriate snackbar message
              //Show the snackbar
              const snackBar = SnackBar(
                content: Text(
                  'Node Saved!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                backgroundColor: (AppColors.blueSecondary),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              //Navigate home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(100, 71),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: const TextStyle(fontSize: 20),
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
