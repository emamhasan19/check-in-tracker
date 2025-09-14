import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/checkin_point.dart';
import '../../../core/theme/app_colors.dart';
import '../riverpod/checkin_point_dialog_provider.dart';
import '../riverpod/map_provider.dart';

class CheckinPointDialog extends ConsumerStatefulWidget {
  final CheckinPoint? existingPoint;
  final double? lat;
  final double? lng;

  const CheckinPointDialog({super.key, this.existingPoint, this.lat, this.lng});

  @override
  ConsumerState<CheckinPointDialog> createState() => _CheckinPointDialogState();
}

class _CheckinPointDialogState extends ConsumerState<CheckinPointDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _creatorController = TextEditingController();
  final _radiusController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    if (widget.existingPoint != null) {
      _nameController.text = widget.existingPoint!.name;
      _creatorController.text = widget.existingPoint!.createdBy;
      _radiusController.text = widget.existingPoint!.radiusMeters.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creatorController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPoint != null;
    final dialogState = ref.watch(checkinPointDialogNotifierProvider);

    return AlertDialog(
      title: Align(
        alignment: Alignment.center,
        child: Text(
          isEditing
              ? AppConstants.editCheckinPoint
              : AppConstants.createCheckinPoint,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppConstants.eventName,
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.pleaseEnterEventName;
                    }
                    if (value.length < 3) {
                      return AppConstants.eventNameMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _creatorController,
                  decoration: const InputDecoration(
                    labelText: AppConstants.createdByLabel,
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.pleaseEnterCreatorName;
                    }
                    if (value.length < 2) {
                      return AppConstants.creatorNameMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _radiusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: AppConstants.radiusMeters,
                    prefixIcon: Icon(Icons.radio_button_checked),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.pleaseEnterRadius;
                    }
                    final radius = double.tryParse(value);
                    if (radius == null || radius <= 0) {
                      return AppConstants.pleaseEnterValidRadius;
                    }
                    if (radius < 10) {
                      return AppConstants.radiusMinValue;
                    }
                    if (radius > 1000) {
                      return AppConstants.radiusMaxValue;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (widget.lat != null && widget.lng != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${AppConstants.locationLabel}: ${widget.lat!.toStringAsFixed(6)}, ${widget.lng!.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
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
                  AppConstants.cancel,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: dialogState.isLoading ? null : _createOrUpdatePoint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dialogState.isLoading
                      ? AppColors.grey
                      : AppColors.primary,
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
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        isEditing ? AppConstants.update : AppConstants.create,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
        // Error display
        if (dialogState.error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dialogState.error!,
                    style: TextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(checkinPointDialogNotifierProvider.notifier)
                        .clearError();
                  },
                  icon: Icon(Icons.close, color: AppColors.error, size: 18),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _createOrUpdatePoint() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(checkinPointDialogNotifierProvider.notifier).setLoading(true);

    try {
      final name = _nameController.text.trim();
      final creator = _creatorController.text.trim();
      final radius = double.parse(_radiusController.text.trim());

      if (widget.existingPoint != null) {
        await ref
            .read(mapNotifierProvider.notifier)
            .updateCheckinPoint(
              widget.existingPoint!.id,
              name: name,
              creator: creator,
              radiusMeters: radius,
            );
      } else {
        await ref
            .read(mapNotifierProvider.notifier)
            .createCheckinEvent(
              name: name,
              creator: creator,
              lat: widget.lat!,
              lng: widget.lng!,
              radiusMeters: radius,
            );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(checkinPointDialogNotifierProvider.notifier)
            .setError(e.toString());
      }
    }
  }
}
