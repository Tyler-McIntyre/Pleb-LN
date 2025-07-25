import 'dart:math' as math;

/// Bitcoin and Lightning Network utility functions

class BitcoinUtils {
  BitcoinUtils._();

  /// Satoshis per Bitcoin
  static const int satsPerBtc = 100000000;

  /// Convert satoshis to Bitcoin
  static double satsToBtc(int sats) {
    return sats / satsPerBtc;
  }

  /// Convert Bitcoin to satoshis
  static int btcToSats(double btc) {
    return (btc * satsPerBtc).round();
  }

  /// Format satoshis as Bitcoin string with specified decimal places
  static String formatSatsToBtc(int sats, {int decimals = 8}) {
    final btc = satsToBtc(sats);
    return btc.toStringAsFixed(decimals);
  }

  /// Format satoshis with unit
  static String formatSats(int sats, {bool showUnit = true}) {
    if (sats == 0) return showUnit ? '0 sats' : '0';
    
    final formatted = formatNumberWithCommas(sats);
    return showUnit ? '$formatted sats' : formatted;
  }

  /// Format amount intelligently (BTC for large amounts, sats for small)
  static String formatAmount(int sats, {bool preferBtc = false}) {
    if (sats == 0) return '0 sats';
    
    if (preferBtc || sats >= 1000000) { // >= 0.01 BTC
      final btc = satsToBtc(sats);
      if (btc >= 1) {
        return '${btc.toStringAsFixed(2)} BTC';
      } else {
        return '${btc.toStringAsFixed(4)} BTC';
      }
    }
    
    return formatSats(sats);
  }

  /// Validate Bitcoin address (basic validation)
  static bool isValidBitcoinAddress(String address) {
    if (address.isEmpty) return false;
    
    // Basic validation for common address formats
    // Legacy (P2PKH): starts with 1
    if (address.startsWith('1') && address.length >= 26 && address.length <= 35) {
      return true;
    }
    
    // Script Hash (P2SH): starts with 3
    if (address.startsWith('3') && address.length >= 26 && address.length <= 35) {
      return true;
    }
    
    // Bech32 (P2WPKH/P2WSH): starts with bc1
    if (address.startsWith('bc1') && address.length >= 42) {
      return true;
    }
    
    return false;
  }

  /// Validate Lightning invoice
  static bool isValidLightningInvoice(String invoice) {
    if (invoice.isEmpty) return false;
    
    // Lightning invoices start with 'lnbc' for mainnet
    return invoice.toLowerCase().startsWith('lnbc') ||
           invoice.toLowerCase().startsWith('lntb') || // testnet
           invoice.toLowerCase().startsWith('lnbcrt'); // regtest
  }

  /// Parse amount from Lightning invoice (simplified)
  static int? parseInvoiceAmount(String invoice) {
    try {
      // This is a simplified parser
      // In production, use a proper BOLT11 decoder
      final regex = RegExp(r'lnbc(\d+)([munp]?)');
      final match = regex.firstMatch(invoice.toLowerCase());
      
      if (match != null) {
        final amount = int.tryParse(match.group(1) ?? '');
        final multiplier = match.group(2);
        
        if (amount != null) {
          switch (multiplier) {
            case 'm': // milli-bitcoin (0.001 BTC)
              return amount * 100000; // 100k sats
            case 'u': // micro-bitcoin (0.000001 BTC)
              return amount * 100; // 100 sats
            case 'n': // nano-bitcoin (0.000000001 BTC)
              return (amount * 0.1).round();
            case 'p': // pico-bitcoin (0.000000000001 BTC)
              return (amount * 0.0001).round();
            default:
              return amount; // assume satoshis
          }
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    
    return null;
  }
}

/// Format numbers with thousand separators
String formatNumberWithCommas(num number) {
  return number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match match) => '${match[1]},',
  );
}

/// Format percentage with specified decimal places
String formatPercentage(double value, {int decimals = 1}) {
  return '${(value * 100).toStringAsFixed(decimals)}%';
}

/// Generate a random color for channels, nodes, etc.
int generateRandomColor() {
  final random = math.Random();
  return 0xFF000000 | random.nextInt(0xFFFFFF);
}

/// Abbreviate public keys for display
String abbreviateKey(String key, {int startChars = 6, int endChars = 6}) {
  if (key.length <= startChars + endChars + 3) {
    return key; // Too short to abbreviate
  }
  
  return '${key.substring(0, startChars)}...${key.substring(key.length - endChars)}';
}

/// Abbreviate transaction IDs
String abbreviateTxId(String txId) {
  return abbreviateKey(txId, startChars: 8, endChars: 8);
}

/// Calculate time ago string
String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  
  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months == 1 ? '' : 's'} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  } else {
    return 'Just now';
  }
}

/// Validate amount input
bool isValidAmount(String input) {
  if (input.isEmpty) return false;
  
  final number = double.tryParse(input);
  return number != null && number > 0;
}

/// Parse amount from string (handles both BTC and sat inputs)
int? parseAmount(String input, {bool assumeSats = false}) {
  if (input.isEmpty) return null;
  
  final cleaned = input.toLowerCase().replaceAll(RegExp(r'[^\d.]'), '');
  final number = double.tryParse(cleaned);
  
  if (number == null || number <= 0) return null;
  
  if (assumeSats || input.contains('sat')) {
    return number.round();
  } else {
    // Assume BTC if no unit specified
    return BitcoinUtils.btcToSats(number);
  }
}

/// Generate QR code data for Bitcoin/Lightning
String generateQRData({
  String? address,
  String? invoice,
  int? amount,
  String? label,
  String? message,
}) {
  if (invoice != null) {
    return invoice; // Lightning invoices are used as-is
  }
  
  if (address != null) {
    final uri = StringBuffer('bitcoin:$address');
    final params = <String>[];
    
    if (amount != null) {
      params.add('amount=${BitcoinUtils.satsToBtc(amount)}');
    }
    
    if (label != null) {
      params.add('label=${Uri.encodeComponent(label)}');
    }
    
    if (message != null) {
      params.add('message=${Uri.encodeComponent(message)}');
    }
    
    if (params.isNotEmpty) {
      uri.write('?${params.join('&')}');
    }
    
    return uri.toString();
  }
  
  return '';
}

/// Validate and normalize input
class InputValidator {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    if (!isValidAmount(value)) {
      return 'Invalid amount';
    }
    
    final amount = parseAmount(value);
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    return null;
  }
  
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (!BitcoinUtils.isValidBitcoinAddress(value)) {
      return 'Invalid Bitcoin address';
    }
    
    return null;
  }
  
  static String? validateInvoice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invoice is required';
    }
    
    if (!BitcoinUtils.isValidLightningInvoice(value)) {
      return 'Invalid Lightning invoice';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
