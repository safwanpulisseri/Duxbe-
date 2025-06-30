part of '../dashboard_mobile.dart'; // Make sure this path is correct

class AiChatScreenMobile extends ConsumerStatefulWidget {
  const AiChatScreenMobile({super.key});

  @override
  ConsumerState<AiChatScreenMobile> createState() => _AiChatScreenMobileState();
}

class _AiChatScreenMobileState extends ConsumerState<AiChatScreenMobile> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  // Helper to build the text part of a message with markdown support for **bold**
  Widget _buildMessageTextContent(String text, bool isReceivedMessage) {
    final baseStyle = TextStyle(
      color: isReceivedMessage ? Colors.black87 : Colors.white,
      fontSize: 15, // Consistent font size
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

    final spans = <TextSpan>[];
    final exp = RegExp(r'\*\*(.*?)\*\*'); // Regex for **bold**
    var currentPosition = 0;

    for (final Match match in exp.allMatches(text)) {
      if (match.start > currentPosition) {
        spans.add(TextSpan(text: text.substring(currentPosition, match.start), style: baseStyle));
      }
      final boldText = match.group(1);
      if (boldText != null && boldText.isNotEmpty) {
        spans.add(TextSpan(text: boldText, style: boldStyle));
      }
      currentPosition = match.end;
    }

    if (currentPosition < text.length) {
      spans.add(TextSpan(text: text.substring(currentPosition), style: baseStyle));
    }

    if (spans.isEmpty && text.isNotEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    } else if (spans.isEmpty && text.isEmpty) {
      // Handle completely empty text if necessary, maybe show a placeholder or nothing
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
              backgroundColor: Colors.blueGrey[100], // A softer color for buttons
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(button.title),
          );
        }).toList(),
      ),
    );
  }

  // Helper to build document preview for a received message
  Widget _buildDocumentWidget(ChatMessageDocument document, BuildContext context) {
    // You might want to use a package like `url_launcher` to open the document URL
    // For now, just display its name and a link.
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: document.url != null
            ? () async {
                // Example using url_launcher:
                // if (await canLaunchUrl(Uri.parse(document.url!))) {
                //   await launchUrl(Uri.parse(document.url!));
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text('Could not open document: ${document.url}')),
                //   );
                // }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Document link: ${document.url ?? 'No URL'}')),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  document.name ?? document.filename ?? 'View Document',
                  style: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline),
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
          // Example using url_launcher:
          // if (await canLaunchUrl(Uri.parse(fileUrl))) {
          //   await launchUrl(Uri.parse(fileUrl));
          // } else {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('Could not open file: $fileUrl')),
          //   );
          // }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File link: $fileUrl')),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link, color: Colors.green[700]),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Download/View File',
                  style: TextStyle(color: Colors.green[800], decoration: TextDecoration.underline),
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
  Widget _buildMessage(ChatMessage msg, BuildContext context) {
    if (msg.source == MessageSource.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Increased vertical padding a bit
      child: Row(
        mainAxisAlignment: isReceivedMessage ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReceivedMessage)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4), // Align with top of bubble
              child: Assets.images.duxbeWhitebg.image(height: 32), // Adjusted size
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isReceivedMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.75), // Responsive max width
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isReceivedMessage ? const Color(0xFFF2F2F2) : AppColors.brandViolet,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildMessageTextContent(msg.text, isReceivedMessage),
                ),
                if (isReceivedMessage && msg.buttons != null && msg.buttons!.isNotEmpty)
                  _buildButtonsWidget(msg.buttons!, context),
                if (isReceivedMessage && msg.document != null) _buildDocumentWidget(msg.document!, context),
                if (isReceivedMessage && msg.fileUrl != null && msg.fileUrl!.isNotEmpty)
                  _buildFileUrlWidget(msg.fileUrl!, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(socketNotifierProvider); // Now List<ChatMessage>

    // Listen for changes in the socket state (received messages) for scrolling
    ref.listen<List<ChatMessage>>(socketNotifierProvider, (previousState, newState) {
      if (previousState != null && newState.length > previousState.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        // Assuming CustomAppBar is defined elsewhere
        title: Text(context.l10n.aiChat),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Assets.images.chatBg.image(fit: BoxFit.cover), // Assuming Assets is setup
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(messages[index], context); // Pass ChatMessage and context
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white, // Or Theme.of(context).cardColor, or transparent
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextForm<String>(
                          // Assuming AppTextForm is defined
                          name: 'message',
                          controller: _controller,
                          onSubmitted: (value) {
                            _sendMessage();
                          },
                          decoration: InputDecoration(
                            hintText: context.l10n.tellMeWhatDoYouWant,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Color(0xffD0D5DD)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Color(0xffD0D5DD)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  const BorderSide(color: Color(0xffD0D5DD)), // Consider a different color for focus
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Add some spacing
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.brandViolet, // Assuming AppColors is defined
                            shape: BoxShape.circle, // Make it circular for a common send button look
                          ),
                          child: const Icon(Icons.send, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      ref.read(socketNotifierProvider.notifier).sendMessage(_controller.text.trim());
      _controller.clear();
      // Optional: Immediate scroll to bottom for sent message,
      // though the listener will also handle it when the message list updates.
      // Consider if this immediate scroll is desired or if relying on the listener is enough.
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (mounted && _scrollController.hasClients) {
      //     _scrollController.animateTo(
      //       _scrollController.position.maxScrollExtent,
      //       duration: const Duration(milliseconds: 100),
      //       curve: Curves.easeOut,
      //     );
      //   }
      // });
    }
  }
}
