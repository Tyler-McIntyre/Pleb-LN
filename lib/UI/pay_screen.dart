import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'pay_invoice.dart';
import 'quick_invoice.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({Key? key}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    @override
    List<Widget> _payScreens = [PayInvoice(), QuickInvoice()];
    return Column(
      children: [
        Expanded(
          flex: 9,
          child: CarouselSlider(
            options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    pageIndex = index;
                  });
                }),
            items: _payScreens.map((widget) {
              return Builder(
                builder: (BuildContext context) {
                  return widget;
                },
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: CarouselIndicator(
            animationDuration: 200,
            count: _payScreens.length,
            index: pageIndex,
          ),
        )
      ],
    );
  }
}
