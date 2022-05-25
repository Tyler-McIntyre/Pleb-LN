import 'package:firebolt/UI/widgets/activities.dart';
import 'package:firebolt/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../database/secure_storage.dart';
import 'Widgets/dashboard_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late bool nodeIsConfigured;
  bool _isExpanded = false;
  Icon caretIcon = Icon(FontAwesomeIcons.caretUp);
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    String nodeIsConfigured = await _nodeIsConfigured();
    setState(() {
      nodeIsConfigured == 'true'
          ? this.nodeIsConfigured = true
          : this.nodeIsConfigured = false;
    });
  }

  Future<String> _nodeIsConfigured() async {
    return await SecureStorage.readValue('isConfigured') ?? 'false';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _nodeIsConfigured(),
        builder: (context, snapshot) {
          late Widget child;
          if (snapshot.hasData) {
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardHeader(
                  nodeIsConfigured: nodeIsConfigured,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            curve: Curves.decelerate,
                            height: _isExpanded
                                ? constraints.biggest.longestSide
                                : 50,
                            duration: const Duration(
                              milliseconds: 500,
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
            child = Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).errorColor,
                  size: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).errorColor),
                  textAlign: TextAlign.center,
                ),
              )
            ]);
          } else {
            child = SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            );
          }

          return child;
        },
      ),
    );
  }
}
