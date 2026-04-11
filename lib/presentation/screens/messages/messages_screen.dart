import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../data/models/message.dart' as msg;

/// Messages Screen - Conversations list
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).loadConversations();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(conversationsProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading) {
      final nextPage = (state.conversations.length ~/ 10) + 1;
      ref.read(conversationsProvider.notifier).loadConversations(page: nextPage);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ConversationsState state) {
    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.conversations.isEmpty) {
      return WaveErrorBanner(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(conversationsProvider.notifier).loadConversations();
        },
      );
    }

    if (state.conversations.isEmpty) {
      return WaveEmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'No Messages Yet',
        subtitle: 'Start a conversation about a property by tapping the message icon on a listing',
        actionLabel: 'Browse Properties',
        onAction: () {
          // Navigate to home tab (index 0)
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(conversationsProvider.notifier).loadConversations();
      },
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.conversations.length + (state.isLoading ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= state.conversations.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final conversation = state.conversations[index] as msg.Conversation;
          return _ConversationTile(
            conversation: conversation,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(conversationId: conversation.id, conversation: conversation),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Conversation Tile Widget
class _ConversationTile extends ConsumerWidget {
  final msg.Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  String _getOtherUserName() {
    if (conversation.subject != null && conversation.subject!.isNotEmpty) {
      return conversation.subject!;
    }
    // Try to extract from listing title
    return 'Conversation #${conversation.id}';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.user?.id ?? 0;
    
    // Determine the other participant
    String displayName = _getOtherUserName();
    String initials = _getInitials(displayName);
    
    final isSeller = conversation.senderId == currentUserId;
    // In a real scenario, you'd fetch the other user's name from the conversation
    // For now, use a generic approach
    if (displayName.startsWith('Conversation #')) {
      displayName = isSeller ? 'Buyer' : 'Seller';
      initials = isSeller ? 'BY' : 'SL';
    }

    final hasUnread = conversation.unreadCount != null && conversation.unreadCount! > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: hasUnread ? AppColors.wave500 : AppColors.navy200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: hasUnread ? Colors.white : AppColors.navy700,
            ),
          ),
        ),
      ),
      title: Text(
        displayName,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        conversation.previewText,
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageAt != null)
            Text(
              _formatTime(conversation.lastMessageAt),
              style: AppTextStyles.caption.copyWith(
                color: hasUnread ? AppColors.wave600 : AppColors.zinc400,
              ),
            ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.wave500,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

/// Chat Screen - Individual conversation with full messaging
class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final msg.Conversation conversation;

  const ChatScreen({super.key, required this.conversationId, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final success = await ref.read(chatMessagesProvider(widget.conversationId).notifier).sendMessage(text);

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listScrollController.hasClients) {
        _listScrollController.animateTo(
          _listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatMessagesProvider(widget.conversationId));
    
    // Get conversation title from listing or other user
    String title = widget.conversation.subject ?? 'Conversation';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chatState.errorMessage != null && chatState.messages.isEmpty
                    ? WaveErrorBanner(
                        message: chatState.errorMessage!,
                        onRetry: () {
                          ref.read(chatMessagesProvider(widget.conversationId).notifier).loadMessages();
                        },
                      )
                    : chatState.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.navy300),
                                const SizedBox(height: 16),
                                Text('No messages yet', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.navy500)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _listScrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: chatState.messages.length,
                            itemBuilder: (context, index) {
                              return _MessageBubble(message: chatState.messages[index]);
                            },
                          ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isSending ? AppColors.zinc400 : AppColors.wave500,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Message Bubble Widget
class _MessageBubble extends ConsumerWidget {
  final msg.Message message;

  const _MessageBubble({required this.message});

  String _getInitials(int senderId, int currentUserId) {
    // For simplicity, use generic initials
    // In production, you'd fetch the actual user's name
    if (senderId == currentUserId) return 'YO';
    return 'OT';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.user?.id ?? 0;
    final isOwn = message.senderId == currentUserId;
    final isSeen = message.readAt != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for incoming messages
          if (!isOwn) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.navy200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'OT',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isOwn ? AppColors.wave500 : AppColors.zinc100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isOwn ? 16 : 4),
                  bottomRight: Radius.circular(isOwn ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: TextStyle(
                      color: isOwn ? Colors.white : AppColors.zinc800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.displayTime,
                        style: TextStyle(
                          color: isOwn ? Colors.white.withOpacity(0.7) : AppColors.zinc400,
                          fontSize: 10,
                        ),
                      ),
                      if (isOwn) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isSeen ? Icons.done_all : Icons.done,
                          size: 14,
                          color: isSeen
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.5),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Avatar for outgoing messages
          if (isOwn) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.wave200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'YO',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.wave700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
