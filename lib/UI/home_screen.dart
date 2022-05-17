import 'package:firebolt/database/secure_storage.dart';
import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import 'Widgets/buttons.dart';
import 'app_settings_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String nodeIsConfigured = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    //TODO: Remove me & add as a script
    //* This serves as a temporary workaround until a script is created to wipe the emulator data.
    //* Uncomment the line below & save, restart the app, comment it back out & save
    // await SecureStorage.wipeStorage();

    setState(() {
      this.nodeIsConfigured = nodeIsConfigured;
    });
  }

  //* HomeScreen screen animations
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

  Future<String> _nodeIsConfigured() async {
    return await SecureStorage.readValue('isConfigured') ?? 'false';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      //TODO: Fix the NestedScrollView, adds extra padding/space when displaying the dashboard widget
      //* The work around for this was creating an app bar with a height of 0
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            leadingWidth: 70,
            leading: const AppBarIconButton(),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppSettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ),
            ],
          ),
        ],
        body: FutureBuilder(
          future: _nodeIsConfigured(),
          builder: (context, AsyncSnapshot<String> snapshot) {
            Widget child;
            if (snapshot.hasData) {
              if (snapshot.data == 'true') {
                //* If the node is configured display the dashboard
                child = const DashboardScreen();
              } else if (snapshot.data == 'false') {
                child = //* If the node is NOT configured then present an icon on startup
                    Center(
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
                        style: TextStyle(color: AppColors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ));
              }
            }
            if (snapshot.data == 'true') {
              //* If the node is configured display the dashboard
              child = const DashboardScreen();
            } else if (snapshot.data == 'false') {
              child = //* If the node is NOT configured then present an icon on startup
                  Center(
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
                        style: TextStyle(color: AppColors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              //* If the there is an error loading the node, display error
              child = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.redPrimary,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ],
              );
            } else {
              //* Otherwise show a loading bar
              child = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Syncing node...',
                      style: TextStyle(color: AppColors.white),
                    ),
                  )
                ],
              );
            }
            return child;
          },
        ),
      ),
    );
  }
}
