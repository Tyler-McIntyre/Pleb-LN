import 'package:firebolt/constants/node_setting.dart';
import 'package:firebolt/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/images.dart';
import '../database/secure_storage.dart';
import 'Widgets/activities.dart';
import 'Widgets/dashboard_header.dart';
import 'app_settings_screen.dart';
import 'widgets/future_builder_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late bool nodeIsConfigured;
  late Future<bool> _isConfigured;
  bool _isExpanded = false;
  Icon caretIcon = Icon(FontAwesomeIcons.caretUp);
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
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

  int containerTransitionSpeedCollapse = 400;
  int containerTransitionSpeedExpand = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          Images.whitePlebLogo,
          scale: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: AppColors.white,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _isConfigured,
        builder: (context, snapshot) {
          late Widget child;
          if (snapshot.hasData) {
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: _isExpanded ? 0 : 1,
                  child: DashboardHeader(
                    nodeIsConfigured: nodeIsConfigured,
                    isExpanded: _isExpanded,
                  ),
                ),
                Expanded(
                  flex: _isExpanded ? 1 : 0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            height: _isExpanded ? constraints.maxHeight : 50,
                            duration: _isExpanded
                                ? Duration(
                                    milliseconds:
                                        containerTransitionSpeedExpand)
                                : Duration(
                                    milliseconds:
                                        containerTransitionSpeedCollapse,
                                  ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.center,
                                      icon: _isExpanded
                                          ? Icon(FontAwesomeIcons.caretDown)
                                          : Icon(FontAwesomeIcons.caretUp),
                                      color: AppColors.white,
                                      onPressed: () {
                                        setState(() {
                                          _isExpanded = !_isExpanded;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                _isExpanded
                                    ? Expanded(
                                        child: Activities(
                                            nodeIsConfigured: nodeIsConfigured),
                                      )
                                    : SizedBox.shrink()
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
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
    );
  }
}
