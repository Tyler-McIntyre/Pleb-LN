import 'package:firebolt/main.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';

class NodeConfig extends StatelessWidget {
  NodeConfig({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  final Map<String, String> _formFieldData = {
    'Nickname (optional)': 'Nody_Montana',
    'Node interface': 'lnd',
    'Host': 'https://...',
    'REST Port': '8080',
    'Macaroon (Hex format)': '020103...',
  };

  static bool isConfigured = true;
  static String alias = 'Nody_Montana';

  List<Widget> getTextFields() {
    List<Widget> formWidgets = [];
    for (int i = 0; i < _formFieldData.length; i++) {
      formWidgets.add(
        TextFormField(
          cursorColor: AppColors.white,
          decoration: InputDecoration(
            label: Text(
              _formFieldData.keys.toList()[i],
              style: const TextStyle(color: AppColors.white),
            ),
            border: const UnderlineInputBorder(),
            hintStyle: const TextStyle(color: AppColors.grey),
            hintText: _formFieldData.values.toList()[i],
          ),
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
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Node Configuration'),
          centerTitle: true,
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Divider(),
                  ...getTextFields(),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.qr_code,
                          color: AppColors.white,
                        ),
                        label: const Text(
                          'Scan LNDConnect Config',
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          fixedSize: const Size(double.infinity, 50),
                          primary: Colors.black,
                          onPrimary: AppColors.white,
                          textStyle: const TextStyle(fontSize: 20),
                          side: const BorderSide(
                            color: AppColors.bluePrimary,
                            width: 1.0,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, (route) => false);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.white,
                        ),
                        label: const Text('Delete Config Settings'),
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          fixedSize: const Size(double.infinity, 50),
                          primary: Colors.black,
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
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved node settings!')),
                        );

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
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        fixedSize: const Size(double.infinity, 50),
                        primary: Colors.black,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
