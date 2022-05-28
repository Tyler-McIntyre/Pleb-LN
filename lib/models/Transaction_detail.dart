import '../constants/transfer_type.dart';

class TransactionDetail {
  String amount;
  DateTime dateTime;
  TransferType transferType;
  TransactionDetail(this.amount, this.dateTime, this.transferType);
}
