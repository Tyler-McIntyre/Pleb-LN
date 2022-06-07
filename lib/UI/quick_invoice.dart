import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';
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

class QuickInvoice extends StatefulWidget {
  const QuickInvoice({Key? key}) : super(key: key);

  @override
  State<QuickInvoice> createState() => _QuickInvoiceState();
}

class _QuickInvoiceState extends State<QuickInvoice> {
  late Future<Invoice> invoiceSubscription;
  late QrImage _qrImage;
  TextEditingController _paymentRequestController = TextEditingController();
  double _formSpacing = 12;

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<bool> _initQuickInvoice() async {
    Map<Int64, String> quickInvoiceMap = await _getInvoice();
    String paymentRequest = quickInvoiceMap.values.first;

    _qrImage = QrCodeHelper.createQrImage(paymentRequest);
    _paymentRequestController.text = paymentRequest;
    Int64 addIndex = quickInvoiceMap.keys.first;
    invoiceSubscription = _invoiceSubscription(addIndex).whenComplete(() {
      setState(() {});
    });

    return true;
  }

  Future<Map<Int64, String>> _getInvoice() async {
    String addIndex =
        await SecureStorage.readValue(NodeSetting.quickInvoice.name) ?? '';

    if (addIndex.isEmpty) {
      AddInvoiceResponse invoiceResp = await _createInvoice();
      await SecureStorage.writeValue(
          NodeSetting.quickInvoice.name, invoiceResp.addIndex.toString());
      return {invoiceResp.addIndex: invoiceResp.paymentRequest};
    } else {
      Map<Int64, String> quickInvoice = {};
      Invoice invoice = await _lookupInvoice(Int64.parseInt(addIndex));
      //* is it expired or settled?

      if (invoice.hasSettleDate() ||
          !Formatting.getExpirationDate(
                  invoice.creationDate.toInt(), invoice.expiry.toInt())
              .isAfter(DateTime.now())) {
        AddInvoiceResponse invoiceResp = await _createInvoice();
        await SecureStorage.writeValue(
            NodeSetting.quickInvoice.name, invoiceResp.addIndex.toString());
        quickInvoice = {invoiceResp.addIndex: invoiceResp.paymentRequest};
      } else {
        quickInvoice = {invoice.addIndex: invoice.paymentRequest};
      }

      return quickInvoice;
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
    return FutureBuilder(
        future: _initQuickInvoice(),
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
            child =
                FutureBuilderWidgets.error(context, snapshot.error.toString());
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

  Future<Invoice> _invoiceSubscription(Int64 addIndex) async {
    LND rpc = LND();
    InvoiceSubscription invoiceSubscription =
        InvoiceSubscription(addIndex: addIndex);
    Invoice response = await rpc.invoiceSubscription(invoiceSubscription);
    return response;
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
        onPressed: () async {},
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


  // _invoiceSubscriptionFutureBuilder(),

  // Widget _invoiceSubscriptionFutureBuilder() {
  //   return FutureBuilder(
  //     future: invoiceSubscription,
  //     builder: ((context, AsyncSnapshot<Invoice> snapshot) {
  //       Widget child;
  //       if (snapshot.hasData) {
  //         bool isSettled = snapshot.data!.settleDate > 0 ? true : false;
  //         if (isSettled) {
  //           child = SizedBox(
  //             width: MediaQuery.of(context).size.width / 1.1,
  //             child: Center(
  //               child: Column(
  //                 children: [
  //                   Icon(
  //                     Icons.thumb_up,
  //                     color: AppColors.green,
  //                     size: 50,
  //                   ),
  //                   Text(
  //                     'Paid!',
  //                     style: TextStyle(
  //                       color: AppColors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         } else {
  //           child = SizedBox(
  //             width: 60,
  //             height: 60,
  //             child: Text(snapshot.data!.state.name),
  //           );
  //         }
  //       } else if (snapshot.hasError) {
  //         child = FutureBuilderWidgets.error(
  //           context,
  //           snapshot.error.toString(),
  //         );
  //       } else {
  //         child = FutureBuilderWidgets.circularProgressIndicator();
  //       }
  //       return child;
  //     }),
  //   );
  // }