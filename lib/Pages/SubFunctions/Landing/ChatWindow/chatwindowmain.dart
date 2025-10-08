import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:woodproposals/Provider/ai_textbox_reformat.dart';
import 'package:woodproposals/Provider/lessons_learned_provider.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Provider/project_provider.dart';
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
  late Future<void> _fetchDataFuture;

  /// -------------------------------------------------------------------------------------
  /// Initialize chat session ID
  @override
  void initState() {
    super.initState();
    final lessonsLearnedProvider = Provider.of<LessonsLearnedProvider>(context, listen: false);
    _chatSessionID = const Uuid().v4();

    _fetchDataFuture = fetchAppStartupInformation(lessonsLearnedProvider);
  }

  /// -------------------------------------------------------------------------------------
  /// Fetch app startup information
  Future<void> fetchAppStartupInformation(LessonsLearnedProvider lessonsLearnedProvider) async {
    await lessonsLearnedProvider.fetchLessonsLearned();
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
  /// Show lesson details by ID
  void _showLessonDetails(int lessonId) {
    final lessonsLearnedProvider = Provider.of<LessonsLearnedProvider>(context, listen: false);
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);
    final projectProvider = Provider.of<Projectprovider>(context, listen: false);
    
    // Find the lesson by ID
    final lesson = lessonsLearnedProvider.lessonsLearned.firstWhere(
      (l) => l['lessonID'] == lessonId,
      orElse: () => <String, dynamic>{},
    );
    
    if (lesson.isEmpty) {
      snackbar(context: context, header: 'Lesson not found with ID: $lessonId');
      return;
    }
    
    // Enhance lesson data with additional information
    final enhancedLesson = Map<String, dynamic>.from(lesson);
    
    // Add type description if available
    final llTypes = formStatusProvider.llTypes;
    final type = llTypes.firstWhere(
      (t) => t['typeID'] == lesson['type'],
      orElse: () => <String, dynamic>{},
    );
    if (type.isNotEmpty) {
      enhancedLesson['typeDescription'] = type['type'];
    }
    
    // Add project information if available
    final projects = projectProvider.projects;
    final project = projects.firstWhere(
      (p) => p['fld_ID'] == lesson['projectID'],
      orElse: () => <String, dynamic>{},
    );
    if (project.isNotEmpty) {
      enhancedLesson['projectNumber'] = project['fld_ProjectNo'];
    }
    
    _addEditLessonsLearnedContextWindow(enhancedLesson);
  }

  /// -------------------------------------------------------------------------------------
  /// View Lessons Learned Context Window
  void _addEditLessonsLearnedContextWindow([Map<String, dynamic>? lesson]) {
    if (lesson == null) return;
    
    final localAppTheme = ResponsiveTheme(context).theme;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Lesson Learned Details', style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'])),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lesson['projectNumber'] != null) ...[
                    _buildLessonDetailRow('Project:', lesson['projectNumber'].toString(), localAppTheme),
                    const SizedBox(height: 16),
                  ],
                  _buildLessonDetailRow('Lesson ID:', lesson['lessonID']?.toString() ?? 'N/A', localAppTheme),
                  const SizedBox(height: 16),
                  _buildLessonDetailRow('Lesson Title:', lesson['lessonTitle']?.toString() ?? 'N/A', localAppTheme),
                  const SizedBox(height: 16),
                  _buildLessonDetailRow('Date Raised:', lesson['dateRaised']?.toString().split('T')[0] ?? 'N/A', localAppTheme),
                  const SizedBox(height: 16),
                  _buildLessonDetailRow('Type:', lesson['typeDescription']?.toString() ?? lesson['type']?.toString() ?? 'N/A', localAppTheme),
                  const SizedBox(height: 16),
                  _buildLessonDetailRow('Cost Savings:', lesson['costSavings']?.toString() ?? 'N/A', localAppTheme),
                  const SizedBox(height: 16),
                  _buildLessonDetailSection('Event:', lesson['event']?.toString() ?? 'N/A', localAppTheme),
                  const SizedBox(height: 16),
                  _buildLessonDetailSection('Outcome:', lesson['outcome']?.toString() ?? 'N/A', localAppTheme),
                  const SizedBox(height: 16),
                  _buildLessonDetailSection('What is the Learning:', lesson['whatIsTheLearning']?.toString() ?? 'N/A', localAppTheme),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Close', style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'])),
            ),
          ],
        );
      },
    );
  }

  /// -------------------------------------------------------------------------------------
  /// Build lesson detail row for single line items
  Widget _buildLessonDetailRow(String label, String value, Map<String, dynamic> theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme['anchorColors']['primaryColor'],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// -------------------------------------------------------------------------------------
  /// Build lesson detail section for multi-line items
  Widget _buildLessonDetailSection(String label, String value, Map<String, dynamic> theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme['anchorColors']['primaryColor'],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
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
                      _showLessonDetails(id);
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