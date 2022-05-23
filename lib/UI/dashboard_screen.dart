import 'package:flutter/material.dart';
import '../database/secure_storage.dart';
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
      body: Column(
        children: [
          DashboardHeader(nodeIsConfigured: nodeIsConfigured),
          Expanded(
            child: Activities(nodeIsConfigured: nodeIsConfigured),
          )
        ],
      ),
    );
  }
}
