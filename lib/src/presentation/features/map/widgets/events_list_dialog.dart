import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import 'event_card.dart';

class EventsListDialog extends ConsumerStatefulWidget {
  final Function(String pointId, double lat, double lng) onViewOnMap;

  const EventsListDialog({super.key, required this.onViewOnMap});

  @override
  ConsumerState<EventsListDialog> createState() => _EventsListDialogState();
}

class _EventsListDialogState extends ConsumerState<EventsListDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.event, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          AppConstants.allEvents,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ref.read(getAllCheckinPointsWithCreatorsUseCaseProvider).call(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error);
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildEventsListView(events);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.failedToLoadEvents,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error?.toString() ?? AppConstants.unknownError,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppConstants.noEventsCreated,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.createFirstEvent,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsListView(List<Map<String, dynamic>> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(event: event, onTap: () => _handleEventTap(event));
      },
    );
  }

  void _handleEventTap(Map<String, dynamic> event) {
    final lat = event['latitude'] as double;
    final lng = event['longitude'] as double;
    final pointId = event['pointId'] as String;
    widget.onViewOnMap(pointId, lat, lng);
    context.pop();
  }
}
