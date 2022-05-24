import 'dart:async';

import 'package:firebolt/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api/lnd.dart';
import '../models/payment.dart';
import 'Constants/payment_status.dart';
import 'dashboard_screen.dart';

class PaymentSplashScreen extends StatefulWidget {
  const PaymentSplashScreen({Key? key, required this.invoice})
      : super(key: key);
  final String invoice;

  @override
  State<PaymentSplashScreen> createState() => _PaymentSplashScreenState();
}

class _PaymentSplashScreenState extends State<PaymentSplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  startTime() async {
    var duration = new Duration(seconds: 2);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashboardScreen()));
  }

  Future<String> _payLightningInvoice() async {
    LND api = LND();
    Payment payment = Payment(widget.invoice);
    late String errorMessage = '';
    PaymentStatus status =
        await api.payLightningInvoice(payment).then(((value) {
      return value;
    })).catchError((error) {
      errorMessage = error;
    });

    if (status == PaymentStatus.successful) {
      return PaymentStatus.successful.toString();
    } else {
      return errorMessage;
    }
  }

  //* Used for testing the progress bar
  // Future<String> _getFutureBool() async {
  //   await Future.delayed(Duration(seconds: 30)).then((onValue) => true);
  //   var result = PaymentStatus.successful.toString();
  //   return result;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: _payLightningInvoice(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        late Widget child;
        if (snapshot.hasData) {
          bool paymentWasSuccessful;
          snapshot.data == PaymentStatus.successful.toString()
              ? paymentWasSuccessful = true
              : paymentWasSuccessful = false;
          if (paymentWasSuccessful == true) {
            startTime();
          }
          child = Center(
            child: Container(
              color: AppColors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/Pleb-logos.jpeg'),
                  paymentWasSuccessful == true
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  FontAwesomeIcons.thumbsUp,
                                  size: 50,
                                  color: AppColors.green,
                                )),
                            Text(
                              'Success!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Icon(
                                FontAwesomeIcons.thumbsDown,
                                size: 50,
                                color: AppColors.red,
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: Text(
                                  'Payment failed: ${snapshot.data}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        )
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          child = Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(
                Icons.error_outline,
                color: Theme.of(context).errorColor,
                size: 40,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).errorColor),
                textAlign: TextAlign.center,
              ),
            )
          ]);
        } else {
          child = Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/Pleb-logos.jpeg'),
                Text(
                  'Routing payment...',
                  style: TextStyle(color: AppColors.white, fontSize: 35),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return child;
      },
    ));
  }
}
