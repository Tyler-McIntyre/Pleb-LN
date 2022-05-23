import 'package:firebolt/UI/Widgets/qr_code_helper.dart';
import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:firebolt/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'Widgets/curve_clipper.dart';
import 'Widgets/qr_code_helper.dart';
import 'package:flutter/services.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key, required this.paymentRequest})
      : super(key: key);
  final String paymentRequest;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late QrImage _qrImage;
  TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    //generate the qr code
    this._qrImage = QrCodeHelper.createQrImage(widget.paymentRequest);
    _textController.text = widget.paymentRequest;
    super.initState();
  }

  // This function is triggered when the copy icon is pressed
  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: AppColors.orange,
      content: Text('Copied to clipboard'),
    ));
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
              height: MediaQuery.of(context).size.height * .85,
              color: AppColors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: _qrImage,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 32.0),
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
                                    onPressed: _copyToClipboard,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
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
