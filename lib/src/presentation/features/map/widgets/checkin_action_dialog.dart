import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/checkin_point.dart';
import '../../../core/theme/app_colors.dart';
import '../riverpod/map_provider.dart';
import 'checkin_point_dialog.dart';

class CheckinActionDialog extends ConsumerWidget {
  final CheckinPoint checkinPoint;
  final bool isWithinRadius;

  const CheckinActionDialog({
    super.key,
    required this.checkinPoint,
    required this.isWithinRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(
        checkinPoint.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.location_on,
            AppConstants.locationLabel,
            '${checkinPoint.lat.toStringAsFixed(6)}, ${checkinPoint.lng.toStringAsFixed(6)}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.radio_button_checked,
            AppConstants.radiusLabel,
            '${checkinPoint.radiusMeters.toInt()} meters',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.person,
            AppConstants.createdBy,
            checkinPoint.creator.isNotEmpty
                ? checkinPoint.creator
                : AppConstants.unknownUser,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            AppConstants.createdAt,
            _formatDate(checkinPoint.createdAt ?? DateTime.now()),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWithinRadius ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isWithinRadius ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isWithinRadius ? Icons.check_circle : Icons.warning,
                  color: isWithinRadius ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isWithinRadius
                        ? AppConstants.withinCheckinArea
                        : AppConstants.outsideCheckinArea,
                    style: TextStyle(
                      color: isWithinRadius
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  foregroundColor: AppColors.primary,
                ),
                child: const Text(
                  AppConstants.cancel,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isWithinRadius) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _checkIn(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    AppConstants.checkIn,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () => _createNewEvent(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  AppConstants.createNewEvent,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(mapNotifierProvider.notifier)
          .checkInToPoint(checkinPoint.id);

      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successfullyCheckedIn),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.checkinFailed}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _createNewEvent(BuildContext context) {
    context.pop();
    showDialog(
      context: context,
      builder: (context) =>
          CheckinPointDialog(lat: checkinPoint.lat, lng: checkinPoint.lng),
    );
  }
}
