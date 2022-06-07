import 'package:flutter/material.dart';
import '../util/app_colors.dart';

enum ChannelListTileIcon {
  private_active,
  private_inactive,
  public_active,
  public_inactive,
  pending
}

Map<ChannelListTileIcon, Icon> _ChannelIconMap = {
  ChannelListTileIcon.private_active: Icon(
    Icons.private_connectivity,
    color: AppColors.lightGreen,
  ),
  ChannelListTileIcon.private_inactive: Icon(
    Icons.private_connectivity,
    color: AppColors.red,
  ),
  ChannelListTileIcon.public_active: Icon(
    Icons.public,
    color: AppColors.lightGreen,
  ),
  ChannelListTileIcon.public_inactive: Icon(
    Icons.public,
    color: AppColors.red,
  ),
  ChannelListTileIcon.pending: Icon(
    Icons.pending,
  ),
};

Icon? getChannelStatusIcon(bool active, bool private, bool pendingChannel) {
  ChannelListTileIcon listtileIcon;

  if (!pendingChannel) {
    if (private && active) {
      listtileIcon = ChannelListTileIcon.private_active;
    } else if (private && !active) {
      listtileIcon = ChannelListTileIcon.private_inactive;
    } else if (!private && active) {
      listtileIcon = ChannelListTileIcon.public_active;
    } else {
      listtileIcon = ChannelListTileIcon.public_inactive;
    }
  } else {
    listtileIcon = ChannelListTileIcon.pending;
  }

  return _ChannelIconMap[listtileIcon];
}
