import 'dart:async';

import 'package:firebolt/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

import '../api/lnd.dart';
import '../constants/payment_status.dart';
import '../models/payment.dart';
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
    super.initState();
  }

  startTime() async {
    var duration = new Duration(seconds: 2);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context,
        PageTransition(
          alignment: Alignment.bottomCenter,
          child: DashboardScreen(),
          type: PageTransitionType.fade,
        ));
  }

  Future<PaymentStatus> _payLightningInvoice() async {
    LND api = LND();
    Payment payment = Payment(widget.invoice);
    PaymentStatus status =
        await api.payLightningInvoice(payment).then(((value) {
      return value;
    }));

    switch (status) {
      case (PaymentStatus.successful):
        return PaymentStatus.successful;
      case (PaymentStatus.invoice_already_paid):
        return PaymentStatus.invoice_already_paid;
      case (PaymentStatus.no_route):
        return PaymentStatus.no_route;
      default:
        return PaymentStatus.unknown;
    }
  }

  //* Used for testing the progress bar
  // Future<PaymentStatus> _getFutureBool() async {
  //   await Future.delayed(Duration(seconds: 5)).then((onValue) => true);
  //   return PaymentStatus.invoice_already_paid;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: _payLightningInvoice(),
      builder: (context, AsyncSnapshot<PaymentStatus> snapshot) {
        late Widget statusWidgets;

        if (snapshot.hasData) {
          bool success = false;
          late String message;
          PaymentStatus? status = snapshot.data;
          switch (status) {
            case (PaymentStatus.successful):
              message = PaymentStatus.successful.name;
              success = true;
              break;
            case (PaymentStatus.invoice_already_paid):
              message = 'This invoice has already been paid';
              break;
            case (PaymentStatus.no_route):
              message = 'No route available';
              break;
            default:
              message = 'An unknown error has occured';
              break;
          }

          startTime();

          statusWidgets = success
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Icon(
                        FontAwesomeIcons.circleCheck,
                        size: 50,
                        color: AppColors.green,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: 'Success',
                        children: [
                          TextSpan(text: '!'),
                        ],
                      ),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Icon(
                        FontAwesomeIcons.solidThumbsDown,
                        size: 50,
                        color: AppColors.red,
                      ),
                    ),
                    Text(
                      'Payment failed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('$message')
                  ],
                );
        } else if (snapshot.hasError) {
          statusWidgets = Column(
            children: [
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
            ],
          );
        } else {
          statusWidgets = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
          );
        }

        return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: Column(children: [
                    Expanded(child: Container()),
                    Expanded(
                        flex: 7,
                        child: Container(
                          child: Image.asset('images/Pleb-logos.jpeg'),
                        )),
                    Expanded(
                      flex: 4,
                      child: Container(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: statusWidgets,
                        ),
                      ),
                    ),
                    Expanded(child: Container())
                  ]),
                ),
              ],
            ));
      },
    ));
  }
}
