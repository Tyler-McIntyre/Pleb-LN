import 'package:firebolt/database/secure_storage.dart';
import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import 'Widgets/buttons.dart';
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
      body: FutureBuilder(
        future: _nodeIsConfigured(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          late Widget child;
          if (snapshot.hasData) {
            if (snapshot.data == 'true') {
              //* If the node is configured display the dashboard
              child = const DashboardScreen();
            } else if (snapshot.data == 'false') {
              //* If the node is NOT configured then present an icon on startup
              child = Center(
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
                      'Tap to link your node',
                      style: TextStyle(color: AppColors.white, fontSize: 20),
                    ),
                  ),
                ],
              ));
            }
          } else if (snapshot.hasError) {
            //* If the there is an error loading the node, display error
            child = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.red,
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
                Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
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
    );
  }
}
