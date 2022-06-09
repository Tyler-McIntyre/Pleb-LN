enum ChannelSortType {
  Pending,
  Inactive,
  Active,
  Capacity,
  Private,
  Public,
  Id
}

class ChannelFilters {
  static final List<ChannelSortType> filters = [
    ChannelSortType.Active,
    ChannelSortType.Capacity,
    ChannelSortType.Id,
    ChannelSortType.Inactive,
    ChannelSortType.Pending,
    ChannelSortType.Private,
    ChannelSortType.Public,
  ];
}
