import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebolt/UI/app_settings_screen.dart';
import 'package:firebolt/UI/create_invoice_screen.dart';
import 'package:firebolt/UI/node_config_screen.dart';
import 'package:firebolt/UI/open_channel_screen.dart';
import 'package:firebolt/UI/on_chain_screen.dart';
import 'package:firebolt/UI/channels_screen.dart';
import 'package:firebolt/UI/pay_screen.dart';
import 'package:firebolt/constants/node_setting.dart';
import 'package:firebolt/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/images.dart';
import '../database/secure_storage.dart';
import '../util/navigate.dart';
import 'widgets/future_builder_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key? key,
    required this.tabIndex,
  }) : super(key: key);
  final int tabIndex;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late bool nodeIsConfigured;
  late Future<bool> _isConfigured;
  late int _selectedIndex;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    this._selectedIndex = widget.tabIndex;
    this._isConfigured = _nodeIsConfigured();
  }

  Future<bool> _nodeIsConfigured() async {
    String result =
        await SecureStorage.readValue(NodeSetting.isConfigured.name) ?? 'false';
    setState(() {
      result == 'true'
          ? this.nodeIsConfigured = true
          : this.nodeIsConfigured = false;
    });
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  //State class
  List<Widget> _screen = [
    OnChainScreen(),
    ChannelsScreen(),
    PayScreen(),
    NodeConfigScreen(),
  ];
  Widget currentScreen = CreateInvoice();
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _isConfigured,
          builder: (context, snapshot) {
            late Widget child;
            if (snapshot.hasData) {
              child = Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(Images.whitePlebLogo, scale: 20),
                        Row(
                          children: [
                            if (_selectedIndex == 1)
                              IconButton(
                                onPressed: () {
                                  Navigate.toRoute(
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OpenChannelScreen(),
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.add,
                                ),
                              ),
                            IconButton(
                              onPressed: () => Navigate.toRoute(
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppSettingsScreen(
                                      tabIndex: _selectedIndex,
                                    ),
                                  ),
                                ),
                              ),
                              icon: Icon(
                                Icons.settings,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: _screen[_selectedIndex],
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              child = FutureBuilderWidgets.error(
                context,
                snapshot.error.toString(),
              );
            } else {
              child = FutureBuilderWidgets.circularProgressIndicator();
            }

            return child;
          },
        ),
      ),
    );
  }
}
