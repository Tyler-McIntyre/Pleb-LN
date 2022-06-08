import 'package:firebolt/UI/Widgets/qr_code_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import '../constants/payment_failure_message.dart';
import '../generated/lightning.pb.dart';
import '../generated/router.pb.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import '../util/formatting.dart';
import 'widgets/snackbars.dart';
import 'package:fixnum/fixnum.dart';

class PayInvoice extends StatefulWidget {
  const PayInvoice({Key? key}) : super(key: key);

  @override
  State<PayInvoice> createState() => _PayInvoiceState();
}

class _PayInvoiceState extends State<PayInvoice> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController invoiceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController memoController = TextEditingController();
  TextEditingController expiryController = TextEditingController();
  ButtonState stateTextWithIcon = ButtonState.idle;
  double _formSpacing = 12;
  bool nonZeroPayReq = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SizedBox(
                height: _formSpacing,
              ),
              _payForm(),
              SizedBox(
                height: _formSpacing,
              ),
              _buttonBar()
            ],
          ),
        )
      ],
    );
  }

  _buttonBar() {
    return Column(
      children: [
        _scanButton(),
        SizedBox(
          height: _formSpacing,
        ),
        _sendPaymentButton(),
      ],
    );
  }

  Future<Payment> _payLightningInvoice(
      String paymentRequest, Int64? amtSats) async {
    LND rpc = LND();
    SendPaymentRequest sendRequest = SendPaymentRequest(
      paymentRequest: paymentRequest,
      amt: amtSats != null ? amtSats : null,
      timeoutSeconds: 20,
    );
    Payment payment;

    payment = await rpc.sendPaymentV2(sendRequest);

    return payment;
  }

  _scanButton() {
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
          QrCodeHelper helper = QrCodeHelper();
          String data = await helper.scanQrCode(mounted);
          PayReq payReq = PayReq();
          try {
            if (data.isEmpty) return;
            payReq = await _decodePaymentRequest(data);
          } catch (ex) {
            await Snackbars.error(context, ex.toString());
          }
          _setConfigFormFields(payReq, data);
        },
        label: Text('Scan'),
        style: ElevatedButton.styleFrom(
          elevation: 3,
          minimumSize: Size(double.infinity, 50),
          primary: Colors.transparent,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }

  void _setConfigFormFields(PayReq? payReq, String invoice) {
    if (payReq != null) {
      String amount = payReq.numSatoshis.toString();

      int timestamp = payReq.timestamp.toInt();
      int expiryInSeconds = payReq.expiry.toInt();
      DateTime expirationDate =
          Formatting.getExpirationDate(timestamp, expiryInSeconds);
      if (!mounted) return;
      setState(() {
        amountController.text = '${MoneyFormatter(
          amount: int.parse(amount).toDouble(),
        ).output.withoutFractionDigits}';
        memoController.text = payReq.description;
        expiryController.text = expirationDate.toString();
        invoiceController.text = invoice;
      });
    }
  }

  Future<PayReq> _decodePaymentRequest(String qrCodeRawData) async {
    LND rpc = LND();
    PayReqString payReqStr = PayReqString();
    payReqStr.payReq = qrCodeRawData;
    PayReq payReq = await rpc.decodePaymentRequest(payReqStr);

    setState(() {
      nonZeroPayReq = payReq.numSatoshis > 0;
    });
    return payReq;
  }

  void _decodeClipboardData(String? pastedData) async {
    if (pastedData!.isNotEmpty) {
      PayReq payReq = await _decodePaymentRequest(pastedData);
      _setConfigFormFields(payReq, pastedData);
    }
  }

  _payForm() {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          children: [
            TextFormField(
              validator: ((value) {
                if (value != null && value.isEmpty) {
                  return 'Please enter an invoice';
                }
                return null;
              }),
              controller: invoiceController,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.paste,
                      color: AppColors.grey,
                    ),
                    onPressed: () async {
                      ClipboardData? clipboardData;
                      try {
                        clipboardData =
                            await Clipboard.getData(Clipboard.kTextPlain);

                        String? pastedData = clipboardData!.text;
                        _decodeClipboardData(pastedData);
                      } catch (ex) {
                        await Snackbars.error(context, ex.toString());
                      }
                    },
                  ),
                  label: Text('Invoice'),
                  hintText: 'lnbc20m1pvjl...'),
            ),
            SizedBox(
              height: _formSpacing,
            ),
            //Memo
            TextFormField(
              controller: amountController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                } else if (int.tryParse(value) == false) {
                  return 'Inavlid amount';
                } else if (int.parse(value.replaceAll(',', '')) <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(label: Text('Amount'), hintText: '...'),
            ),
            SizedBox(
              height: _formSpacing,
            ),
            TextFormField(
              enabled: false,
              controller: memoController,
              decoration: InputDecoration(label: Text('Memo')),
            ),
            SizedBox(
              height: _formSpacing,
            ),
            //Expiry
            TextFormField(
              enabled: false,
              controller: expiryController,
              decoration: InputDecoration(label: Text('Expires')),
            ),
            SizedBox(
              height: _formSpacing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendPaymentButton() {
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
              text: 'Send',
              icon: Icon(Icons.send),
              color: Colors.transparent,
            ),
            ButtonState.loading: IconedButton(
              text: 'Sending',
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
              Payment response = Payment();
              switch (stateTextWithIcon) {
                case ButtonState.idle:
                  stateTextWithIcon = ButtonState.loading;
                  bool successfulPayment = false;
                  try {
                    Int64 amtSats = Int64.parseInt(
                      amountController.text.replaceAll(',', ''),
                    );

                    response = await _payLightningInvoice(
                        invoiceController.text, nonZeroPayReq ? null : amtSats);
                    successfulPayment =
                        response.status == Payment_PaymentStatus.SUCCEEDED
                            ? true
                            : false;

                    Future.delayed(Duration(seconds: 1), () async {
                      setState(() {
                        stateTextWithIcon = successfulPayment
                            ? ButtonState.success
                            : ButtonState.fail;
                      });
                    });

                    if (!successfulPayment) {
                      await Snackbars.error(
                        context,
                        PaymentFailure.getMessage(response.failureReason),
                      );
                    }
                  } catch (ex) {
                    await Snackbars.error(
                      context,
                      ex.toString(),
                    );

                    successfulPayment = false;
                  }

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
                  if (stateTextWithIcon == ButtonState.success) {
                    invoiceController.text = '';
                    amountController.text = '';
                    memoController.text = '';
                    expiryController.text = '';
                  }
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
}
