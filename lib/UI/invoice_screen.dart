import '../UI/Widgets/qr_code_helper.dart';
import '../UI/dashboard_screen.dart';
import '../generated/lightning.pb.dart';
import '../util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/images.dart';
import '../rpc/lnd.dart';
import '../util/clipboard_helper.dart';
import 'Widgets/qr_code_helper.dart';
import 'package:fixnum/fixnum.dart';
import 'widgets/future_builder_widgets.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);
  final AddInvoiceResponse invoice;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  late QrImage _qrImage;
  TextEditingController _paymentRequestController = TextEditingController();
  double _formSpacing = 12;
  late Future<bool> _init;
  late AnimationController _controller;
  bool invoiceWasPaid = false;

  @override
  void initState() {
    _init = _initInvoice();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              tabIndex: 2,
            ),
          ),
        );
      }
    });
    super.initState();
  }

  Future<bool> _initInvoice() async {
    String paymentRequest = widget.invoice.paymentRequest;
    this._qrImage = QrCodeHelper.createQrImage(paymentRequest);
    _paymentRequestController.text = paymentRequest;
    Int64 addIndex = widget.invoice.addIndex;
    _invoiceSubscription(addIndex);
    return true;
  }

  Future<void> _invoiceSubscription(Int64 addIndex) async {
    LND rpc = LND();
    InvoiceSubscription invoiceSubscription =
        InvoiceSubscription(addIndex: addIndex);
    Invoice response = await rpc.invoiceSubscription(invoiceSubscription);
    if (response.amtPaidSat > 0) {
      if (!mounted) return;
      setState(() {
        invoiceWasPaid = true;
      });
    }
  }

  @override
  void dispose() {
    _paymentRequestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              leading: Image.asset(
                Images.whitePlebLogo,
              ),
            ),
            body: invoiceWasPaid
                ? Lottie.asset(
                    'animations/blue-checkmark.json',
                    controller: _controller,
                    frameRate: FrameRate.max,
                    onLoaded: (composition) {
                      _controller.duration = composition.duration;
                      _controller.forward();
                    },
                  )
                : FutureBuilder(
                    future: _init,
                    builder: ((context, snapshot) {
                      Widget child;
                      if (snapshot.hasData) {
                        child = Column(
                          children: [
                            Text(
                              'Scan',
                              style: TextStyle(color: AppColors.white),
                            ),
                            SizedBox(
                              height: _formSpacing,
                            ),
                            _invoiceHashAndCode(),
                            SizedBox(
                              height: _formSpacing,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'or',
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: _formSpacing,
                            ),
                            _backToDashboardButton(),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        child = FutureBuilderWidgets.error(
                            context, snapshot.error.toString());
                      } else {
                        child = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilderWidgets.circularProgressIndicator(),
                          ],
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: child),
                        ],
                      );
                    }))));
  }

  Widget _invoiceHashAndCode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _qrImage,
        ),
        TextField(
          readOnly: true,
          controller: _paymentRequestController,
          decoration: InputDecoration(
            label: Text('Invoice'),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.copy,
                color: AppColors.grey,
              ),
              onPressed: () => ClipboardHelper.copyToClipboard(
                  _paymentRequestController.text, context),
            ),
          ),
        )
      ],
    );
  }

  Widget _backToDashboardButton() {
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
      child: ElevatedButton.icon(
        icon: Icon(Icons.dashboard),
        onPressed: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                tabIndex: 2,
              ),
            ),
          );
        },
        label: Text('Back to dashboard'),
        style: ElevatedButton.styleFrom(
          elevation: 3,
          minimumSize: Size(double.infinity, 50),
          primary: Colors.transparent,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
