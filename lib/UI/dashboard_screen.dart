import 'package:flutter/material.dart';
import 'Widgets/activities.dart';
import 'Widgets/Dashboard_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          DashboardHeader(),
          Activities(),
        ],
      ),
    );
  }
}
