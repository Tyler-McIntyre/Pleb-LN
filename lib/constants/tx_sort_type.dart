enum TxSortType { Date, Sent, Received }

class TxFilters {
  static final List<TxSortType> filters = [
    TxSortType.Date,
    TxSortType.Sent,
    TxSortType.Received,
  ];
}
