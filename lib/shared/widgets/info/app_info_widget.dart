import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/app_info_service.dart';
import '../../../util/app_colors.dart';

/// App and device information display widget
class AppInfoWidget extends ConsumerWidget {
  const AppInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appVersionAsync = ref.watch(appVersionProvider);
    final deviceInfoAsync = ref.watch(deviceInfoProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'App Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // App version info
          appVersionAsync.when(
            data: (version) => _buildInfoSection(
              'App Version',
              [
                _InfoItem('Name', version.appName),
                _InfoItem('Version', version.formattedVersion),
                _InfoItem('Package', version.packageName),
              ],
              theme,
            ),
            loading: () => _buildLoadingSection('App Version', theme),
            error: (error, stack) => _buildErrorSection('App Version', theme),
          ),
          
          const SizedBox(height: 16),
          
          // Device info
          deviceInfoAsync.when(
            data: (device) => _buildInfoSection(
              'Device Information',
              [
                _InfoItem('Platform', device.platformDisplayName),
                _InfoItem('Model', device.model),
                _InfoItem('System', device.systemVersion),
                _InfoItem('Physical Device', device.isPhysicalDevice ? 'Yes' : 'No'),
              ],
              theme,
            ),
            loading: () => _buildLoadingSection('Device Information', theme),
            error: (error, stack) => _buildErrorSection('Device Information', theme),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<_InfoItem> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  '${item.label}:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildLoadingSection(String title, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.blue),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorSection(String title, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Information unavailable',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact app version display for headers
class CompactVersionDisplay extends ConsumerWidget {
  const CompactVersionDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formattedVersion = ref.watch(formattedVersionProvider);

    return Text(
      'v$formattedVersion',
      style: theme.textTheme.bodySmall?.copyWith(
        color: AppColors.grey,
        fontSize: 12,
      ),
    );
  }
}

/// Platform indicator chip
class PlatformChip extends ConsumerWidget {
  const PlatformChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final platformName = ref.watch(platformNameProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.blue.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        platformName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.blue,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Info item model for display
class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}
