import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';

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
      ref
          .read(conversationsProvider.notifier)
          .loadConversations(page: nextPage);
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
    // Loading state
    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.errorMessage != null && state.conversations.isEmpty) {
      return WaveErrorBanner(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(conversationsProvider.notifier).loadConversations();
        },
      );
    }

    // Empty state
    if (state.conversations.isEmpty) {
      return WaveEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No Messages Yet',
        subtitle: 'Start a conversation about a property',
      );
    }

    // Conversations list
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

          final conversation = state.conversations[index];
          return _ConversationTile(
            conversation: conversation,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(conversation: conversation),
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
class _ConversationTile extends StatelessWidget {
  final dynamic conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount != null && conversation.unreadCount > 0;

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: hasUnread ? AppColors.wave100 : AppColors.navy50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          hasUnread ? Icons.chat : Icons.chat_bubble_outline,
          size: 24,
          color: hasUnread ? AppColors.wave600 : AppColors.navy400,
        ),
      ),
      title: Text(
        conversation.displayTitle ?? 'Conversation',
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        conversation.previewText ?? '',
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

/// Chat Screen - Individual conversation
class ChatScreen extends ConsumerStatefulWidget {
  final dynamic conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // TODO: Load messages for this conversation
  }

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

    // TODO: Call message service to send message
    // For now, just clear the input

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.displayTitle ?? 'Chat'),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.navy300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Messages coming soon',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.navy500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.wave500,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
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
