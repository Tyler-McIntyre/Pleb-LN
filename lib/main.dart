import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_navigation.dart';
import 'core/state/app_state.dart';
import 'core/error/error_handling.dart';
import 'shared/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: const PlebLnApp(),
    ),
  );
}

class PlebLnApp extends ConsumerWidget {
  const PlebLnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.defaultTheme,
      home: const AppShell(),
      builder: (context, child) {
        // Ensure text scaling is clamped to reasonable values
        final mediaQueryData = MediaQuery.of(context);
        final constrainedTextScaler = TextScaler.linear(
          mediaQueryData.textScaler.scale(1.0).clamp(0.8, 1.2),
        );

        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: constrainedTextScaler),
          child: child!,
        );
      },
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with ErrorHandlingMixin, WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize app after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
        // Handle inactive state if needed
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state if needed
        break;
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Set app as loading
      ref.read(appStateProvider.notifier).setLoading(true);
      
      // Initialize core services
      await _initializeServices();
      
      // Check node connection
      await _checkNodeConnection();
      
      // Mark initialization complete
      ref.read(appStateProvider.notifier).setLoading(false);
      
    } catch (e) {
      ref.read(appStateProvider.notifier).setError('Failed to initialize app: $e');
    }
  }

  Future<void> _initializeServices() async {
    // Initialize local storage, crypto, networking, etc.
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate initialization
  }

  Future<void> _checkNodeConnection() async {
    try {
      // Check Lightning node connection
      // This would typically call your LND client
      await Future.delayed(const Duration(seconds: 1)); // Simulate connection check
      
      ref.read(appStateProvider.notifier).setConnection(true);
      ref.read(appStateProvider.notifier).setNodeInfo(
        alias: 'Pleb Node',
        pubkey: '0234567890abcdef...',
      );
    } catch (e) {
      ref.read(appStateProvider.notifier).setConnection(false);
      throw Exception('Node connection failed: $e');
    }
  }

  void _onAppResumed() {
    // Refresh balances and connection status when app is resumed
    _checkNodeConnection();
  }

  void _onAppPaused() {
    // Clean up resources or save state when app is paused
  }

  void _onAppDetached() {
    // Final cleanup when app is closed
  }

  @override
  Widget build(BuildContext context) {
    final currentDestination = ref.watch(navigationProvider);
    final appState = ref.watch(appStateProvider);
    
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: appState.isLoading
            ? const LoadingScreen()
            : appState.error != null
                ? ErrorScreen(error: appState.error!)
                : _buildMainContent(currentDestination),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint
          ? const AppBottomNavigationBar()
          : null,
    );
  }

  Widget _buildMainContent(AppDestination destination) {
    return Row(
      children: [
        // Navigation rail for larger screens
        if (MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint)
          const AppNavigationRail(),
        
        // Main content area
        Expanded(
          child: _buildDestinationScreen(destination),
        ),
      ],
    );
  }

  Widget _buildDestinationScreen(AppDestination destination) {
    switch (destination) {
      case AppDestination.home:
        return const HomeScreen();
      case AppDestination.channels:
        return const ChannelsScreen();
      case AppDestination.transactions:
        return const TransactionsScreen();
      case AppDestination.settings:
        return const SettingsScreen();
    }
  }
}

/// Loading screen shown during app initialization
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.black, AppColors.black2],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.bolt,
                color: AppColors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              AppConstants.appName,
              style: GoogleFonts.lato(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Lightning Network Wallet',
              style: GoogleFonts.lato(
                fontSize: 16,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 48),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.blue),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Connecting to Lightning Network...',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown when app fails to initialize
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            
            Text(
              'Initialization Failed',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              error,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () {
                // Restart app or retry initialization
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Restart App'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screens - these would be implemented with your actual UI
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Home Screen',
        style: TextStyle(color: AppColors.white, fontSize: 24),
      ),
    );
  }
}

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Channels Screen',
        style: TextStyle(color: AppColors.white, fontSize: 24),
      ),
    );
  }
}

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Transactions Screen',
        style: TextStyle(color: AppColors.white, fontSize: 24),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Settings Screen',
        style: TextStyle(color: AppColors.white, fontSize: 24),
      ),
    );
  }
}
