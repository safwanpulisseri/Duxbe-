import 'package:flutter/foundation.dart'; // For @required in older Freezed versions, or just general use
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.freezed.dart'; // Will be generated
part 'chat_model.g.dart'; // Will be generated

@freezed
class ChatMessageButton with _$ChatMessageButton {
  const factory ChatMessageButton({
    // The backend sends 'id' and 'title' in the 'reply' object for WhatsApp button replies
    // or directly as 'id' and 'title' for interactive message buttons.
    // We'll use JsonKey to map 'reply.id' to 'id' and 'reply.title' to 'title' if 'reply' exists.
    // The server-side response for buttons seems to be:
    // { "type": "button", "reply": { "id": "button_id_1", "title": "Button 1" } } (from WhatsApp)
    // or { "id": "button_id_1", "title": "Button 1" } (from direct interactive)
    // We need a robust way to parse this.
    // Let's assume the WebSocket response normalizes this to a flat structure like:
    // { "id": "some_id", "title": "Some Title" }
    // If not, the fromJson will be more complex or done in the notifier.
    // For now, let's assume the JSON is simple for the model.
    // The React example showed: response.buttons.map(button => ({ id: button.id, title: button.title || button.text }))
    // This implies the backend might send `text` sometimes instead of `title`.
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'title') required String title,
    // If your backend sometimes sends 'text' instead of 'title' for buttons,
    // you might need a custom converter or handle it in the `fromJson` of the parent.
    // For simplicity with Freezed, we expect a consistent 'title' field.
  }) = _ChatMessageButton;

  factory ChatMessageButton.fromJson(Map<String, dynamic> json) => _$ChatMessageButtonFromJson(json);
}

@freezed
class ChatMessageDocument with _$ChatMessageDocument {
  const factory ChatMessageDocument({
    // React example: msg.document.name || 'Untitled', msg.document.url
    // Let's assume JSON keys are 'name' and 'url'.
    // Adjust if backend sends 'filename' or 'link' as in your previous model.
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'url') String? url,
    @JsonKey(name: 'filename') String? filename, // For WhatsApp like documents
    @JsonKey(name: 'link') String? link, // For WhatsApp like documents
  }) = _ChatMessageDocument;

  factory ChatMessageDocument.fromJson(Map<String, dynamic> json) => _$ChatMessageDocumentFromJson(json);
}

enum MessageSource {
  sent,
  received,
  system,
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required MessageSource source,
    required String text,
    required DateTime timestamp,
    List<ChatMessageButton>? buttons,
    ChatMessageDocument? document,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'message_type') String? messageType,
    // Add any other fields you expect, e.g., senderName, avatarUrl etc.
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}
