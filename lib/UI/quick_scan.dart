import 'package:firebolt/UI/create_invoice_screen.dart';
import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/node_setting.dart';
import '../database/secure_storage.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import '../util/clipboard_helper.dart';
import '../util/formatting.dart';
import 'Widgets/qr_code_helper.dart';
import 'widgets/future_builder_widgets.dart';
import 'widgets/snackbars.dart';

class QuickScan extends StatefulWidget {
  const QuickScan({Key? key}) : super(key: key);

  @override
  State<QuickScan> createState() => _QuickScanState();
}

class _QuickScanState extends State<QuickScan>
    with SingleTickerProviderStateMixin {
  late Future<Invoice> invoiceSubscription;
  late QrImage _qrImage;
  TextEditingController _paymentRequestController = TextEditingController();
  double _formSpacing = 12;
  late Future<bool> _init;
  bool invoiceWasPaid = false;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);

    _init = _initQuickScan();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          invoiceWasPaid = false;
          _init = _initQuickScan();
        });
        _controller.reset();
      }
    });
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _initQuickScan() async {
    Invoice invoice = await _getInvoice();
    String paymentRequest = invoice.paymentRequest;

    _qrImage = QrCodeHelper.createQrImage(paymentRequest);
    _paymentRequestController.text = paymentRequest;
    Int64 addIndex = invoice.addIndex;
    _invoiceSubscription(addIndex);

    return true;
  }

  Future<Invoice> _getInvoice() async {
    String addIndex =
        await SecureStorage.readValue(NodeSetting.quickScan.name) ?? '';
    if (addIndex.isEmpty) {
      AddInvoiceResponse invoiceResp = await _createInvoice();
      await SecureStorage.writeValue(
          NodeSetting.quickScan.name, invoiceResp.addIndex.toString());
      return Invoice(
          addIndex: invoiceResp.addIndex,
          paymentRequest: invoiceResp.paymentRequest);
    } else {
      Invoice invoice = await _lookupInvoice(Int64.parseInt(addIndex));
      //* is it expired or settled?
      if (invoice.amtPaidSat > 0 ||
          !Formatting.getExpirationDate(
                  invoice.creationDate.toInt(), invoice.expiry.toInt())
              .isAfter(DateTime.now())) {
        AddInvoiceResponse invoiceResp = await _createInvoice();
        await SecureStorage.writeValue(
            NodeSetting.quickScan.name, invoiceResp.addIndex.toString());
        return Invoice(
            addIndex: invoiceResp.addIndex,
            paymentRequest: invoiceResp.paymentRequest);
      } else {
        return Invoice(
            addIndex: invoice.addIndex, paymentRequest: invoice.paymentRequest);
      }
    }
  }

  Future<Invoice> _lookupInvoice(Int64 addIndex) async {
    LND rpc = LND();
    ListInvoiceResponse list = await rpc.listInvoices();
    Invoice invoice =
        list.invoices.where((invoice) => invoice.addIndex == addIndex).first;
    return invoice;
  }

  Future<AddInvoiceResponse> _createInvoice() async {
    LND rpc = LND();
    AddInvoiceResponse invoice;
    try {
      //One month
      String expirySeconds = '2592000';
      invoice = await rpc.createInvoice(
        Int64(0),
        '',
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

  @override
  Widget build(BuildContext context) {
    return invoiceWasPaid
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
                      'Quick Scan',
                      style: TextStyle(color: AppColors.white),
                    ),
                    SizedBox(
                      height: _formSpacing,
                    ),
                    _invoiceHashAndCode(),
                    SizedBox(
                      height: _formSpacing,
                    ),
                    Text(
                      'or',
                      style: TextStyle(color: AppColors.white),
                    ),
                    SizedBox(
                      height: _formSpacing,
                    ),
                    _createInvoiceButton()
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
            }));
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

  Widget _invoiceHashAndCode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _qrImage,
        ),
        TextFormField(
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
        ),
      ],
    );
  }

  Widget _createInvoiceButton() {
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
        icon: Icon(Icons.create),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateInvoice(),
            ),
          );
        },
        label: Text('Create a New Invoice'),
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
