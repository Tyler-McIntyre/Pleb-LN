import 'package:firebolt/database/secure_storage.dart';
import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import 'Widgets/buttons.dart';
import 'app_settings.dart';
import 'dashboard.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late String nodeIsConfigured;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    //TODO: Remove me  and add as a script
    // await SecureStorage.wipeStorage();
    final nodeIsConfigured =
        await SecureStorage.readValue('isConfigured') ?? 'false';

    setState(() {
      this.nodeIsConfigured = nodeIsConfigured;
    });
  }

  //* This mimics the load time when connecting to a node
  //* when we are actually connecting to a node, the delayed
  //* function will be replaced with a call to make the connection
  final Future<String> getConfig = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );

  //* Home screen animations
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
                        builder: (context) => const AppSettings(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ),
            ],
          ),
        ],
        body: nodeIsConfigured == 'true'
            ? FutureBuilder(
                future: getConfig,
                builder: (context, AsyncSnapshot<String> snapshot) {
                  Widget child;
                  if (snapshot.hasData) {
                    //* If the node is configured display the dashboard
                    child = const Dashboard();
                  } else if (snapshot.hasError) {
                    //* If the there is an error loading the node, display error
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
              )
            :
            //* If the node is NOT configured then present an icon on startup
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
              ),
      ),
    );
  }
}
