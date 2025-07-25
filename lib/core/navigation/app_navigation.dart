import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/app_colors.dart';

/// Modern navigation system for the Lightning Network wallet

/// Navigation destinations
enum AppDestination {
  home,
  channels,
  transactions,
  settings,
}

extension AppDestinationExtension on AppDestination {
  String get label {
    switch (this) {
      case AppDestination.home:
        return 'Home';
      case AppDestination.channels:
        return 'Channels';
      case AppDestination.transactions:
        return 'Transactions';
      case AppDestination.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case AppDestination.home:
        return Icons.home_outlined;
      case AppDestination.channels:
        return Icons.hub_outlined;
      case AppDestination.transactions:
        return Icons.receipt_long_outlined;
      case AppDestination.settings:
        return Icons.settings_outlined;
    }
  }

  IconData get selectedIcon {
    switch (this) {
      case AppDestination.home:
        return Icons.home;
      case AppDestination.channels:
        return Icons.hub;
      case AppDestination.transactions:
        return Icons.receipt_long;
      case AppDestination.settings:
        return Icons.settings;
    }
  }
}

/// Navigation state notifier
class NavigationNotifier extends StateNotifier<AppDestination> {
  NavigationNotifier() : super(AppDestination.home);

  /// Navigate to a destination
  void navigateTo(AppDestination destination) {
    state = destination;
  }

  /// Navigate to home
  void goHome() => navigateTo(AppDestination.home);

  /// Navigate to channels
  void goToChannels() => navigateTo(AppDestination.channels);

  /// Navigate to transactions
  void goToTransactions() => navigateTo(AppDestination.transactions);

  /// Navigate to settings
  void goToSettings() => navigateTo(AppDestination.settings);
}

/// Current navigation destination provider
final navigationProvider = StateNotifierProvider<NavigationNotifier, AppDestination>(
  (ref) => NavigationNotifier(),
);

/// Current navigation index for BottomNavigationBar
final navigationIndexProvider = Provider<int>((ref) {
  final destination = ref.watch(navigationProvider);
  return AppDestination.values.indexOf(destination);
});

/// Modern bottom navigation bar
class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black2,
        border: Border(
          top: BorderSide(
            color: AppColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AppDestination.values.map((destination) {
              final index = AppDestination.values.indexOf(destination);
              final isSelected = index == currentIndex;
              
              return _NavigationItem(
                destination: destination,
                isSelected: isSelected,
                onTap: () {
                  ref.read(navigationProvider.notifier).navigateTo(destination);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item
class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.blue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? destination.selectedIcon : destination.icon,
                  color: isSelected ? AppColors.blue : AppColors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? AppColors.blue : AppColors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation rail for larger screens
class AppNavigationRail extends ConsumerWidget {
  const AppNavigationRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: AppColors.black2,
        border: Border(
          right: BorderSide(
            color: AppColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final destination = AppDestination.values[index];
          ref.read(navigationProvider.notifier).navigateTo(destination);
        },
        backgroundColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(
          color: AppColors.blue,
          size: 28,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.grey,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.blue,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.grey,
        ),
        destinations: AppDestination.values.map((destination) {
          return NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          );
        }).toList(),
      ),
    );
  }
}

/// Responsive navigation that switches between bottom bar and rail
class ResponsiveNavigation extends StatelessWidget {
  const ResponsiveNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use navigation rail for wider screens
        if (constraints.maxWidth >= 640) {
          return const AppNavigationRail();
        }
        // Use bottom navigation bar for mobile
        return const AppBottomNavigationBar();
      },
    );
  }
}
