enum ChannelSortType {
  Pending,
  Inactive,
  Active,
  Private,
  Public,
  Id,
  LocalBalance,
}

class ChannelFilters {
  static final List<ChannelSortType> filters = [
    ChannelSortType.Active,
    ChannelSortType.Id,
    ChannelSortType.Inactive,
    ChannelSortType.Pending,
    ChannelSortType.Private,
    ChannelSortType.Public,
    ChannelSortType.LocalBalance
  ];
}
