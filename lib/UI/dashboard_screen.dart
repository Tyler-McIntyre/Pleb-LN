import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/images.dart';
import '../provider/index_provider.dart';
import '../shared/utils/app_colors.dart';
import '../shared/utils/navigation_service.dart';
import 'app_settings_screen.dart';
import 'channels_screen.dart';
import 'node_config_screen.dart';
import 'on_chain_screen.dart';
import 'open_channel_screen.dart';
import 'pay_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, this.tabIndex});
  
  final int? tabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Widget> screens = [
      OnChainScreen(),
      ChannelsScreen(),
      const PayScreen(),
      NodeConfigScreen(),
    ];
    
    final GlobalKey<State> bottomNavigationKey = GlobalKey();
    final int bottomNavIndex = ref.watch(IndexProvider.bottomNavIndex);
    final int selectedIndex = bottomNavIndex;

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.black,
              key: bottomNavigationKey,
              selectedIconTheme: const IconThemeData(color: AppColors.white),
              selectedItemColor: AppColors.blue,
              currentIndex: selectedIndex,
              selectedFontSize: 15,
              unselectedFontSize: 13,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.currency_bitcoin, size: 30),
                  label: 'Bitcoin',
                  backgroundColor: AppColors.black,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bolt, size: 30),
                  backgroundColor: AppColors.black,
                  label: 'Lightning',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_outlined, size: 30),
                  label: 'Pay',
                  backgroundColor: AppColors.black,
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.raspberryPi, size: 30),
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
                          if (selectedIndex == 1)
                            IconButton(
                                onPressed: () {
                                  NavigationService.navigateTo(
                                    context,
                                    const OpenChannelProvider(),
                                    replace: true,
                                  );
                                },
                                icon: const Icon(Icons.add)),
                          IconButton(
                              onPressed: () => NavigationService.navigateTo(
                                context,
                                AppSettingsScreen(tabIndex: selectedIndex),
                                replace: true,
                              ),
                              icon: const Icon(Icons.settings))
                        ])
                      ])),
              Expanded(child: screens[selectedIndex])
            ]))));
  }
}
