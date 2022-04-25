import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../buttons.dart';

class SendWithLightning extends StatefulWidget {
  const SendWithLightning({Key? key}) : super(key: key);

  @override
  State<SendWithLightning> createState() => _SendWithLightningState();
}

class _SendWithLightningState extends State<SendWithLightning> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Container(
              color: AppColors.black,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Lightning payment request, Bitcoin address, keysend address (if enabled)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.grey),
                        ),
                        TextFormField(
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(
                              hintStyle: TextStyle(
                                  color: Color.fromARGB(255, 68, 68, 68)),
                              hintText: 'Inbc1...',
                              fillColor: AppColors.grey),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an address or scan a QR code';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RoundedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor:
                                            Color.fromRGBO(220, 25, 33, 1),
                                        content: Text('Scanning QR code!')),
                                  );
                                },
                                icon: const Icon(Icons.qr_code),
                                label: const Text('Scan'),
                                width: double.infinity,
                                fontSize: 25,
                              ),
                              RoundedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        elevation: 20,
                                        backgroundColor: AppColors.white,
                                        content: Text(
                                            'Sending Bitcoin on the lightning network!!!'),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.send),
                                label: const Text('Send'),
                                width: double.infinity,
                                fontSize: 25,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
