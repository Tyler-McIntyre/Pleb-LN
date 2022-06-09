import 'dart:async';

import 'package:firebolt/provider/balance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/lightning.pb.dart';
import '../rpc/lnd.dart';

class TransactionProvider {
  static LND _rpc = LND();
  static StateProvider<ListPaymentsResponse> payments =
      StateProvider<ListPaymentsResponse>((ref) => ListPaymentsResponse());
  static StateProvider<ListInvoiceResponse> invoices =
      StateProvider<ListInvoiceResponse>((ref) => ListInvoiceResponse());
  static AutoDisposeStreamProvider<Future<bool>> transactionStream =
      StreamProvider.autoDispose((ref) =>
          Stream.periodic(Duration(seconds: 15), ((_) async {
            ListPaymentsResponse payments = await _rpc.getPayments();
            ListInvoiceResponse invoices = await _rpc.listInvoices();

            ListPaymentsResponse currentPayments =
                ref.read(TransactionProvider.payments);
            ListInvoiceResponse currentInvoices =
                ref.read(TransactionProvider.invoices);

            bool newPayments = currentPayments != payments;
            bool newInvoices = currentInvoices != invoices;

            if (newPayments) {
              ref.read(TransactionProvider.payments.notifier).state = payments;
            }

            if (newInvoices) {
              ref.read(TransactionProvider.invoices.notifier).state = invoices;
            }

            if (newPayments || newInvoices) {
              WalletBalanceResponse walletBalance =
                  await _rpc.getWalletBalance();
              ref.read(BalanceProvider.onChainBalance.notifier).state =
                  walletBalance;
            }
            return true;
          })));
}



  // //fetch the current list and the new list of transactions (payments + invoices)
 