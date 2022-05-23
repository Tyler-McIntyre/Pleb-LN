import 'package:flutter/material.dart';
import '../util/app_colors.dart';

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
    const Icon(Icons.alt_route): 'Manage Channels',
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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
            child: Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(
                  context,
                )),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
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
                          final snackBar = SnackBar(
                            content: Text(
                              'Coming Soon -> ${listTileInfo.values.toList()[index]}!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20),
                            ),
                            backgroundColor: (AppColors.blueSecondary),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
      ),
    );
  }
}
