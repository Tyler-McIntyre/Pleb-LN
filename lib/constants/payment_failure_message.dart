import '../generated/lightning.pb.dart';

class PaymentFailure {
  static String getMessage(PaymentFailureReason reason) {
    switch (reason) {
      case (PaymentFailureReason.FAILURE_REASON_ERROR):
        return 'Unable to complete the payment at this time. Try again later.';
      case (PaymentFailureReason.FAILURE_REASON_INCORRECT_PAYMENT_DETAILS):
        return 'Invalid payment details';
      case (PaymentFailureReason.FAILURE_REASON_NONE):
        return 'Failure reason, none';
      case (PaymentFailureReason.FAILURE_REASON_INSUFFICIENT_BALANCE):
        return 'Insufficient balance';
      case (PaymentFailureReason.FAILURE_REASON_NO_ROUTE):
        return 'No route';
      case (PaymentFailureReason.FAILURE_REASON_TIMEOUT):
        return 'Request has timed out';
      default:
        return 'An unknown error has occured';
    }
  }
}
