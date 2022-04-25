import 'package:flutter/material.dart';

import '../app_colors.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  final Map<Icon, String> listTileInfo = {
    const Icon(Icons.computer): 'Nody_Montana',
    const Icon(Icons.insert_drive_file_outlined): 'Node Info',
    const Icon(Icons.remove_red_eye): 'Privacy',
    const Icon(Icons.lock): 'Security',
    const Icon(Icons.verified): 'Sign or verify message',
    const Icon(Icons.currency_bitcoin): 'Currency',
    const Icon(Icons.language): 'Language',
    const Icon(Icons.brush): 'Theme',
    const Icon(Icons.info_outline): 'About'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
