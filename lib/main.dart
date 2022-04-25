import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebolt/buttons.dart';
import 'package:flutter/material.dart';
import 'UI/activity.dart';
import 'UI/app_settings.dart';
import 'UI/dashboard_carousel_slider.dart';
import 'app_colors.dart';
import 'NodeConfig/node_config.dart';

void main() {
  runApp(const FireBolt());
}

class FireBolt extends StatefulWidget {
  const FireBolt({Key? key}) : super(key: key);

  @override
  State<FireBolt> createState() => _FireBoltState();
}

class _FireBoltState extends State<FireBolt> with TickerProviderStateMixin {
  final String _logoPath =
      'images/Firebolt-logos/Firebolt-logos-thumbnail.jpeg';

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int pageIndex = 1;

  final pageWidgets = const [
    Activity(),
    DashboardCarouselSlider(),
    AppSettings()
  ];

  final Future<String> getConfig = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );

  late final AnimationController _iconController = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..forward();

  late final Animation<double> _iconAnimation = CurvedAnimation(
    parent: _iconController,
    curve: Curves.easeIn,
  );

  late final AnimationController _textController = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..forward();

  late final Animation<double> _textAnimation = CurvedAnimation(
    parent: _textController,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _textController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.black,
        colorScheme: const ColorScheme(
          background: AppColors.black,
          onPrimary: AppColors.white,
          brightness: Brightness.light,
          error: AppColors.orange,
          onBackground: AppColors.black,
          onError: AppColors.orange,
          onSecondary: AppColors.black,
          onSurface: AppColors.black,
          primary: AppColors.red,
          secondary: AppColors.red,
          surface: AppColors.yellow,
        ),
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(),
        body: SafeArea(
          top: false,
          child: NodeConfig.isConfigured
              ? FutureBuilder(
                  future: getConfig,
                  builder: (context, AsyncSnapshot<String> snapshot) {
                    Widget child;
                    if (snapshot.hasData) {
                      child = pageWidgets[pageIndex];
                    } else if (snapshot.hasError) {
                      child = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          )
                        ],
                      );
                    } else {
                      child = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              color: AppColors.red,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(
                              //TODO: replace 'node' with the node alias
                              'Syncing node...',
                              style: TextStyle(color: AppColors.white),
                            ),
                          )
                        ],
                      );
                    }
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: child,
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _iconAnimation,
                        child: const LinkNodeButton(),
                      ),
                      FadeTransition(
                        opacity: _textAnimation,
                        child: const Text(
                          'Tap the icon to link your node',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: NodeConfig.isConfigured
            ? CurvedNavigationBar(
                key: _bottomNavigationKey,
                onTap: (pageIndex) =>
                    setState(() => this.pageIndex = pageIndex),
                index: 1,
                color: AppColors.red,
                backgroundColor: AppColors.black,
                items: [
                  const Icon(
                    Icons.list,
                    size: 30,
                    color: AppColors.white,
                  ),
                  ClipOval(
                    child: Image.asset(
                      _logoPath,
                      scale: 11.75,
                    ),
                  ),
                  const Icon(
                    Icons.settings,
                    size: 30,
                    color: AppColors.white,
                  ),
                ],
                // ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
