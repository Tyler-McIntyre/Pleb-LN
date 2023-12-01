import 'package:dropdown_button2/dropdown_button2.dart';
import '../provider/database_provider.dart';
import '../generated/lightning.pb.dart';
import '../provider/balance_provider.dart';
import '../provider/index_provider.dart';
import '../provider/sorting_provider.dart';
import '../provider/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/lightning.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import '../constants/transfer_type.dart';
import '../constants/tx_sort_type.dart';
import '../models/transaction_detail.dart';
import '../util/app_colors.dart';
import '../util/formatting.dart';
import 'Widgets/balance.dart';
import 'widgets/future_builder_widgets.dart';

class OnChainScreen extends ConsumerWidget {
  OnChainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //poll for updates
    ref.watch(TransactionProvider.transactionStream);

    //fetch the alias
    AsyncValue<String> alias = ref.watch(DatabaseProvider.alias);
    //fetch the confirmed total balance
    WalletBalanceResponse walletBalance =
        ref.watch(BalanceProvider.onChainBalance);
    int balanceIndex = ref.watch(IndexProvider.balanceTypeIndex);

    //build the balance widgets
    List<Widget> _balanceWidgets = Balance.buildWidgets(
        walletBalance.totalBalance.toString(), context, ref);

    //set the sort type
    TxSortType _txSortType = ref.watch(SortingProvider.txSortTypeProvider);

    //fetch the transaction data
    ListPaymentsResponse payments = ref.watch(TransactionProvider.payments);
    ListInvoiceResponse invoices = ref.watch(TransactionProvider.invoices);
    List<TransactionDetail> _transactions =
        _getTransactions(_txSortType, payments, invoices);

    void _changeBalanceWidget() {
      balanceIndex >= _balanceWidgets.length - 1
          ? ref.read(IndexProvider.balanceTypeIndex.notifier).state = 0
          : ref.read(IndexProvider.balanceTypeIndex.notifier).state += 1;
    }

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              alias.when(
                data: (alias) {
                  return Text(alias,
                      style: Theme.of(context).textTheme.bodyLarge);
                },
                error: (err, stack) =>
                    FutureBuilderWidgets.error(context, err.toString()),
                loading: () =>
                    CircularProgressIndicator(color: AppColors.white),
              ),
              Column(children: [
                TextButton(
                  onPressed: () {
                    _changeBalanceWidget();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _balanceWidgets[balanceIndex],
                    ],
                  ),
                )
              ]),
            ],
          ),
        ),
        //FilterBar
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Recent Activites ',
                  style: Theme.of(context).textTheme.bodySmall),
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  style: TextStyle(color: AppColors.white),
                  items: TxFilters.filters
                      .map((item) => DropdownMenuItem<TxSortType>(
                            value: item,
                            child: Text(
                              item.name,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ))
                      .toList(),
                  value: _txSortType,
                  onChanged: (value) {
                    switch (value) {
                      case (TxSortType.Date):
                        _txSortType = TxSortType.Date;
                        break;
                      case (TxSortType.Sent):
                        _txSortType = TxSortType.Sent;
                        break;
                      case (TxSortType.Received):
                        _txSortType = TxSortType.Received;
                        break;
                    }
                    ref
                        .read(SortingProvider.txSortTypeProvider.notifier)
                        .state = value as TxSortType;
                    _transactions =
                        _getTransactions(_txSortType, payments, invoices);
                  },
                  // buttonHeight: 40,
                  // buttonWidth: 140,
                  // itemHeight: 40,
                  // dropdownMaxHeight: 200,
                  // dropdownWidth: 140,
                  // dropdownPadding: EdgeInsets.only(bottom: 8),
                  // dropdownDecoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(14),
                  //   color: AppColors.black,
                  // ),
                ),
              ),
            ],
          ),
        ),
        //FilterBar,
        Expanded(
          flex: 2,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topRight,
                colors: [
                  AppColors.blue,
                  AppColors.black,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: Scrollbar(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.zero,
                  children: [
                    Column(children: _buildTxListTiles(_transactions, context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Padding> _buildTxListTiles(
      List<TransactionDetail> txList, BuildContext context) {
    List<Padding> txListTiles = [];

    Icon sentIcon = Icon(Icons.send);
    Icon receivedIcon = Icon(Icons.receipt);

    for (TransactionDetail transactionDetail in txList) {
      bool isSentTx =
          transactionDetail.transferType == TransferType.Sent ? true : false;

      txListTiles.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            // onTap: (){}, //TODO: navigate to transaction details page
            style: ListTileStyle.list,
            leading: isSentTx ? sentIcon : receivedIcon,
            title: Text.rich(
              TextSpan(
                text: null,
                children: [
                  TextSpan(
                    text: transactionDetail.transferType.name,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                  TextSpan(
                    text: Formatting.dateTimeToShortDate(
                        transactionDetail.dateTime),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  WidgetSpan(
                    child: Container(),
                  ),
                ],
              ),
            ),
            trailing: Text.rich(
              TextSpan(
                  text: '${MoneyFormatter(
                    amount:
                        int.parse(transactionDetail.amount).toDouble(), //amount
                  ).output.withoutFractionDigits}',
                  style: TextStyle(
                    fontSize: 19,
                    color: (transactionDetail.transferType == TransferType.Sent
                        ? AppColors.red
                        : AppColors.lightGreen),
                  ),
                  children: [
                    TextSpan(
                      text: 'sats',
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  ]),
            ),
          ),
        ),
      );
    }

    return txListTiles;
  }

  List<TransactionDetail> _getTransactions(TxSortType sortType,
      ListPaymentsResponse payments, ListInvoiceResponse invoices) {
    List<TransactionDetail> txList = [];
    payments.payments.forEach((payment) {
      txList.add(
        TransactionDetail(
            payment.valueSat.toString(),
            Formatting.timestampNanoSecondsToDate(
              payment.creationTimeNs.toInt(),
            ),
            TransferType.Sent),
      );
    });
    invoices.invoices.forEach((invoice) {
      bool invoiceIsSettled = invoice.settleDate > 0;
      if (invoiceIsSettled) {
        txList.add(
          TransactionDetail(
              invoice.amtPaidSat.toString(),
              Formatting.timestampToDateTime(
                invoice.settleDate.toInt(),
              ),
              TransferType.Received),
        );
      }
    });

    switch (sortType) {
      case TxSortType.Date:
        txList.sort((a, b) {
          return b.dateTime.compareTo(a.dateTime);
        });
        break;
      case TxSortType.Sent:
        txList = txList
            .where((TransactionDetail) =>
                TransactionDetail.transferType == TransferType.Sent)
            .toList()
            .reversed
            .toList();
        break;
      case TxSortType.Received:
        txList = txList
            .where((TransactionDetail) =>
                TransactionDetail.transferType == TransferType.Received)
            .toList()
            .reversed
            .toList();
        break;
    }

    return txList;
  }
}
