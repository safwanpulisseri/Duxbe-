part of 'item_details_mobile.dart';

class RichTextScreen extends StatefulWidget {
  const RichTextScreen({required this.richText, super.key});

  final String? richText;

  @override
  State<RichTextScreen> createState() => _RichTextScreenState();
}

class _RichTextScreenState extends State<RichTextScreen> {
  final QuillController _quillController = QuillController.basic();

  @override
  void initState() {
    super.initState();
    if (widget.richText != null) {
      _quillController.document = Document.fromJson(jsonDecode(widget.richText!) as List<dynamic>);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title:  Text(context.l10n.description),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: AppButton(
          onPress: () {
            context.pop(jsonEncode(_quillController.document.toDelta().toJson()));
          },
          label:  Text(context.l10n.save),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: QuillScreen(controller: _quillController),
      ),
    );
  }
}
