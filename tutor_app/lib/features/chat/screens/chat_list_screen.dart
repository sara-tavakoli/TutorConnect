import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/chat_model.dart';
import '../../../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid  = auth.user?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor:    AppColors.white,
        surfaceTintColor:   Colors.transparent,
        title: Text('Messages', style: AppTextStyles.headlineMedium),
        centerTitle: false,
      ),
      body: uid == null
          ? const SizedBox()
          : StreamBuilder<List<ChatModel>>(
              stream: ChatService().getChats(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snap.data ?? [];

                if (chats.isEmpty) {
                  return _EmptyChats();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 80,
                    endIndent: 24,
                    color: AppColors.grey100,
                  ),
                  itemBuilder: (context, i) {
                    final chat = chats[i];
                    return _ChatTile(
                      chat:  chat,
                      myUid: uid,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId:        chat.id,
                            otherUserId:   chat.otherUserId(uid),
                            otherUserName: chat.otherUserName(uid),
                            otherUserPhoto: chat.otherUserPhoto(uid),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// ── Chat tile ──────────────────────────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String    myUid;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.myUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name      = chat.otherUserName(myUid);
    final photo     = chat.otherUserPhoto(myUid);
    final unread    = chat.unreadFor(myUid);
    final hasUnread = unread > 0;

    return Material(
      color: hasUnread ? AppColors.primarySurface.withValues(alpha: 0.4) : AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar
              _Avatar(name: name, photoUrl: photo),
              const SizedBox(width: 14),

              // Name + last message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      chat.lastMessage.isEmpty
                          ? 'Say hello!'
                          : chat.lastMessage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: hasUnread
                            ? AppColors.grey700
                            : AppColors.grey400,
                        fontWeight: hasUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Time + unread badge column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (chat.lastMessageAt != null)
                    Text(
                      _formatTime(chat.lastMessageAt!),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: hasUnread
                            ? AppColors.primary
                            : AppColors.grey400,
                        fontSize: 11,
                      ),
                    ),
                  if (hasUnread) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:        AppColors.primary,
                        borderRadius: AppRadius.fullAll,
                      ),
                      constraints: const BoxConstraints(minWidth: 20),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: AppTextStyles.labelSmall.copyWith(
                          color:       AppColors.white,
                          fontSize:    10,
                          letterSpacing: 0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date  = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return DateFormat.jm().format(dt);
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (now.difference(dt).inDays < 7) return DateFormat.E().format(dt);
    return DateFormat.MMMd().format(dt);
  }
}

// ── Avatar ─────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String  name;
  final String? photoUrl;

  const _Avatar({required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color:        AppColors.primarySurface,
        borderRadius: AppRadius.fullAll,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.fullAll,
        child: photoUrl != null
            ? CachedNetworkImage(
                imageUrl:    photoUrl!,
                fit:         BoxFit.cover,
                placeholder: (_, __) => _Initials(name: name),
                errorWidget: (_, __, ___) => _Initials(name: name),
              )
            : _Initials(name: name),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
        : '?';
    return Container(
      color: AppColors.primarySurface,
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary, fontSize: 18),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyChats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color:        AppColors.primarySurface,
                borderRadius: AppRadius.fullAll,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('No messages yet',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Find a tutor and tap "Message" on their profile to start a conversation.',
              style:     AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
