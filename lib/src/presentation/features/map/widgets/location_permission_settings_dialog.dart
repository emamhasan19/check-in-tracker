import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class LocationPermissionSettingsDialog extends StatelessWidget {
  const LocationPermissionSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: AppColors.error),
            SizedBox(width: 8),
            Text(AppConstants.locationPermissionRequiredTitle),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.locationPermissionRequiredDescription,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              AppConstants.locationPermissionPermanentlyDenied,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              AppConstants.stepsToEnableLocation,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${AppConstants.step1OpenSettings}\n'
              '${AppConstants.step2FindLocation}\n'
              '${AppConstants.step3EnablePermission}\n'
              '${AppConstants.step4ReturnToApp}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text(AppConstants.exitApp),
          ),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text(AppConstants.openSettings),
          ),
        ],
      ),
    );
  }
}
