import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_top_bar.dart';
import '../../../../core/utils/formatters.dart';
import '../bloc/notifications_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsBloc()..add(LoadNotificationsEvent()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          appBar: const NajmaTopBar(title: 'الإشعارات'),
          body: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoading)
                return const Center(child: CircularProgressIndicator(color: NajmaColors.gold));
              if (state is NotificationsError)
                return Center(child: Text(state.message, style: NajmaTextStyles.body()));
              if (state is NotificationsLoaded) {
                if (state.notifications.isEmpty)
                  return Center(child: Text('لا توجد إشعارات', style: NajmaTextStyles.body(color: NajmaColors.textDim)));
                return ListView.separated(
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E1E1E), height: 1),
                  itemBuilder: (ctx, i) {
                    final n = state.notifications[i];
                    return ListTile(
                      tileColor: n.isRead ? Colors.transparent : NajmaColors.gold.withOpacity(0.04),
                      leading: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: n.isRead ? Colors.transparent : NajmaColors.gold,
                        ),
                      ),
                      title: Text(n.title, style: NajmaTextStyles.body(size: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.body, style: NajmaTextStyles.caption()),
                          Text(NajmaFormatters.timeAgo(n.createdAt),
                              style: NajmaTextStyles.caption(size: 10, color: NajmaColors.textDim)),
                        ],
                      ),
                      onTap: () => context.read<NotificationsBloc>().add(MarkReadEvent(n.id)),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
