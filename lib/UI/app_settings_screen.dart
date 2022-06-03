import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import 'widgets/snackbars.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final Map<Icon, String> listTileInfo = {
    //TODO: Decide if we need this option if we have the node config
    const Icon(Icons.computer): 'Nody_Montana',
    const Icon(Icons.insert_drive_file_outlined): 'Node Info',
    //
    const Icon(Icons.remove_red_eye): 'Privacy',
    const Icon(Icons.lock): 'Security',
    const Icon(Icons.verified): 'Sign or verify message',
    const Icon(Icons.info_outline): 'About',
    //* Less Important options, these will be done after all other pages are finished
    const Icon(Icons.currency_bitcoin): 'Currency',
    const Icon(Icons.language): 'Language',
    const Icon(Icons.brush): 'Theme',
    //*
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(),
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          width: MediaQuery.of(context).size.width / 1.15,
          child: ListView.builder(
            itemCount: listTileInfo.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Card(
                    child: ListTile(
                      onTap: () {
                        Snackbars.comingSoon(
                          context,
                          listTileInfo.values.toList()[index],
                        );
                      },
                      leading: listTileInfo.keys.toList()[index],
                      title: Text(
                        listTileInfo.values.toList()[index],
                        style: TextStyle(fontSize: 25),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
