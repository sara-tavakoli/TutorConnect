import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/message_model.dart';
import '../../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String  chatId;
  final String  otherUserId;
  final String  otherUserName;
  final String? otherUserPhoto;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller    = TextEditingController();
  final _scrollCtrl    = ScrollController();
  final _chatService   = ChatService();
  bool  _canSend       = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final canSend = _controller.text.trim().isNotEmpty;
      if (canSend != _canSend) setState(() => _canSend = canSend);
    });
    // Mark messages as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        _chatService.markAsRead(widget.chatId, uid);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve:    Curves.easeOut,
      );
    }
  }

  Future<void> _send(String myUid) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _chatService.sendMessage(
      chatId:     widget.chatId,
      senderId:   myUid,
      receiverId: widget.otherUserId,
      text:       text,
    );
    // slight delay so the new message doc arrives before scrolling
    await Future.delayed(const Duration(milliseconds: 150));
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final myUid = auth.user?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor:  AppColors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing:     0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.grey800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _MiniAvatar(name: widget.otherUserName, photoUrl: widget.otherUserPhoto),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUserName,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('TutorConnect',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snap.data ?? [];

                if (messages.isEmpty) {
                  return _EmptyConversation(name: widget.otherUserName);
                }

                // Auto-scroll when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller:  _scrollCtrl,
                  padding:     const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount:   messages.length,
                  itemBuilder: (_, i) {
                    final msg    = messages[i];
                    final isMe   = msg.senderId == myUid;
                    final prev   = i > 0 ? messages[i - 1] : null;
                    final showDate = prev == null ||
                        !_sameDay(prev.createdAt, msg.createdAt);

                    return Column(
                      children: [
                        if (showDate) _DateSeparator(date: msg.createdAt),
                        _MessageBubble(message: msg, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          _InputBar(
            controller: _controller,
            canSend:    _canSend,
            onSend:     () => _send(myUid),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Message bubble ─────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool         isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:  const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4  : 18),
          ),
          boxShadow: isMe ? [] : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color:  isMe ? AppColors.white : AppColors.grey900,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.jm().format(message.createdAt),
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                color: isMe
                    ? AppColors.white.withValues(alpha: 0.65)
                    : AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date separator ─────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(date.year, date.month, date.day);

    String label;
    if (d == today) {
      label = 'Today';
    } else if (d == today.subtract(const Duration(days: 1))) {
      label = 'Yesterday';
    } else {
      label = DateFormat.MMMd().format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Expanded(child: Divider(color: AppColors.grey200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
        ),
        const Expanded(child: Divider(color: AppColors.grey200)),
      ]),
    );
  }
}

// ── Input bar ──────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool         canSend;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left:   12,
        right:  12,
        top:    10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
            top: BorderSide(color: AppColors.grey100, width: 1)),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:        AppColors.grey100,
                borderRadius: AppRadius.fullAll,
              ),
              child: TextField(
                controller:  controller,
                minLines:    1,
                maxLines:    5,
                textCapitalization: TextCapitalization.sentences,
                style:       AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.grey900),
                decoration: InputDecoration(
                  hintText:      'Type a message…',
                  hintStyle:     AppTextStyles.bodyMedium,
                  border:        InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  filled: false,
                ),
                onSubmitted: canSend ? (_) => onSend() : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: canSend ? AppColors.primary : AppColors.grey200,
              borderRadius: AppRadius.fullAll,
            ),
            child: Material(
              color:        Colors.transparent,
              borderRadius: AppRadius.fullAll,
              child: InkWell(
                borderRadius: AppRadius.fullAll,
                onTap:        canSend ? onSend : null,
                child: Icon(
                  Icons.send_rounded,
                  size:  18,
                  color: canSend ? AppColors.white : AppColors.grey400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini avatar for app bar ────────────────────────────────────────────────────

class _MiniAvatar extends StatelessWidget {
  final String  name;
  final String? photoUrl;
  const _MiniAvatar({required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
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
                placeholder: (_, __) => _Initial(name: name),
                errorWidget: (_, __, ___) => _Initial(name: name),
              )
            : _Initial(name: name),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});
  @override
  Widget build(BuildContext context) {
    final ch = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.primarySurface,
      alignment: Alignment.center,
      child: Text(ch,
          style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary, fontSize: 15)),
    );
  }
}

// ── Empty conversation ─────────────────────────────────────────────────────────

class _EmptyConversation extends StatelessWidget {
  final String name;
  const _EmptyConversation({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color:        AppColors.primarySurface,
                borderRadius: AppRadius.fullAll,
              ),
              child: const Icon(Icons.waving_hand_rounded,
                  size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Start the conversation!',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Say hi to $name and ask anything about their sessions.',
              style:     AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
