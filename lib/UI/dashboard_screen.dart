import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../UI/app_settings_screen.dart';
import '../UI/node_config_screen.dart';
import '../UI/open_channel_screen.dart';
import '../UI/on_chain_screen.dart';
import '../UI/channels_screen.dart';
import '../UI/pay_screen.dart';
import '../provider/index_provider.dart';
import '../util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/images.dart';
import '../util/navigate.dart';

class DashboardScreen extends ConsumerWidget {
  DashboardScreen({Key? key, this.tabIndex}) : super(key: key);
  final int? tabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> _screen = [
      OnChainScreen(),
      ChannelsScreen(),
      PayScreen(),
      NodeConfigScreen(),
    ];
    GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
    int bottomNavIndex = ref.watch(IndexProvider.bottomNavIndex);
    int _selectedIndex = bottomNavIndex;

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.black,
              key: _bottomNavigationKey,
              selectedIconTheme: IconThemeData(color: AppColors.white),
              selectedItemColor: AppColors.blue,
              currentIndex: _selectedIndex,
              selectedFontSize: 15,
              unselectedFontSize: 13,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.currency_bitcoin,
                    size: 30,
                  ),
                  label: 'Bitcoin',
                  backgroundColor: AppColors.black,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.bolt,
                    size: 30,
                  ),
                  backgroundColor: AppColors.black,
                  label: 'Lightning',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.qr_code_scanner_outlined,
                    size: 30,
                  ),
                  label: 'Pay',
                  backgroundColor: AppColors.black,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.raspberryPi,
                    size: 30,
                  ),
                  backgroundColor: AppColors.black,
                  label: 'Node',
                )
              ],
              onTap: (index) {
                ref.read(IndexProvider.bottomNavIndex.notifier).state = index;
              },
            ),
            body: SafeArea(
                child: Column(children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(Images.whitePlebLogo, scale: 20),
                        Row(children: [
                          if (_selectedIndex == 1)
                            IconButton(
                                onPressed: () {
                                  Navigate.toRoute(() => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OpenChannelProvider(),
                                        )));
                                },
                                icon: Icon(
                                  Icons.add,
                                )),
                          IconButton(
                              onPressed: () => Navigate.toRoute(() =>
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AppSettingsScreen(
                                                tabIndex: _selectedIndex,
                                              )))),
                              icon: Icon(Icons.settings))
                        ])
                      ])),
              Expanded(child: _screen[_selectedIndex])
            ]))));
  }
}
