part of '../home.dart'; // Ensure this path is correct

// Define a class for sample prompts
class _SamplePrompt {
  _SamplePrompt(this.text, this.type, {this.icon});
  final String text;
  final String type; // 'query' or 'action'
  final IconData? icon;
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // For scrolling to bottom

  // --- Sample Prompts Data ---
  final List<_SamplePrompt> _samplePrompts = [
    // _SamplePrompt("What are the latest market trends?", "query", icon: Icons.query_stats),
    // _SamplePrompt("Tell me a joke about business.", "query", icon: Icons.sentiment_very_satisfied),
    // _SamplePrompt("Draft an email to a new client.", "action", icon: Icons.edit_note),
    // _SamplePrompt("Summarize my upcoming tasks.", "action", icon: Icons.checklist),
    // _SamplePrompt("Compare product A and product B.", "query", icon: Icons.compare_arrows),
    // _SamplePrompt("Help me brainstorm ideas for a new marketing campaign.", "action", icon: Icons.lightbulb_outline),
    _SamplePrompt('Send reminder to customers with overdue invoices', 'action', icon: Icons.alarm_add),
    _SamplePrompt('How can i make a sale?', 'query', icon: Icons.question_mark),
    _SamplePrompt('Create an expense', 'action', icon: Icons.attach_money),
    _SamplePrompt('Get Sales Insight', 'query', icon: Icons.insights),
  ];

  @override
  void initState() {
    super.initState();
    // Ensure the socket attempts to connect when the screen is initialized.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still in the tree
        ref.read(socketNotifierProvider.notifier).ensureConnected();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Reusing Helper Widgets (can be moved to a common file if used elsewhere) ---

  // Helper to build the text part of a message with WhatsApp-style formatting (*bold*, _italic_)
  Widget _buildMessageTextContent(String text, bool isReceivedMessage, BuildContext context) {
    // Using DefaultTextStyle to inherit web's base text styles better
    final defaultStyle = DefaultTextStyle.of(context).style;
    final baseStyle = defaultStyle.copyWith(
      color: isReceivedMessage ? Colors.black87 : Colors.white,
      fontSize: 14, // Adjust as needed for web
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    final italicStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);
    final boldItalicStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
    );

    final spans = <TextSpan>[];
    var currentPosition = 0;

    // Process bold (*), italic (_), and combined (_*text*_) formatting
    while (currentPosition < text.length) {
      final boldMatch = RegExp(r'\*(.*?)\*').firstMatch(text.substring(currentPosition));
      final italicMatch = RegExp('_(.*?)_').firstMatch(text.substring(currentPosition));
      final combinedMatch = RegExp(r'_\*(.*?)\*_').firstMatch(text.substring(currentPosition));
      final combinedMatch2 = RegExp(r'\*_(.*?)_\*').firstMatch(text.substring(currentPosition));

      if (boldMatch == null && italicMatch == null && combinedMatch == null && combinedMatch2 == null) {
        // No more formatting found, add remaining text
        spans.add(TextSpan(text: text.substring(currentPosition), style: baseStyle));
        break;
      }

      // Determine which match comes first
      final firstMatch = [
        if (combinedMatch != null) combinedMatch,
        if (combinedMatch2 != null) combinedMatch2,
        if (boldMatch != null) boldMatch,
        if (italicMatch != null) italicMatch,
      ].reduce((a, b) => a.start < b.start ? a : b);

      final isCombined = firstMatch == combinedMatch || firstMatch == combinedMatch2;
      final isBold = firstMatch == boldMatch;

      // Add text before the formatting
      if (firstMatch.start > 0) {
        spans.add(
          TextSpan(
            text: text.substring(currentPosition, currentPosition + firstMatch.start),
            style: baseStyle,
          ),
        );
      }

      // Add formatted text
      final formattedText = firstMatch.group(1);
      if (formattedText != null && formattedText.isNotEmpty) {
        spans.add(
          TextSpan(
            text: formattedText,
            style: isCombined ? boldItalicStyle : (isBold ? boldStyle : italicStyle),
          ),
        );
      }

      currentPosition += firstMatch.end;
    }

    if (spans.isEmpty && text.isNotEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    } else if (spans.isEmpty && text.isEmpty) {
      spans.add(TextSpan(text: '', style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }

  // Helper to build buttons for a received message
  Widget _buildButtonsWidget(List<ChatMessageButton> buttons, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: buttons.map((button) {
          return ElevatedButton(
            onPressed: () {
              ref.read(socketNotifierProvider.notifier).sendButtonClick(button);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[50], // Lighter for web perhaps
              foregroundColor: Colors.blueGrey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: Text(button.title),
          );
        }).toList(),
      ),
    );
  }

  // Helper to build document preview for a received message
  Widget _buildDocumentWidget(ChatMessageDocument document, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: document.url != null || document.link != null
            ? () async {
                final docUrl = document.url ?? document.link;
                if (docUrl != null) {
                  // For web, url_launcher usually opens in a new tab
                  await launchUrl(Uri.parse(docUrl)); // Uncomment if using url_launcher
                  // html.window.open(docUrl, '_blank'); // Simple way to open in new tab
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening document: ${document.name ?? document.filename}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document URL not available')),
                  );
                }
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Important for Wrap to work correctly
            children: [
              Icon(Icons.insert_drive_file_outlined, color: Colors.grey[700], size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  document.name ?? document.filename ?? 'View Document',
                  style: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build file URL link for a received message
  Widget _buildFileUrlWidget(String fileUrl, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () async {
          await launchUrl(Uri.parse(fileUrl)); // Uncomment if using url_launcher
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_outlined, color: Colors.green[700], size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Download / View File',
                  style: TextStyle(color: Colors.green[800], decoration: TextDecoration.underline, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Main message building logic
  Widget _buildChatMessageWidget(ChatMessage msg, BuildContext context) {
    // Renamed for clarity
    if (msg.source == MessageSource.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              msg.text,
              style: const TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final isReceivedMessage = msg.source == MessageSource.received;
    final screenWidth = MediaQuery.of(context).size.width;
    // Max width for web can be larger or more dynamic
    final bubbleMaxWidth = screenWidth > 600.0 ? 500.0 : screenWidth * 0.7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: isReceivedMessage ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start, // Align avatar with top of bubble column
        children: [
          if (isReceivedMessage)
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 2), // Adjusted padding
              child: Assets.images.duxbeWhitebg.image(height: 36), // Ensure this asset is suitable
            ),
          Flexible(
            child: Column(
              // Use Column to stack text bubble and buttons/docs
              crossAxisAlignment: isReceivedMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isReceivedMessage ? const Color(0xFFF0F0F0) : AppColors.brandViolet, // Slightly different grey
                    borderRadius: BorderRadius.circular(18), // Slightly less rounded
                  ),
                  child: _buildMessageTextContent(msg.text, isReceivedMessage, context),
                ),
                // Conditionally render buttons, document, fileUrl
                if (isReceivedMessage && msg.buttons != null && msg.buttons!.isNotEmpty)
                  _buildButtonsWidget(msg.buttons!, context),
                if (isReceivedMessage && msg.document != null) _buildDocumentWidget(msg.document!, context),
                if (isReceivedMessage && msg.fileUrl != null && msg.fileUrl!.isNotEmpty)
                  _buildFileUrlWidget(msg.fileUrl!, context),
              ],
            ),
          ),
          if (!isReceivedMessage) // Placeholder for sender avatar if needed
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: AppColors.brandViolet,
                foregroundImage: ref.read(authNotifierProvider).user?.image != null
                    ? NetworkImage(ref.read(authNotifierProvider).user!.image!)
                    : Assets.images.photo.image().image,
                child: const Icon(Icons.person, color: AppColors.white),
              ),
            ), // Match the space of receiver avatar + padding
        ],
      ),
    );
  }

  void _sendMessage({String? text}) {
    // Allow passing text directly for query prompts
    final messageText = text ?? _controller.text.trim();
    if (messageText.isNotEmpty) {
      ref.read(socketNotifierProvider.notifier).sendMessage(messageText);
      if (text == null) {
        // Only clear controller if not from a direct query prompt
        _controller.clear();
      }
      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // --- Widget for Sample Prompts ---
  Widget _buildSamplePromptsWidget(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Try these prompts:',
              style: AppText.largeM.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _samplePrompts.map((prompt) {
                return InkWell(
                  onTap: () {
                    if (prompt.type == 'query') {
                      _sendMessage(text: prompt.text);
                    } else if (prompt.type == 'action') {
                      _controller.text = prompt.text;
                      // Optionally, could also request focus on the text field
                      // FocusScope.of(context).requestFocus(_textFieldFocusNode);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.brandViolet.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brandViolet.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (prompt.icon != null) Icon(prompt.icon, color: AppColors.brandViolet, size: 18),
                        if (prompt.icon != null) const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            prompt.text,
                            style: AppText.smallM.copyWith(color: AppColors.brandViolet),
                            // maxLines: 2,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Or, type your own message below.',
              textAlign: TextAlign.center,
              style: AppText.smallM.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(socketNotifierProvider);

    // Listen for new messages to scroll to bottom
    ref.listen<List<ChatMessage>>(socketNotifierProvider, (previousState, newState) {
      if (previousState != null && newState.length > previousState.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Container(
      // width: 400, // Example fixed width for chat panel on web
      decoration: AppStyles.boxDecoration, // Assuming AppStyles is defined
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20), // Adjusted padding
            decoration: const BoxDecoration(
              color: AppColors.primaryColor, // Assuming AppColors is defined
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Assets.icons.duxbeWhiteLogo.svg(height: 36), // Adjusted size
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.duxbe, // Assuming context.l10n is setup
                      style: AppText.largeM.copyWith(color: AppColors.white), // Assuming AppText
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AI',
                            style: AppText.smallB.copyWith(color: AppColors.brandViolet, fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Bot',
                          style: AppText.smallM.copyWith(color: AppColors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                // Spacer(), // Could add a close button or options here
                // IconButton(icon: Icon(Icons.close, color: AppColors.white), onPressed: () { /* close chat */ })
              ],
            ),
          ),
          // Message List or Sample Prompts
          Expanded(
            child: messages.isEmpty
                ? _buildSamplePromptsWidget(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatMessageWidget(messages[index], context); // Use the new method
                    },
                  ),
          ),
          const Divider(
            thickness: 1, // Thinner divider
            color: Color(0xffE0E0E0),
            height: 1,
          ),
          // Input Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted padding
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: context.l10n.typeAReply,
                      border: InputBorder.none, // Clean look
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.brandViolet),
                  onPressed: _sendMessage,
                  tooltip: 'Send message',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
