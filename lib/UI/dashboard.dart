import 'package:flutter/material.dart';
import 'Widgets/activities.dart';
import 'Widgets/dashboard_header.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          DashboardHeader(),
          const Divider(),
          Activities(),
        ],
      ),
    );
  }
}
