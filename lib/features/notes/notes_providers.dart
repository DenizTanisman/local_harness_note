import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database_provider.dart';
import '../../data/repositories/notes_repository.dart';
import '../gemma/gemma_service.dart';
import '../relay/push.dart';

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepository(ref.watch(databaseProvider)),
);

/// One model and one download per process.
final gemmaServiceProvider = Provider<GemmaService>((ref) => GemmaService());

final pushProvider = Provider<Push>((ref) => Push(ref.watch(databaseProvider)));
