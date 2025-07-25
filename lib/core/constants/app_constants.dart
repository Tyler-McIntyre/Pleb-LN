/// Application constants and configuration

class AppConstants {
  AppConstants._();

  /// App Information
  static const String appName = 'pleb-ln';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Lightning Network Wallet for Plebs';

  /// Network Configuration
  static const String defaultNetwork = 'mainnet';
  static const List<String> supportedNetworks = ['mainnet', 'testnet', 'regtest'];

  /// Default Values
  static const int defaultTimeoutMs = 30000;
  static const int defaultRetryAttempts = 3;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration defaultDebounceDelay = Duration(milliseconds: 500);

  /// UI Configuration
  static const double defaultBorderRadius = 16.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultElevation = 2.0;

  /// Bitcoin/Lightning Configuration
  static const int minChannelSize = 20000; // 20k sats minimum
  static const int maxChannelSize = 16777215; // Max channel size in sats
  static const int defaultFeeRate = 1; // sats per vbyte
  static const int minConfirmations = 3;
  static const Duration invoiceExpiry = Duration(hours: 24);

  /// Refresh Intervals
  static const Duration balanceRefreshInterval = Duration(seconds: 30);
  static const Duration channelRefreshInterval = Duration(minutes: 1);
  static const Duration transactionRefreshInterval = Duration(minutes: 2);
  static const Duration priceRefreshInterval = Duration(minutes: 5);

  /// Storage Keys
  static const String nodeConfigKey = 'node_config';
  static const String userPreferencesKey = 'user_preferences';
  static const String secureCredentialsKey = 'secure_credentials';
  static const String transactionHistoryKey = 'transaction_history';

  /// API Configuration
  static const String priceApiUrl = 'https://api.coingecko.com/api/v3';
  static const String explorerBaseUrl = 'https://mempool.space';
  static const String testnetExplorerUrl = 'https://mempool.space/testnet';

  /// Security
  static const int pinLength = 6;
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  /// Feature Flags
  static const bool enableBiometrics = true;
  static const bool enableLightningAddress = true;
  static const bool enableOnChainSweep = true;
  static const bool enableChannelBackups = true;
  static const bool enableTor = false; // Disabled by default

  /// Validation Limits
  static const int maxInvoiceDescriptionLength = 640;
  static const int maxNodeAliasLength = 32;
  static const int maxLabelLength = 100;
  static const double minBtcAmount = 0.00000001; // 1 sat
  static const double maxBtcAmount = 21000000.0; // Max Bitcoin supply

  /// UI Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  /// Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String nodeConnectionErrorMessage = 'Failed to connect to Lightning node. Please check your configuration.';
  static const String invalidAmountErrorMessage = 'Invalid amount. Please enter a valid number.';
  static const String insufficientBalanceErrorMessage = 'Insufficient balance for this transaction.';
  static const String invalidAddressErrorMessage = 'Invalid Bitcoin address format.';
  static const String invalidInvoiceErrorMessage = 'Invalid Lightning invoice format.';

  /// Success Messages
  static const String paymentSuccessMessage = 'Payment sent successfully!';
  static const String invoiceCreatedMessage = 'Invoice created successfully!';
  static const String channelOpenedMessage = 'Channel opened successfully!';
  static const String channelClosedMessage = 'Channel closed successfully!';

  /// File Extensions
  static const List<String> supportedImageFormats = ['.png', '.jpg', '.jpeg', '.gif'];
  static const List<String> supportedBackupFormats = ['.backup', '.json'];

  /// Regex Patterns
  static const String bitcoinAddressPattern = r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$|^bc1[a-z0-9]{39,59}$';
  static const String lightningInvoicePattern = r'^lnbc[0-9]+[munp]?1[02-9ac-hj-np-z]+$';
  static const String nodePublicKeyPattern = r'^[0-9a-fA-F]{66}$';
  static const String channelIdPattern = r'^[0-9]+x[0-9]+x[0-9]+$';

  /// Color Values (as hex strings for configuration)
  static const String primaryColorHex = '#2196F3';
  static const String bitcoinColorHex = '#FF9800';
  static const String successColorHex = '#4CAF50';
  static const String errorColorHex = '#F44336';
  static const String warningColorHex = '#FF9800';
}

/// Environment-specific configuration
class Environment {
  Environment._();

  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'production');

  static bool get isProduction => _environment == 'production';
  static bool get isDevelopment => _environment == 'development';
  static bool get isDebug => _environment == 'debug';

  /// Get appropriate configuration based on environment
  static String get apiBaseUrl {
    switch (_environment) {
      case 'development':
        return 'https://api-dev.example.com';
      case 'debug':
        return 'http://localhost:3000';
      default:
        return 'https://api.example.com';
    }
  }

  static String get bitcoinNetwork {
    switch (_environment) {
      case 'development':
      case 'debug':
        return 'testnet';
      default:
        return 'mainnet';
    }
  }

  static bool get enableLogging {
    return isDevelopment || isDebug;
  }
}

/// Bitcoin unit enumeration
enum BitcoinUnit {
  btc,
  mbtc, // milli-bitcoin
  sat,  // satoshi
}

extension BitcoinUnitExtension on BitcoinUnit {
  String get symbol {
    switch (this) {
      case BitcoinUnit.btc:
        return 'BTC';
      case BitcoinUnit.mbtc:
        return 'mBTC';
      case BitcoinUnit.sat:
        return 'sats';
    }
  }

  String get displayName {
    switch (this) {
      case BitcoinUnit.btc:
        return 'Bitcoin';
      case BitcoinUnit.mbtc:
        return 'milli-Bitcoin';
      case BitcoinUnit.sat:
        return 'Satoshis';
    }
  }

  int get multiplier {
    switch (this) {
      case BitcoinUnit.btc:
        return 100000000; // 1 BTC = 100M sats
      case BitcoinUnit.mbtc:
        return 100000; // 1 mBTC = 100k sats
      case BitcoinUnit.sat:
        return 1; // 1 sat = 1 sat
    }
  }
}

/// Application routes
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String send = '/send';
  static const String receive = '/receive';
  static const String channels = '/channels';
  static const String transactions = '/transactions';
  static const String settings = '/settings';
  static const String nodeConfig = '/settings/node';
  static const String security = '/settings/security';
  static const String about = '/settings/about';
  static const String backup = '/settings/backup';
}

/// Preferences keys for shared preferences
class PreferenceKeys {
  PreferenceKeys._();

  static const String isFirstLaunch = 'is_first_launch';
  static const String preferredUnit = 'preferred_unit';
  static const String enableNotifications = 'enable_notifications';
  static const String enableBiometrics = 'enable_biometrics';
  static const String autoLockTimeout = 'auto_lock_timeout';
  static const String hideSensitiveInfo = 'hide_sensitive_info';
  static const String selectedCurrency = 'selected_currency';
  static const String enableTor = 'enable_tor';
  static const String nodeHost = 'node_host';
  static const String nodePort = 'node_port';
  static const String macaroonPath = 'macaroon_path';
  static const String certPath = 'cert_path';
}
