import 'package:firebolt/UI/dashboard_screen.dart';
import 'package:firebolt/models/channel_detail.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constants/channel_list_tile_icon.dart';
import '../database/secure_storage.dart';
import '../util/app_colors.dart';

class ChannelDetailsScreen extends StatefulWidget {
  const ChannelDetailsScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);
  final ChannelDetail channel;

  @override
  State<ChannelDetailsScreen> createState() => _ChannelDetailsScreenState();
}

class _ChannelDetailsScreenState extends State<ChannelDetailsScreen> {
  // final _formKey = GlobalKey<FormState>();
  TextEditingController channelLabelController = TextEditingController();
  bool userIsAddingLabel = false;
  late double _localBalancePercentage;
  bool _channelLabelIsEditable = true;

  @override
  void initState() {
    _fetchChannelLabel();
    _localBalancePercentage = (int.parse(widget.channel.channel!.localBalance) /
        (int.parse(widget.channel.channel!.capacity)));
    super.initState();
  }

  void _fetchChannelLabel() async {
    channelLabelController.text =
        await SecureStorage.readValue(widget.channel.chanId) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _channelDetailsForm(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _channelDetailsButtonBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _channelDetailsButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: Text(
            'Close Channel',
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(175, 50),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: Theme.of(context).textTheme.displaySmall,
            side: const BorderSide(
              color: AppColors.red,
              width: 1.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _saveChannelLabel();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          },
          child: Text(
            'Update channel',
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 3,
            fixedSize: const Size(175, 50),
            primary: AppColors.black,
            onPrimary: AppColors.white,
            textStyle: Theme.of(context).textTheme.displaySmall,
            side: const BorderSide(
              color: AppColors.blue,
              width: 1.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _channelDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: getChannelStatusIcon(widget.channel) as Icon,
              ),
              Column(
                children: [
                  Text(widget.channel.chanId),
                  Text(
                    'Channel id',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  //TODO: make this copyable
                },
                icon: Icon(Icons.copy),
                color: AppColors.grey,
              )
            ],
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.1,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    child: TextFormField(
                      enabled: _channelLabelIsEditable,
                      controller: channelLabelController,
                      decoration: InputDecoration(
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder,
                        label: Text('Channel Label'),
                        hintText: '...',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    enabled: false,
                    label: Text(
                      widget.channel.channel!.remotePubkey,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Text(
                  'Remote pubkey',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.lifetime),
                    Text(
                      'Lifetime',
                      style: TextStyle(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.channel.channel!.uptime),
                  Text(
                    'Uptime',
                    style: TextStyle(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.totalSatoshisSent),
                    Text(
                      'Sats sent',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.channel.channel!.totalSatoshisReceived),
                    Text(
                      'Sats received',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.channel.channel!.commitFee),
                      Text(
                        'Commit fee',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.channel.channel!.unsettledBalance),
                      Text(
                        'Unsettled balance',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.channel.channel!.localBalance),
                          Text(
                            'Local balance',
                            style: TextStyle(color: AppColors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.channel.channel!.remoteBalance),
                          Text(
                            'Remote balance',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CircularPercentIndicator(
                  radius: 100,
                  animation: true,
                  animationDuration: 1200,
                  lineWidth: 15.0,
                  percent: _localBalancePercentage,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.channel.channel!.capacity),
                      Text(
                        'Capacity',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.square,
                  backgroundColor: AppColors.red,
                  progressColor: AppColors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _saveChannelLabel() async {
    await SecureStorage.writeValue(
      widget.channel.chanId,
      channelLabelController.text,
    );
  }
}
