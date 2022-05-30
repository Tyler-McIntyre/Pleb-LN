import 'package:flutter/material.dart';
import '../models/channel_detail.dart';
import '../util/app_colors.dart';
import 'channel_status.dart';
import 'channel_type.dart';

enum ChannelListTileIcon {
  private_active,
  private_inactive,
  public_active,
  public_inactive,
  pending
}

Map<ChannelListTileIcon, Icon> ChannelIconMap = {
  ChannelListTileIcon.private_active: Icon(
    Icons.private_connectivity,
    color: AppColors.green,
  ),
  ChannelListTileIcon.private_inactive: Icon(
    Icons.private_connectivity,
    color: AppColors.red,
  ),
  ChannelListTileIcon.public_active: Icon(
    Icons.public,
    color: AppColors.green,
  ),
  ChannelListTileIcon.public_inactive: Icon(
    Icons.public,
    color: AppColors.red,
  ),
  ChannelListTileIcon.pending: Icon(
    Icons.pending,
  ),
};

Icon? getChannelStatusIcon(ChannelDetail channel) {
  bool isActive = channel.channelStatus == ChannelStatus.Active ? true : false;
  bool isPrivate = channel.channelType == ChannelType.private ? true : false;

  ChannelListTileIcon listtileIcon;

  if (channel.channelStatus != ChannelStatus.Pending) {
    if (isPrivate && isActive) {
      listtileIcon = ChannelListTileIcon.private_active;
    } else if (isPrivate && !isActive) {
      listtileIcon = ChannelListTileIcon.private_inactive;
    } else if (!isPrivate && isActive) {
      listtileIcon = ChannelListTileIcon.public_active;
    } else {
      listtileIcon = ChannelListTileIcon.public_inactive;
    }
  } else {
    listtileIcon = ChannelListTileIcon.pending;
  }

  return ChannelIconMap[listtileIcon];
}
