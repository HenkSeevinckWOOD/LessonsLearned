import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:woodproposals/Provider/ai_textbox_reformat.dart';
import 'package:woodproposals/Utilities/globalvariables.dart';
import 'package:woodproposals/Widgets/widgets.dart';

class ChatWindowMain extends StatefulWidget {
  const ChatWindowMain({super.key});

  @override
  State<ChatWindowMain> createState() => _ChatWindowMainState();
}

class _ChatWindowMainState extends State<ChatWindowMain> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late final String _chatSessionID;

  /// -------------------------------------------------------------------------------------
  /// Initialize chat session ID
  @override
  void initState() {
    super.initState();
    _chatSessionID = const Uuid().v4();
  }

  /// -------------------------------------------------------------------------------------
  /// Dispose controllers
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// -------------------------------------------------------------------------------------
  /// Send message
  Future<void> _sendMessage() async {
    final prompt = _textController.text.trim();
    if (prompt.isEmpty) return;

    // Add user message to the list
    setState(() {
      _messages.add({'sender': 'user', 'text': prompt});
    });
    _textController.clear();
    _scrollToBottom();

    final aiProvider = Provider.of<AITextboxReformat>(context, listen: false);

    // Get AI response
    final response = await aiProvider.getChatResponse(
      prompt: prompt,
      chatSessionID: _chatSessionID,
      context: context,
    );

    // Add AI response to the list
    if (response != null) {
      setState(() {
        // Get the applicable IDs from the provider and add them to the message map
        final applicableIDs = List<int>.from(aiProvider.applicableLessonsLearnedIDs);
        _messages.add({'sender': 'ai', 'text': response, 'lessons': applicableIDs});
      });
      _scrollToBottom();
    }
  }

  /// -------------------------------------------------------------------------------------
  /// Scroll to bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// -------------------------------------------------------------------------------------
  /// Build widget
  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AITextboxReformat>();
    final localAppTheme = ResponsiveTheme(context).theme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: header1(header: 'LESSONS LEARNED AI ASSISTANT', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
        backgroundColor: localAppTheme['anchorColors']['primaryColor'],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                final lessons = message['lessons'] as List<int>?;
                return _buildChatBubble(isUser, message['text']!, localAppTheme, lessons: lessons);
              },
            ),
          ),
          if (aiProvider.isLoading) const LinearProgressIndicator(),
          _buildMessageComposer(localAppTheme),
        ],
      ),
    );
  }

  /// -------------------------------------------------------------------------------------
  /// Build chat bubble
  Widget _buildChatBubble(bool isUser, String text, Map<String, dynamic> theme, {List<int>? lessons}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? theme['anchorColors']['primaryColor'] : theme['anchorColors']['secondaryColor'],
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14),
                strong: TextStyle(fontWeight: FontWeight.bold, color: isUser ? Colors.white : Colors.black87),
                listBullet: TextStyle(color: isUser ? Colors.white : Colors.black87),
                h1: TextStyle(color: isUser ? Colors.white : Colors.black87),
                h2: TextStyle(color: isUser ? Colors.white : Colors.black87),
                h3: TextStyle(color: isUser ? Colors.white : Colors.black87),
                em: TextStyle(fontStyle: FontStyle.italic, color: isUser ? Colors.white : Colors.black87),
              ),
            ),
            if (lessons != null && lessons.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: lessons.map((id) {
                  return TextButton.icon(
                    icon: Icon(Icons.link, size: 16, color: theme['anchorColors']['primaryColor']),
                    label: Text('Lesson $id', style: TextStyle(color: theme['anchorColors']['primaryColor'])),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      // TODO: Implement navigation to the specific lesson item.
                      snackbar(context: context, header: 'Navigate to Lesson ID: $id');
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// -------------------------------------------------------------------------------------
  /// Build message composer
  Widget _buildMessageComposer(Map<String, dynamic> theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5)]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Ask about lessons learned...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: theme['anchorColors']['primaryColor']),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}