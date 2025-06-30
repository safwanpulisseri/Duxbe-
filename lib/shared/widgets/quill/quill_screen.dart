import 'package:duxbe/shared/widgets/quill/my_quill_editor.dart';
import 'package:duxbe/shared/widgets/quill/my_quill_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hancod_theme/hancod_theme.dart';

@immutable
class QuillScreenArgs {
  const QuillScreenArgs({required this.document});

  final Document document;
}

class QuillScreen extends StatefulWidget {
  const QuillScreen({
    required this.controller,
    super.key,
  });

  final QuillController controller;
  @override
  State<QuillScreen> createState() => _QuillScreenState();
}

class _QuillScreenState extends State<QuillScreen> {
  /// Instantiate the controller
  late QuillController _controller;
  final _editorFocusNode = FocusNode();
  final _editorScrollController = ScrollController();
  final _isReadOnly = false;
  var _isSpellcheckerActive = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.readOnly = _isReadOnly;
    if (!_isSpellcheckerActive) {
      _isSpellcheckerActive = true;
      // SpellChecker.useSpellCheckerService(
      //     Localizations.localeOf(context).languageCode);
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isReadOnly)
            MyQuillToolbar(
              controller: _controller,
              focusNode: _editorFocusNode,
            ),
          const Divider(color: AppColors.primaryColor, height: 2, thickness: 2),
          Builder(
            builder: (context) {
              return Expanded(
                child: MyQuillEditor(
                  controller: _controller,
                  configurations: QuillEditorConfigurations(
                    characterShortcutEvents: standardCharactersShortcutEvents,
                    spaceShortcutEvents: standardSpaceShorcutEvents,
                    searchConfigurations: const QuillSearchConfigurations(
                      searchEmbedMode: SearchEmbedMode.plainText,
                    ),
                  ),
                  scrollController: _editorScrollController,
                  focusNode: _editorFocusNode,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
