import 'package:firebolt/buttons.dart';
import 'package:firebolt/main.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../NodeConfig/node_config.dart';

class NodeSettings extends StatelessWidget {
  NodeSettings({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  final Map<String, String> _formFieldData = {
    'Nickname (optional)': 'Nody_Montana',
    'Node interface': 'lnd',
    'Host': 'https://...',
    'REST Port': '8080',
    'Macaroon (Hex format)': '020103...',
  };

  List<Widget> getTextFields() {
    List<Widget> formWidgets = [];
    for (int i = 0; i < _formFieldData.length; i++) {
      formWidgets.add(
        TextFormField(
          cursorColor: AppColors.white,
          decoration: InputDecoration(
              label: Text(
                _formFieldData.keys.toList()[i],
                style: const TextStyle(color: AppColors.grey),
              ),
              border: const UnderlineInputBorder(),
              hintStyle: const TextStyle(color: AppColors.orange),
              hintText: _formFieldData.values.toList()[i]),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
          ),
        ),
      );
    }

    return formWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Node Configuration'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 19, 0, 0),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.25,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Divider(),
                    ...getTextFields(),
                    const Divider(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SquareButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.qr_code,
                          color: AppColors.white,
                        ),
                        label: const Text(
                          'Scan LNDConnect Config',
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SquareButton(
                        onPressed: () {
                          Navigator.pop(context, (route) => false);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.white,
                        ),
                        label: const Text('Delete Config Settings'),
                        width: double.infinity,
                        height: double.infinity,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SquareButton(
                        onPressed: () {
                          // if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Saved node settings!')),
                          );

                          NodeConfig.isConfigured = true;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FireBolt(),
                            ),
                          );
                          // }
                        },
                        icon: const Icon(
                          Icons.save,
                          color: AppColors.white,
                        ),
                        label: const Text('Save Settings'),
                        width: double.infinity,
                        height: double.infinity,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
