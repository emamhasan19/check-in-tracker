import 'package:check_in_tracker/src/core/base/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/checkin_point.dart';
import '../../../core/theme/app_colors.dart';
import '../riverpod/dialog_ui_provider.dart';
import '../riverpod/map_provider.dart';

class EventDetailsDialog extends ConsumerStatefulWidget {
  final CheckinPoint checkinPoint;
  final bool isCheckedIn;
  final String? currentCheckinId;
  final bool isCreator;

  const EventDetailsDialog({
    super.key,
    required this.checkinPoint,
    required this.isCheckedIn,
    this.currentCheckinId,
    required this.isCreator,
  });

  @override
  ConsumerState<EventDetailsDialog> createState() => _EventDetailsDialogState();
}

class _EventDetailsDialogState extends ConsumerState<EventDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    final dialogState = ref.watch(dialogUiNotifierProvider);

    return AlertDialog(
      title: Align(
        alignment: Alignment.center,
        child: Text(
          widget.checkinPoint.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.8),
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.person,
                    AppConstants.createdBy,
                    widget.checkinPoint.creator.isNotEmpty
                        ? widget.checkinPoint.creator
                        : AppConstants.na,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on,
                    AppConstants.locationLabel,
                    '${widget.checkinPoint.lat.toStringAsFixed(6)}, ${widget.checkinPoint.lng.toStringAsFixed(6)}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.radio_button_checked,
                    AppConstants.radiusLabel,
                    '${widget.checkinPoint.radiusMeters.toInt()} ${AppConstants.meters}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.access_time,
                    AppConstants.createdAt,
                    _formatDate(
                      widget.checkinPoint.createdAt ?? DateTime.now(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Real-time Check-in Count and Users List Card
            StreamBuilder<int>(
              stream: ref
                  .read(mapNotifierProvider.notifier)
                  .getCheckinCountStream(widget.checkinPoint.id),
              builder: (context, countSnapshot) {
                final checkinCount = countSnapshot.data ?? 0;

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: ref
                      .read(mapNotifierProvider.notifier)
                      .getActiveCheckinUsersStream(widget.checkinPoint.id),
                  builder: (context, usersSnapshot) {
                    final checkinUsers = usersSnapshot.data ?? [];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Count Header
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Colors.green[700],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppConstants.activeCheckinsTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '$checkinCount ${AppConstants.people}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Users List
                          if (checkinUsers.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              AppConstants.checkedInUsers,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: checkinUsers.length,
                                itemBuilder: (context, index) {
                                  final user = checkinUsers[index];
                                  final userDisplayName =
                                      user['userDisplayName'] ??
                                      AppConstants.unknownUser;
                                  final userEmail = user['userEmail'];
                                  final userId = user['userId'].toString();

                                  String displayName;
                                  if (userDisplayName != null &&
                                      userDisplayName.isNotEmpty) {
                                    displayName = userDisplayName;
                                  } else if (userEmail != null &&
                                      userEmail.isNotEmpty) {
                                    displayName = userEmail.split('@').first;
                                  } else {
                                    displayName =
                                        '${AppConstants.userPrefix} ${userId.substring(0, 8)}';
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.green[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Status Card
            if (!widget.isCreator)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isCheckedIn
                      ? Colors.orange[50]
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isCheckedIn
                        ? Colors.orange[200]!
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isCheckedIn
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: widget.isCheckedIn
                          ? Colors.orange[700]
                          : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isCheckedIn
                            ? AppConstants.currentlyCheckedInToEvent
                            : AppConstants.notCheckedInToEvent,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: widget.isCheckedIn
                              ? Colors.orange[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
                  AppConstants.close,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12), // Gap between buttons
            if (widget.isCreator) ...[
              // Show delete button for creator
              Expanded(
                child: ElevatedButton(
                  onPressed: dialogState.isLoading ? null : _deleteEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 2,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: dialogState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : const Text(
                          AppConstants.deleteEvent,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ] else ...[
              // Show check-in/check-out buttons for other users
              if (widget.isCheckedIn) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: dialogState.isLoading ? null : _checkOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 2,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: dialogState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : const Text(
                            AppConstants.checkOut,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: dialogState.isLoading ? null : _checkIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 2,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: dialogState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : const Text(
                            AppConstants.checkIn,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ],
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
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            if (message.contains(AppConstants.tooFarMessage)) ...[
              const Text(
                AppConstants.tips,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(AppConstants.moveCloser),
              const Text(AppConstants.checkCorrectEvent),
              const Text(AppConstants.enableLocationServices),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(AppConstants.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _checkIn() async {
    ref.read(dialogUiNotifierProvider.notifier).updateIsLoading(true);

    try {
      final result = await ref
          .read(mapNotifierProvider.notifier)
          .checkInToPoint(widget.checkinPoint.id);

      result.when(
        success: (data) {
          if (mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppConstants.successfullyCheckedIn),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        failure: (error) {
          if (mounted) {
            // Show error dialog instead of just a snackbar
            _showErrorDialog('${AppConstants.checkinFailed} Failed', error);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          '${AppConstants.checkinFailed} Failed',
          '${AppConstants.unexpectedErrorOccurred}: $e',
        );
      }
    } finally {
      if (mounted) {
        ref.read(dialogUiNotifierProvider.notifier).updateIsLoading(false);
      }
    }
  }

  Future<void> _checkOut() async {
    ref.read(dialogUiNotifierProvider.notifier).updateIsLoading(true);

    try {
      if (widget.currentCheckinId != null) {
        final result = await ref
            .read(mapNotifierProvider.notifier)
            .checkOutFromPoint(widget.currentCheckinId!);

        result.when(
          success: (data) {
            if (mounted) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppConstants.successfullyCheckedOut),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          failure: (error) {
            if (mounted) {
              _showErrorDialog('${AppConstants.checkoutFailed} Failed', error);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          '${AppConstants.checkoutFailed} Failed',
          '${AppConstants.unexpectedErrorOccurred}: $e',
        );
      }
    } finally {
      if (mounted) {
        ref.read(dialogUiNotifierProvider.notifier).updateIsLoading(false);
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.deleteEvent),
        content: Text(
          '${AppConstants.deleteConfirmationMessage} "${widget.checkinPoint.name}"? ${AppConstants.deleteConfirmationDetails}',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => context.pop(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: AppColors.error.withValues(alpha: 0.4),
                width: 1.5,
              ),
              foregroundColor: AppColors.error.withValues(alpha: 0.6),
            ),
            child: const Text(
              AppConstants.cancel,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.5),
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 2,
              shadowColor: AppColors.error.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              AppConstants.deleteEvent,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ref.read(dialogUiNotifierProvider.notifier).updateIsLoading(true);

    try {
      await ref
          .read(mapNotifierProvider.notifier)
          .deleteCheckinPoint(widget.checkinPoint.id);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.eventDeletedSuccessfully),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.deleteFailed}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(dialogUiNotifierProvider.notifier).updateIsLoading(false);
      }
    }
  }
}
