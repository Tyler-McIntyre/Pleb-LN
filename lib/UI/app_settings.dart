import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import 'buttons.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  final Map<Icon, String> listTileInfo = {
    //TODO: Decide if we need this option if we have the node config
    // const Icon(Icons.computer): 'Nody_Montana',
    // const Icon(Icons.insert_drive_file_outlined): 'Node Info',
    //*
    const Icon(Icons.alt_route): 'Manage Channels',
    const Icon(Icons.remove_red_eye): 'Privacy',
    const Icon(Icons.lock): 'Security',
    const Icon(Icons.verified): 'Sign or verify message',
    const Icon(Icons.info_outline): 'About'
    //* Less Important options, these will be done after all other pages are finished
    // const Icon(Icons.currency_bitcoin): 'Currency',
    // const Icon(Icons.language): 'Language',
    // const Icon(Icons.brush): 'Theme',
    //*
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leadingWidth: 70,
        leading: const AppBarIconButton(),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          width: MediaQuery.of(context).size.width / 1.2,
          child: ListTileTheme(
            tileColor: AppColors.secondaryBlack,
            textColor: AppColors.white,
            iconColor: AppColors.white,
            child: ListView.builder(
              itemCount: listTileInfo.length,
              itemBuilder: (context, index) {
                return Card(
                  color: AppColors.white,
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
                    title: Text(listTileInfo.values.toList()[index]),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
