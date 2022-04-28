// import 'package:carousel_indicator/carousel_indicator.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'carousel_cards.dart';

// class DashboardCarouselSlider extends StatefulWidget {
//   const DashboardCarouselSlider({Key? key}) : super(key: key);

//   @override
//   State<DashboardCarouselSlider> createState() =>
//       _DashboardCarouselSliderState();
// }

// class _DashboardCarouselSliderState extends State<DashboardCarouselSlider> {
//   int pageIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (BuildContext context) {
//         return Column(
//           children: [
//             Expanded(
//                 flex: 5,
//                 child: CarouselSlider(
//                   options: CarouselOptions(
//                       height: MediaQuery.of(context).size.height / 1.5,
//                       viewportFraction: 1,
//                       reverse: false,
//                       enableInfiniteScroll: false,
//                       onPageChanged: (index, _) {
//                         setState(() {
//                           pageIndex = index;
//                         });
//                       }),
//                   items: carouselCards.map((carouselOption) {
//                     return Builder(
//                       builder: (BuildContext context) {
//                         return carouselOption;
//                       },
//                     );
//                   }).toList(),
//                 )),
//             Expanded(
//               child: CarouselIndicator(
//                 count: carouselCards.length,
//                 index: pageIndex,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
