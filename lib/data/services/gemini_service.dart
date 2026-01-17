import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  // Using the same model for vision as valid for 1.5/2.5 flash models often support multimodal inputs
  // The user requested 'gemini-2.5-flash-preview' for all calls.
  static const String _modelName = 'gemini-2.5-flash';

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      // Safety settings can be adjusted here if needed
    );
  }

  /// Cognitive Accessibility: Simplifies complex text.
  Future<String> simplifyText(String originalText) async {
    final prompt =
        "Riscrivi il seguente testo in italiano estremamente semplice, breve e chiaro (livello A2). "
        "Usa frasi corte e dirette. Evita parole difficili. Testo originale: $originalText";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Impossibile semplificare il testo.";
    } catch (e) {
      debugPrint("Gemini simplifyText error: $e");
      return "Errore nella semplificazione del testo.";
    }
  }

  /// Motor & Social Accessibility: Generates smart replies.
  Future<List<String>> generateSmartReplies(String contextText) async {
    final prompt =
        "Leggi questo post e genera 3 risposte brevi (max 6-7 parole), gentili, incoraggianti e colloquiali in italiano."
        "Restituisci SOLO le risposte separate dal simbolo pipe '|'. Nient'altro. Post: $contextText";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text?.trim();

      if (text != null && text.isNotEmpty) {
        return text
            .split('|')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Gemini generateSmartReplies error: $e");
      return [];
    }
  }

  /// Autism Support / Social Cueing: Analyzes the tone of a draft message.
  /// Returns a map with 'emoji' and 'explanation'.
  Future<Map<String, String>> analyzeTone(String draftText) async {
    if (draftText.trim().isEmpty) return {};

    final prompt =
        "Analizza il tono di questo messaggio. Rispondi con una Emoji che riassume l'emozione principale e una brevissima frase (max 8 parole) "
        "che spiega come potrebbe essere percepito dagli altri. Formato: EMOJI: SPIEGAZIONE. Messaggio: $draftText";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text?.trim();

      if (text != null) {
        // Expected format: "😊: Sembra amichevole e gentile" or just "😊 Sembra..."
        // Let's try to split by first colon or space if colon missing
        String emoji = "";
        String explanation = "";

        final parts = text.split(':');
        if (parts.length >= 2) {
          emoji = parts[0].trim();
          explanation = parts.sublist(1).join(':').trim();
        } else {
          // Fallback separation
          final firstSpace = text.indexOf(' ');
          if (firstSpace != -1) {
            emoji = text.substring(0, firstSpace).trim();
            explanation = text.substring(firstSpace + 1).trim();
          } else {
            emoji = text; // Just emoji?
            explanation = "";
          }
        }
        return {'emoji': emoji, 'explanation': explanation};
      }
      return {};
    } catch (e) {
      debugPrint("Gemini analyzeTone error: $e");
      return {};
    }
  }

  /// Visual Accessibility: Generates Alt Text for an image.
  /// [imageBase64] should be the raw bytes or base64 string.
  /// The library supports Uint8List directly.
  Future<String> generateAltText(Uint8List imageBytes) async {
    final prompt =
        "Genera una descrizione 'Alt Text' per non vedenti di questa immagine. "
        "Sii oggettivo, descrivi gli elementi principali, i colori e l'atmosfera. Max 2 frasi.";

    try {
      // For images, we need to handle supported MIME types.
      // We assume JPEG or PNG. GenerativeModel handles it if we pass DataPart.
      // Defaulting to image/jpeg if unknown, but usually okay for generic vision tasks.
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "Descrizione non disponibile.";
    } catch (e) {
      debugPrint("Gemini generateAltText error: $e");
      return "Errore nella generazione della descrizione.";
    }
  }
}
