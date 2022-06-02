import 'dart:async';
import 'package:firebolt/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import '../generated/lightning.pb.dart';
import '../generated/router.pbgrpc.dart';
import '../rpc/lnd.dart';
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

  startTime(Duration duration, Function() route) async {
    Duration duration = new Duration(seconds: 2);
    return new Timer(duration, route);
  }

  HomeRoute() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        alignment: Alignment.bottomCenter,
        child: DashboardScreen(),
        type: PageTransitionType.fade,
      ),
    );
  }

  payScreenRoute() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        alignment: Alignment.bottomCenter,
        child: DashboardScreen(),
        type: PageTransitionType.fade,
      ),
    );
  }

  Future<Payment> _payLightningInvoice() async {
    LND rpc = LND();
    SendPaymentRequest sendRequest = SendPaymentRequest(
      paymentRequest: widget.invoice,
      timeoutSeconds: 20,
    );
    Payment payment;

    payment = await rpc.sendPaymentV2(sendRequest);
    print('in the splash screen: ${payment.status}');

    return payment;
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
      builder: (context, AsyncSnapshot<Payment> snapshot) {
        late Widget statusWidgets;

        if (snapshot.hasData) {
          bool success = false;
          late String message;
          Payment_PaymentStatus status = snapshot.data!.status;

          switch (status) {
            case (Payment_PaymentStatus.SUCCEEDED):
              message = Payment_PaymentStatus.SUCCEEDED.name;
              success = true;
              break;
            case (Payment_PaymentStatus.FAILED):
              message = snapshot.data!.failureReason.toString();
              break;
            default:
              message = snapshot.data!.failureReason.toString();
              break;
          }
          Duration successDuration = Duration(seconds: 5);
          startTime(successDuration, HomeRoute);

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
                    Text('$message'),
                  ],
                );
        } else if (snapshot.hasError) {
          Duration errorDuration = Duration(seconds: 7);
          startTime(errorDuration, payScreenRoute);
          String message =
              snapshot.error.toString().replaceAll('Exception:', '');
          statusWidgets = Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).errorColor,
                  size: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  '$message',
                  style: TextStyle(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
              ),
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

        return Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width / 1.1,
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
              )),
        );
      },
    ));
  }
}
