import '../UI/Widgets/qr_code_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/node_setting.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import '../generated/lightning.pb.dart';
import '../models/settings.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import '../database/secure_storage.dart';
import '../models/lnd_connect.dart';
import 'widgets/snackbars.dart';

class NodeConfigScreen extends ConsumerWidget {
  NodeConfigScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: NodeConfigForm(
            ref: ref,
          ),
        ));
  }
}

class NodeConfigForm extends StatefulWidget {
  const NodeConfigForm({
    Key? key,
    required this.ref,
  }) : super(key: key);
  final WidgetRef ref;

  @override
  State<NodeConfigForm> createState() => _NodeConfigFormState();
}

class _NodeConfigFormState extends State<NodeConfigForm> {
  final _formKey = GlobalKey<FormState>();
  static bool useTorIsSwitched = false;
  TextEditingController aliasController = TextEditingController();
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
    final String alias =
        await SecureStorage.readValue(NodeSetting.alias.name) ?? '';
    final String host =
        await SecureStorage.readValue(NodeSetting.host.name) ?? '';
    final String port =
        await SecureStorage.readValue(NodeSetting.grpcport.name) ?? '';
    final String macaroon =
        await SecureStorage.readValue(NodeSetting.macaroon.name) ?? '';
    final String useTor =
        await SecureStorage.readValue(NodeSetting.useTor.name) ?? 'false';

    setState(() {
      aliasController.text = alias;
      hostController.text = host;
      portController.text = port;
      macaroonController.text = macaroon;
      useTorIsSwitched = useTor.toLowerCase() == 'true' ? true : false;
      configSettings = {
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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

  Widget _buttonBar() {
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

  Widget _configFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: aliasController,
            decoration: InputDecoration(
              enabled: false,
              label: Text('Alias'),
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

  void _setConfigFormFields(String data) async {
    if (data.isEmpty || data.toLowerCase().contains('error') || data == '-1')
      return;

    try {
      connectionParams = LNDConnect.parseConnectionString(data);

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
    } catch (ex) {
      await Snackbars.error(
        context,
        ex.toString(),
      );
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
                  bool saveSuccesful = false;
                  bool fetchSuccessful = false;

                  Settings settings = Settings(
                      hostController.text,
                      portController.text,
                      macaroonController.text,
                      useTorIsSwitched);
                  String nodeAlias = '';
                  try {
                    saveSuccesful =
                        await SecureStorage.saveUserSettings(settings);
                    nodeAlias = await _fetchAndSaveNodeInfo();
                    fetchSuccessful = await LND.fetchEssentialData(widget.ref);
                    if (saveSuccesful && fetchSuccessful) {
                      await SecureStorage.writeValue(
                        NodeSetting.isConfigured.name,
                        'true',
                      );
                    }
                  } catch (ex) {
                    await Snackbars.error(context, ex.toString());
                  }

                  if (saveSuccesful) {
                    setState(() {
                      aliasController.text = nodeAlias;
                    });
                  }

                  Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      stateTextWithIcon = (saveSuccesful && fetchSuccessful)
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
          String data = '';
          try {
            QrCodeHelper helper = QrCodeHelper();
            data = await helper.scanQrCode(mounted);
          } catch (ex) {
            Snackbars.error(context, ex.toString());
          }

          if (data.isEmpty) return;
          _setConfigFormFields(data);
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

  Future<String> _fetchAndSaveNodeInfo() async {
    LND rpc = LND();
    GetInfoResponse nodeInfo = await rpc.getInfo();
    await SecureStorage.writeValue(
      NodeSetting.alias.name,
      nodeInfo.alias,
    );
    return nodeInfo.alias;
  }
}
