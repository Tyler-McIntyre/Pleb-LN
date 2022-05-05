import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import 'Widgets/curve_clipper.dart';

class CreateInvoice extends StatefulWidget {
  const CreateInvoice({Key? key}) : super(key: key);

  @override
  State<CreateInvoice> createState() => _CreateInvoiceState();
}

class _CreateInvoiceState extends State<CreateInvoice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redPrimary,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Invoice'),
        centerTitle: true,
      ),
      body: CreateInvoiceForm(),
    );
  }
}

class CreateInvoiceForm extends StatefulWidget {
  const CreateInvoiceForm({Key? key}) : super(key: key);

  @override
  State<CreateInvoiceForm> createState() => _CreateInvoiceFormState();
}

class _CreateInvoiceFormState extends State<CreateInvoiceForm> {
  static final _formKey = GlobalKey<FormState>();
  static bool routeHintsIsSwitched = false;
  static bool ampInvoiceIsSwitched = false;
  TextEditingController memoController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController expirationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stack(
        children: [
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * .75,
              color: AppColors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //*Memo
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: memoController,
                            cursorColor: AppColors.white,
                            decoration: const InputDecoration(
                              label: Text(
                                'Memo',
                                style: TextStyle(color: AppColors.white),
                              ),
                              border: UnderlineInputBorder(),
                              hintStyle: TextStyle(color: AppColors.grey),
                              hintText: 'A Satoshi for your thoughts?',
                            ),
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        //*Amount
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: amountController,
                            cursorColor: AppColors.white,
                            decoration: const InputDecoration(
                              label: Text(
                                'Amount (sats)',
                                style: TextStyle(color: AppColors.white),
                              ),
                              border: UnderlineInputBorder(),
                              hintStyle: TextStyle(color: AppColors.grey),
                              hintText: '0',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              return null;
                            },
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        //*Expiration
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: expirationController,
                            cursorColor: AppColors.white,
                            decoration: const InputDecoration(
                              label: Text(
                                'Expiration (in seconds)',
                                style: TextStyle(color: AppColors.white),
                              ),
                              border: UnderlineInputBorder(),
                              hintStyle: TextStyle(color: AppColors.grey),
                              hintText: '3600',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an expiration';
                              }
                              return null;
                            },
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SwitchListTile(
                          title: const Text(
                            'Include Route Hints',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: routeHintsIsSwitched,
                          onChanged: (bool value) {
                            setState(() {
                              routeHintsIsSwitched = value;
                            });
                          },
                          secondary: const Icon(
                            Icons.compare_arrows_sharp,
                            color: Colors.white,
                          ),
                        ),
                        //* AMP Invoice switch
                        SwitchListTile(
                          title: const Text(
                            'AMP Invoice',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: ampInvoiceIsSwitched,
                          onChanged: (bool value) {
                            setState(() {
                              ampInvoiceIsSwitched = value;
                            });
                          },
                          secondary: const Icon(
                            Icons.amp_stories,
                            color: Colors.white,
                          ),
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
                top: MediaQuery.of(context).size.height * .65,
                right: 20.0,
                left: 20.0),
            child: SizedBox(
              height: 100.0,
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                child: CreateInvoiceButtonBar(),
              ),
            ),
          )
        ],
      ),
    );
  }

  CreateInvoiceButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              memoController.clear();
              amountController.clear();
              expirationController.clear();
              routeHintsIsSwitched = false;
              ampInvoiceIsSwitched = false;
            });
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(150, 71),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: const TextStyle(fontSize: 20),
            side: const BorderSide(
              color: AppColors.redPrimary,
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
            children: const [
              Icon(
                Icons.restore,
                color: AppColors.white,
              ),
              Text(
                'Reset',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              const snackBar = SnackBar(
                content: Text(
                  'Coming Soon -> Create Invoice!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                backgroundColor: (AppColors.blueSecondary),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(150, 71),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: const TextStyle(fontSize: 20),
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
            children: const [
              Icon(
                Icons.create,
                color: AppColors.white,
              ),
              Text(
                'Create',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
