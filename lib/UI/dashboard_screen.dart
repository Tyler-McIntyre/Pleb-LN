import 'package:flutter/material.dart';
import '../database/secure_storage.dart';
import '../util/app_colors.dart';
import 'Widgets/activities.dart';
import 'Widgets/dashboard_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late bool nodeIsConfigured;
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
              children: [
                DashboardHeader(nodeIsConfigured: nodeIsConfigured),
                Expanded(
                  child: Activities(nodeIsConfigured: nodeIsConfigured),
                )
              ],
            );
          } else if (snapshot.hasError) {
            child = Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: AppColors.red),
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

          return Center(
            child: child,
          );
        },
      ),
    );
  }
}
