import 'package:firebolt/models/payment_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:money_formatter/money_formatter.dart';
import '../api/lnd.dart';
import '../util/app_colors.dart';
import 'Widgets/curve_clipper.dart';
import 'payment_splash_screen.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({Key? key}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  late String qrCode;
  final _formKey = GlobalKey<FormState>();
  TextEditingController invoiceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController memoController = TextEditingController();
  TextEditingController expiryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            ClipPath(
              clipper: CurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * .80,
                color: AppColors.black,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: [
                          Text(
                            'Enter the Lightning invoice you\'d like to pay',
                            style: Theme.of(context).textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 30.0),
                            child: TextFormField(
                              controller: invoiceController,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.paste,
                                      color: AppColors.orange,
                                    ),
                                    onPressed: () async {
                                      ClipboardData? clipboardData =
                                          await Clipboard.getData(
                                              Clipboard.kTextPlain);
                                      if (clipboardData!.text!.isNotEmpty) {
                                        print(
                                            'clipboard data: ${clipboardData.text!}');
                                        String invoice = clipboardData.text!;
                                        PaymentRequest payReq =
                                            await _decodePaymentRequest(
                                                invoice);
                                        _setConfigFormFields(payReq, invoice);
                                      }
                                    },
                                  ),
                                  focusedBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .focusedBorder,
                                  label: Text('Invoice',
                                      style: Theme.of(context)
                                          .inputDecorationTheme
                                          .labelStyle),
                                  hintText: 'lnbc20m1pvjl...'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          //Memo
                          TextFormField(
                            controller: amountController,
                            decoration: InputDecoration(
                              focusedBorder: Theme.of(context)
                                  .inputDecorationTheme
                                  .focusedBorder,
                              label: Text('Amount',
                                  style: Theme.of(context)
                                      .inputDecorationTheme
                                      .labelStyle),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0),
                            child: TextFormField(
                              enabled: false,
                              controller: memoController,
                              decoration: InputDecoration(
                                  focusedBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .focusedBorder,
                                  label: Text('Memo',
                                      style: Theme.of(context)
                                          .inputDecorationTheme
                                          .labelStyle),
                                  hintText: 'lnbc20m1pvjl...'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          //Expiry
                          TextFormField(
                            enabled: false,
                            controller: expiryController,
                            decoration: InputDecoration(
                                focusedBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .focusedBorder,
                                label: Text('Expires',
                                    style: Theme.of(context)
                                        .inputDecorationTheme
                                        .labelStyle),
                                hintText: 'lnbc20m1pvjl...'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
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
                  top: MediaQuery.of(context).size.height * .73,
                  right: 10.0,
                  left: 10.0),
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
      ),
    );
  }

  _buttonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () async {
            await scanQrCode();
            String invoice = qrCode;
            PaymentRequest payReq = await _decodePaymentRequest(invoice);
            _setConfigFormFields(payReq, invoice);
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
                'Scan',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              //TODO: reset all fields
              invoiceController.text = '';
              amountController.text = '';
              memoController.text = '';
              expiryController.text = '';
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentSplashScreen(
                            invoice: invoiceController.text,
                          )));
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
                Icons.send,
                color: AppColors.white,
              ),
              Text(
                'Send',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
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

  void _setConfigFormFields(PaymentRequest paymentRequest, String invoice) {
    String amount = paymentRequest.num_satoshis;

    setState(() {
      invoiceController.text = invoice;
      amountController.text = '${MoneyFormatter(
        amount: int.parse(amount).toDouble(),
      ).output.withoutFractionDigits}';
      memoController.text = paymentRequest.description;
      expiryController.text = paymentRequest.expiry;
    });
  }

  Future<PaymentRequest> _decodePaymentRequest(String qrCodeRawData) async {
    LND api = LND();
    PaymentRequest payReq = await api.decodePaymentRequest(qrCodeRawData);
    return payReq;
  }
}
