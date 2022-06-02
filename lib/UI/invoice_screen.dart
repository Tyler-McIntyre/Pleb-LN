import 'package:firebolt/UI/Widgets/qr_code_helper.dart';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:firebolt/generated/lightning.pb.dart';
import 'package:firebolt/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../rpc/lnd.dart';
import '../util/clipboard_helper.dart';
import 'Widgets/curve_clipper.dart';
import 'Widgets/qr_code_helper.dart';
import 'package:fixnum/fixnum.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);
  final AddInvoiceResponse invoice;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late QrImage _qrImage;
  TextEditingController _textController = TextEditingController();
  late Future<Invoice> invoiceSubscription;

  @override
  void initState() {
    String paymentRequest = widget.invoice.paymentRequest;
    this._qrImage = QrCodeHelper.createQrImage(paymentRequest);
    _textController.text = paymentRequest;
    Int64 addIndex = widget.invoice.addIndex;
    this.invoiceSubscription = _invoiceSubscription(addIndex);
    super.initState();
  }

  Future<Invoice> _invoiceSubscription(Int64 addIndex) async {
    LND rpc = LND();
    InvoiceSubscription invoiceSubscription =
        InvoiceSubscription(addIndex: addIndex);
    Invoice response = await rpc.invoiceSubscription(invoiceSubscription);
    print('Screen response $response');
    return response;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          child: Icon(Icons.home),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * .93,
              color: AppColors.black,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _qrImage,
                                  Padding(
                                    padding: const EdgeInsets.only(top: 32),
                                    child: TextField(
                                      style: TextStyle(
                                          color: AppColors.white, fontSize: 22),
                                      readOnly: true,
                                      controller: _textController,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            color: AppColors.orange,
                                          ),
                                          onPressed: () =>
                                              ClipboardHelper.copyToClipboard(
                                                  _textController.text,
                                                  context),
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder(
                              future: invoiceSubscription,
                              builder:
                                  ((context, AsyncSnapshot<Invoice> snapshot) {
                                Widget child;
                                if (snapshot.hasData) {
                                  bool isSettled = snapshot.data!.settleDate > 0
                                      ? true
                                      : false;
                                  if (isSettled) {
                                    child = SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.thumb_up,
                                              color: AppColors.green,
                                              size: 50,
                                            ),
                                            Text(
                                              'Paid!',
                                              style: TextStyle(
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    child = SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Text(snapshot.data!.state.name),
                                    );
                                  }
                                } else if (snapshot.hasError) {
                                  child = Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
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
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).errorColor),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  child = SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return Expanded(
                                    flex: 2,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          child,
                                        ],
                                      ),
                                    ));
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
