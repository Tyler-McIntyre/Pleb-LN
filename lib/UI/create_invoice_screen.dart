import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import 'invoice_screen.dart';
import 'package:fixnum/fixnum.dart';

import 'widgets/snackbars.dart';

class CreateInvoice extends StatefulWidget {
  const CreateInvoice({Key? key}) : super(key: key);

  @override
  State<CreateInvoice> createState() => _CreateInvoiceState();
}

class _CreateInvoiceState extends State<CreateInvoice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CreateInvoiceForm(),
    );
  }
}

class CreateInvoiceForm extends StatefulWidget {
  const CreateInvoiceForm({Key? key}) : super(key: key);

  @override
  State<CreateInvoiceForm> createState() => _CreateInvoiceFormState();
}

class _CreateInvoiceFormState extends State<CreateInvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  int _currentHourValue = 0;
  int _currentMinutesValue = 0;
  String _minutesLabel = 'Minutes';
  String _hoursLabel = 'Hours';
  bool _useDefaultExpiry = true;
  TextEditingController memoController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController expirationController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //*Memo
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: memoController,
                        cursorColor: AppColors.white,
                        decoration: InputDecoration(
                          focusedBorder: Theme.of(context)
                              .inputDecorationTheme
                              .focusedBorder,
                          label: Text(
                            'Memo',
                            style: Theme.of(context)
                                .inputDecorationTheme
                                .labelStyle,
                          ),
                          border: UnderlineInputBorder(),
                          hintStyle: TextStyle(color: AppColors.grey),
                          hintText: 'A Satoshi for your thoughts?',
                        ),
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    //*Amount
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: amountController,
                        cursorColor: AppColors.white,
                        decoration: InputDecoration(
                          focusedBorder: Theme.of(context)
                              .inputDecorationTheme
                              .focusedBorder,
                          label: Text.rich(
                            TextSpan(
                              text: 'Amount ',
                              style: Theme.of(context)
                                  .inputDecorationTheme
                                  .labelStyle,
                              children: [
                                TextSpan(
                                    text: '(sats)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
                              ],
                            ),
                          ),
                          border: UnderlineInputBorder(),
                          hintStyle: TextStyle(color: AppColors.grey),
                          hintText: '0',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    //*Expiration
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Expiration',
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                          SwitchListTile(
                              title: Text.rich(
                                TextSpan(
                                  text: 'Use default ',
                                  children: [
                                    TextSpan(
                                        text: ' = 1 hour',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall)
                                  ],
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              activeColor: AppColors.blue,
                              value: _useDefaultExpiry,
                              onChanged: (value) {
                                setState(() {
                                  _useDefaultExpiry = value;
                                });
                              }),
                          _useDefaultExpiry
                              ? SizedBox.shrink()
                              : _showExpirationNumberPicker(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .63,
                right: 20.0,
                left: 20.0),
            child: SizedBox(
              height: 100.0,
              width: MediaQuery.of(context).size.width,
              // child: SizedBox(
              //   child: CreateInvoiceButtonBar(),
              // ),
            ),
          )
        ],
      ),
    );
  }

  CreateInvoiceButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              memoController.clear();
              amountController.clear();
              expirationController.clear();
              _currentHourValue = 0;
              _currentMinutesValue = 0;
            });
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(150, 71),
            primary: AppColors.blue,
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
              if (!_useDefaultExpiry &&
                  _currentHourValue == 0 &&
                  _currentMinutesValue == 0) {
                Snackbars.invalid(context, 'expiration');
              } else {
                AddInvoiceResponse invoice = await _createInvoice();
                if (invoice.hasRHash()) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvoiceScreen(
                          invoice: invoice,
                        ),
                      ));
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(150, 71),
            primary: AppColors.blue,
            onPrimary: AppColors.white,
            textStyle: const TextStyle(fontSize: 20),
            side: BorderSide(
              color: AppColors.grey,
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
              Text('Create', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _showExpirationNumberPicker() {
    //Hours
    return Row(
      children: [
        NumberPicker(
          value: _currentHourValue,
          minValue: 0,
          maxValue: 72,
          textStyle: TextStyle(color: AppColors.white),
          selectedTextStyle: TextStyle(color: AppColors.grey, fontSize: 25),
          onChanged: (value) {
            setState(() {
              value == 1 ? _hoursLabel = 'Hour' : _hoursLabel = 'Hours';
              _currentHourValue = value;
            });
          },
        ),
        Text(
          _hoursLabel,
          style: TextStyle(color: AppColors.white),
        ),
        //Minutes
        NumberPicker(
          value: _currentMinutesValue,
          minValue: 0,
          maxValue: 60,
          textStyle: TextStyle(color: AppColors.white),
          selectedTextStyle: TextStyle(color: AppColors.grey, fontSize: 25),
          onChanged: (value) {
            setState(() {
              value == 1 ? _minutesLabel = 'Minute' : _minutesLabel = 'Minutes';
              _currentMinutesValue = value;
            });
          },
        ),
        Text(
          _minutesLabel,
          style: TextStyle(color: AppColors.white),
        )
      ],
    );
  }

  Future<AddInvoiceResponse> _createInvoice() async {
    String expirySeconds;
    _useDefaultExpiry
        ? expirySeconds = '3600'
        : expirySeconds =
            ((_currentHourValue * 3600) + (_currentMinutesValue * 60))
                .toString();

    LND rpc = LND();
    AddInvoiceResponse invoice;
    try {
      invoice = await rpc.createInvoice(
        Int64.parseInt(amountController.text),
        memoController.text,
        Int64.parseInt(expirySeconds),
      );
    } catch (ex) {
      Snackbars.error(
        context,
        ex.toString(),
      );
      throw (ex);
    }

    return invoice;
  }
}
