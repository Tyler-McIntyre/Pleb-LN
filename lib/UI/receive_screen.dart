import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import 'create_invoice_screen.dart';
import 'Widgets/curve_clipper.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * .75,
              color: AppColors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Text(
                      'How\'d you like to ReceiveScreen?:',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.white, fontSize: 25),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateInvoiceScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          fixedSize: const Size(175, 100),
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
                              'New invoice',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          const snackBar = SnackBar(
                            content: Text(
                              'Coming Soon -> LNURL!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                            backgroundColor: (AppColors.blueSecondary),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          fixedSize: const Size(175, 100),
                          primary: AppColors.black,
                          onPrimary: AppColors.white,
                          textStyle: const TextStyle(fontSize: 20),
                          side: const BorderSide(
                            color: AppColors.blueSecondary,
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
                              Icons.bolt,
                              color: AppColors.white,
                            ),
                            Text(
                              'LNURL',
                              style: TextStyle(
                                color: AppColors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
