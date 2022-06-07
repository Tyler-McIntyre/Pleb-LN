import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../UI/widgets/balance.dart';
import '../generated/lightning.pb.dart';
import '../generated/lightning.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import '../constants/transfer_type.dart';
import '../constants/tx_sort_type.dart';
import '../database/secure_storage.dart';
import '../models/transaction_detail.dart';
import '../rpc/lnd.dart';
import '../util/app_colors.dart';
import '../util/formatting.dart';
import '../util/refresh_timer.dart';
import 'widgets/future_builder_widgets.dart';

class OnChainScreen extends StatefulWidget {
  const OnChainScreen({Key? key}) : super(key: key);

  @override
  State<OnChainScreen> createState() => _OnChainScreenState();
}

class _OnChainScreenState extends State<OnChainScreen> {
  late List<Widget> _onChainBalanceWidgets;

  static int onChainBalanceWidgetIndex = 0;
  TextEditingController nicknameController = TextEditingController();
  TxSortType _txSortType = TxSortType.Date;
  late Future<List<TransactionDetail>> _transactions;
  late Future<WalletBalanceResponse> _onChainBalance;
  final List<TxSortType> filters = [
    TxSortType.Date,
    TxSortType.Sent,
    TxSortType.Received,
  ];
  TxSortType? selectedValue;
  Duration refreshInterval = Duration(seconds: 15);

  @override
  void initState() {
    selectedValue = filters.first;
    _transactions = _getTransactions(_txSortType);
    _onChainBalance = _getOnChainBalance();
    _transactions = _getTransactions(_txSortType);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String nickname = await _getNickname();
      RefreshTimer.refreshTimer =
          Timer.periodic(refreshInterval, (timer) => _sweepForUpdates(timer));
      if (!mounted) return;
      setState(() {
        nicknameController.text = nickname;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    RefreshTimer.refreshTimer!.cancel();
    super.dispose();
  }

  Future<String> _getNickname() async {
    final String nickname = await SecureStorage.readValue('nickname') ?? '';
    return nickname;
  }

  _sweepForUpdates(Timer t) async {
    Timer.periodic(
      refreshInterval,
      (Timer t) async {
        List<TransactionDetail> transactions =
            await _getTransactions(_txSortType);
        List<TransactionDetail> currentTxDetails = await _transactions;

        bool newTransactions = currentTxDetails.length == transactions.length;

        WalletBalanceResponse balance = await _getOnChainBalance();
        WalletBalanceResponse currentBalance = await _onChainBalance;

        bool newBalance = currentBalance.totalBalance != balance.totalBalance;

        if (!newTransactions || newBalance) {
          if (newTransactions) {
            if (!mounted) return;
            setState(() {
              _transactions = Future.value(transactions);
            });
          }

          if (newBalance) {
            if (!mounted) return;
            setState(() {
              _onChainBalance = _getOnChainBalance();
            });
          }
        }
      },
    );
  }

  Future<List<TransactionDetail>> _getTransactions(TxSortType sortType) async {
    LND rpc = LND();
    ListPaymentsResponse payments = await rpc.getPayments();
    ListInvoiceResponse invoices = await rpc.listInvoices();
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
              invoice.value.toString(),
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

  Future<WalletBalanceResponse> _getOnChainBalance() async {
    LND rpc = LND();
    WalletBalanceResponse result = await rpc.getWalletBalance();

    String totalBalance = result.totalBalance.toString();
    _onChainBalanceWidgets = await Balance.buildWidgets(totalBalance, context);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(nicknameController.text,
                  style: Theme.of(context).textTheme.bodyLarge),
              _onChainBalanceFutureBuilder(),
            ],
          ),
        ),
        _buttonBar(),
        _txFutureBuilder(),
      ],
    );
  }

  FutureBuilder _onChainBalanceFutureBuilder() {
    return FutureBuilder<WalletBalanceResponse>(
      future: _onChainBalance,
      builder: (BuildContext context,
          AsyncSnapshot<WalletBalanceResponse> snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = Column(
            children: [
              TextButton(
                onPressed: () {
                  if (!mounted) return;
                  setState(() {
                    _changeOnChainBalanceWidget();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _onChainBalanceWidgets[onChainBalanceWidgetIndex],
                  ],
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          child = FutureBuilderWidgets.error(
            context,
            snapshot.error.toString(),
          );
        } else {
          child = Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            ),
          );
        }
        return child;
      },
    );
  }

  FutureBuilder _txFutureBuilder() {
    return FutureBuilder<List<TransactionDetail>>(
      future: _transactions,
      builder: (
        context,
        AsyncSnapshot<List<TransactionDetail>> snapshot,
      ) {
        Widget child;
        if (snapshot.hasData) {
          child = MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Column(children: _buildTxListTiles(snapshot.data!)),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          child = Column(
            children: [
              Expanded(
                child: FutureBuilderWidgets.error(
                  context,
                  snapshot.error.toString(),
                ),
              )
            ],
          );
        } else {
          child = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FutureBuilderWidgets.circularProgressIndicator(),
              ),
            ],
          );
        }
        return Expanded(
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
            child: child,
          ),
        );
      },
    );
  }

  List<Padding> _buildTxListTiles(List<TransactionDetail> txList) {
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

  void _changeOnChainBalanceWidget() {
    onChainBalanceWidgetIndex >= _onChainBalanceWidgets.length - 1
        ? onChainBalanceWidgetIndex = 0
        : onChainBalanceWidgetIndex += 1;
  }

  _buttonBar() {
    return Padding(
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
              items: filters
                  .map((item) => DropdownMenuItem<TxSortType>(
                        value: item,
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ))
                  .toList(),
              value: selectedValue,
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
                if (!mounted) return;
                setState(() {
                  selectedValue = value as TxSortType;
                  _transactions = _getTransactions(_txSortType);
                });
              },
              buttonHeight: 40,
              buttonWidth: 140,
              itemHeight: 40,
              dropdownMaxHeight: 200,
              dropdownWidth: 140,
              dropdownPadding: EdgeInsets.only(bottom: 8),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
