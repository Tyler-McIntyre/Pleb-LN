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
  double _formSpacing = 12;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              Expanded(
                  child: ListView(
                children: [
                  SizedBox(
                    height: _formSpacing,
                  ),
                  _invoiceForm(),
                  SizedBox(
                    height: _formSpacing,
                  ),
                  _createInvoiceButtonBar()
                ],
              ))
            ],
          ),
        ));
  }

  _createInvoiceButtonBar() {
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
        icon: Icon(Icons.create),
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
        label: Text('Create'),
        style: ElevatedButton.styleFrom(
          elevation: 3,
          minimumSize: Size(double.infinity, 50),
          primary: Colors.transparent,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
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
          selectedTextStyle: TextStyle(color: AppColors.blue),
          onChanged: (value) {
            setState(() {
              value == 1 ? _hoursLabel = 'Hour' : _hoursLabel = 'Hours';
              _currentHourValue = value;
            });
          },
        ),
        Text(
          _hoursLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        //Minutes
        NumberPicker(
          value: _currentMinutesValue,
          minValue: 0,
          maxValue: 60,
          textStyle: TextStyle(color: AppColors.white),
          selectedTextStyle: TextStyle(color: AppColors.blue),
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
        ? expirySeconds = '10800'
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

  Widget _invoiceForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          //*Memo
          TextFormField(
            controller: memoController,
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              label: Text('Memo'),
              hintText: 'A Satoshi for your thoughts?',
            ),
          ),
          SizedBox(
            height: _formSpacing,
          ),
          //*Amount
          TextFormField(
            keyboardType: TextInputType.number,
            controller: amountController,
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              label: Text.rich(
                TextSpan(
                  text: 'Amount ',
                  children: [
                    TextSpan(
                        text: '(sats)',
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              hintText: '...',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              return null;
            },
          ),
          SizedBox(
            height: _formSpacing,
          ),
          //*Expiration
          Column(
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
                      children: [TextSpan(text: ' = 3 hours')],
                      style: Theme.of(context).textTheme.labelMedium,
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
                  : _showExpirationNumberPicker()
            ],
          ),
        ],
      ),
    );
  }
}
