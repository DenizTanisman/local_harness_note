import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';

/// Where the on-device model stands.
sealed class GemmaStatus {
  const GemmaStatus();
}

class GemmaUnknown extends GemmaStatus {
  const GemmaUnknown();
}

class GemmaNotInstalled extends GemmaStatus {
  const GemmaNotInstalled();
}

class GemmaDownloading extends GemmaStatus {
  const GemmaDownloading(this.percent);
  final int percent;
}

class GemmaReady extends GemmaStatus {
  const GemmaReady();
}

class GemmaFailed extends GemmaStatus {
  const GemmaFailed(this.message);
  final String message;
}

/// On-device Gemma (spec §5): Gemma 4 E2B via LiteRT-LM, downloaded once
/// (no account needed — Apache 2.0), then fully offline.
class GemmaService {
  GemmaService();

  static const modelFile = 'gemma-4-E2B-it.litertlm';
  static const modelUrl =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/'
      'resolve/main/$modelFile';
  static const modelSizeLabel = '2,6 GB';

  static const promptKey = 'gemma_prompt';
  static const noteSlot = '{{not}}';
  static const defaultPrompt =
      'Aşağıdaki notu Türkçe olarak toparla. Ana fikirleri koru, tekrarları '
      'çıkar, gerekiyorsa maddeler halinde düzenle. Notta olmayan bilgi '
      'ekleme.\n'
      'Kurallar:\n'
      '- İlk satır kısa bir başlık olsun.\n'
      '- Düz metin yaz: Markdown kullanma (**, ##, * yok); madde için '
      '"- " kullan.\n'
      '- En son satıra yalnızca notta geçen #etiketleri yaz (örnek: '
      '#fikir #proje); önüne başka kelime koyma. Etiket yoksa bu satırı '
      'yazma.\n'
      '- Sadece düzenlenmiş notu yaz, açıklama ekleme.\n\n'
      'NOT:\n$noteSlot';

  /// Fills [template]'s `{{not}}` with [note] (appended when missing).
  static String buildPrompt(String? template, String note) {
    final t = (template == null || template.trim().isEmpty)
        ? defaultPrompt
        : template;
    return t.contains(noteSlot) ? t.replaceAll(noteSlot, note) : '$t\n\n$note';
  }

  final status = ValueNotifier<GemmaStatus>(const GemmaUnknown());

  bool _initialized = false;
  CancelToken? _download;
  InferenceModel? _model;
  InferenceModelSession? _session;

  Future<void> _init() async {
    if (_initialized) return;
    await FlutterGemma.initialize(inferenceEngines: [LiteRtLmEngine()]);
    _initialized = true;
  }

  InferenceInstallationBuilder _builder() => FlutterGemma.installModel(
    modelType: ModelType.gemma4,
    fileType: ModelFileType.litertlm,
  );

  Future<void> refresh() async {
    if (status.value is GemmaDownloading) return;
    try {
      await _init();
      status.value = await FlutterGemma.isModelInstalled(modelFile)
          ? const GemmaReady()
          : const GemmaNotInstalled();
    } catch (e) {
      status.value = GemmaFailed('$e');
    }
  }

  /// Downloads the model (foreground service with a progress notification,
  /// resumes after network drops).
  Future<void> download() async {
    if (status.value is GemmaDownloading) return;
    await _init();
    final token = _download = CancelToken();
    status.value = const GemmaDownloading(0);
    try {
      await _builder()
          .fromNetwork(modelUrl, foreground: true)
          .withProgress((p) => status.value = GemmaDownloading(p))
          .withCancelToken(token)
          .install();
      status.value = const GemmaReady();
    } on DownloadCancelledException {
      status.value = const GemmaNotInstalled();
    } catch (e) {
      status.value = GemmaFailed('İndirme başarısız: $e');
    } finally {
      _download = null;
    }
  }

  void cancelDownload() => _download?.cancel('Kullanıcı iptal etti');

  Future<void> deleteModel() async {
    await _closeModel();
    try {
      await FlutterGemma.uninstallModel(modelFile);
    } catch (_) {
      // Already gone.
    }
    status.value = const GemmaNotInstalled();
  }

  Future<InferenceModel> _ensureModel() async {
    await _init();
    if (_model != null) return _model!;
    if (!await FlutterGemma.isModelInstalled(modelFile)) {
      throw StateError('Gemma modeli yüklü değil. Ayarlar’dan indir.');
    }
    // Idempotent: the file is on disk, so this only marks it active.
    await _builder().fromNetwork(modelUrl).install();
    // CPU: Gemma 4 on GPU can garble digits (dates in merged notes).
    return _model = await FlutterGemma.getActiveModel(
      maxTokens: 4096,
      preferredBackend: PreferredBackend.cpu,
    );
  }

  /// Streams Gemma's answer to [prompt], token by token.
  Stream<String> generate(String prompt) async* {
    final model = await _ensureModel();
    await _session?.close();
    final session = _session = await model.createSession(
      temperature: 0.4,
      topK: 40,
      maxOutputTokens: 2048,
    );
    try {
      await session.addQueryChunk(Message(text: prompt, isUser: true));
      yield* session.getResponseAsync();
    } finally {
      if (identical(_session, session)) _session = null;
      await session.close();
    }
  }

  Future<void> stop() async {
    try {
      await _session?.stopGeneration();
    } catch (_) {
      // Nothing running.
    }
  }

  Future<void> _closeModel() async {
    await _session?.close();
    _session = null;
    await _model?.close();
    _model = null;
  }
}
