import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

  factory TimeStampEmbed.fromDocument(Document document) => TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  static const String timeStampType = 'timeStamp';

  Document get document => Document.fromJson(jsonDecode(data.toString()) as List<dynamic>);
}

class TimeStampEmbedBuilderWidget extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data.toString();
  }

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(node.value.data as String),
      ],
    );
  }
}
