import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/domain/usecases/vision_notification_usecase.dart';
import 'package:thermal_mobile/presentation/bloc/vision_notification/vision_notification_bloc.dart';
import 'vision_notification_detail_screen.dart';

/// Vision Notification List Screen
class VisionNotificationListScreen extends StatelessWidget {
  const VisionNotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VisionNotificationBloc(
        getVisionNotificationsUseCase: getIt<GetVisionNotificationsUseCase>(),
      )..add(
          FetchVisionNotifications(
            fromTime: _formatDateTime(
                DateTime.now().subtract(const Duration(days: 7))),
            toTime: _formatDateTime(DateTime.now()),
            areaId: 5,
            cameraId: 3,
            warningEventId: 2,
            page: 1,
            pageSize: 20,
          ),
        ),
      child: const _VisionNotificationListView(),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}

class _VisionNotificationListView extends StatefulWidget {
  const _VisionNotificationListView();

  @override
  State<_VisionNotificationListView> createState() =>
      _VisionNotificationListViewState();
}

class _VisionNotificationListViewState
    extends State<_VisionNotificationListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<VisionNotificationBloc>().add(LoadMoreVisionNotifications());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Notifications'),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<VisionNotificationBloc>()
                  .add(RefreshVisionNotifications());
            },
          ),
        ],
      ),
      body: BlocBuilder<VisionNotificationBloc, VisionNotificationState>(
        builder: (context, state) {
          if (state is VisionNotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is VisionNotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<VisionNotificationBloc>()
                          .add(RefreshVisionNotifications());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is VisionNotificationLoaded ||
              state is VisionNotificationLoadingMore) {
            final notifications = state is VisionNotificationLoaded
                ? state.notifications
                : (state as VisionNotificationLoadingMore).currentNotifications;

            final hasReachedMax =
                state is VisionNotificationLoaded && state.hasReachedMax;

            if (notifications.items.isEmpty) {
              return const Center(
                child: Text('No notifications found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<VisionNotificationBloc>()
                    .add(RefreshVisionNotifications());
                // Wait for refresh to complete
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: notifications.items.length + (hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= notifications.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final item = notifications.items[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: item.imagePath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                item.imagePath,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.image),
                            ),
                      title: Text(
                        item.warningEventName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('📍 ${item.areaName}'),
                          Text('📷 ${item.cameraName}'),
                          Text('🕐 ${item.formattedDate}'),
                        ],
                      ),
                      trailing: Icon(
                        item.inArea ? Icons.warning : Icons.info_outline,
                        color: item.inArea ? Colors.orange : Colors.blue,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                VisionNotificationDetailScreen(
                              notification: item,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
      floatingActionButton: BlocBuilder<VisionNotificationBloc,
          VisionNotificationState>(
        builder: (context, state) {
          if (state is VisionNotificationLoaded) {
            return FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.info_outline),
              label: Text('Total: ${state.notifications.totalRow}'),
              backgroundColor: AppColors.primaryDark,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
