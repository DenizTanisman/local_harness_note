import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/core/tag_tree.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const rows = [
    (noteId: '1', tag: 'question'),
    (noteId: '2', tag: 'question-llm'),
    (noteId: '3', tag: 'question-llm'),
    (noteId: '3', tag: 'question-llm-rag'),
    (noteId: '4', tag: 'question-flutter'),
    (noteId: '5', tag: 'kitap'),
  ];

  test('top level counts every note under a tag once', () {
    final top = TagTree.children(rows, null);
    expect(top.map((t) => (t.path, t.count)), [('question', 4), ('kitap', 1)]);
  });

  test('children of a tag, deeper levels folded in', () {
    final sub = TagTree.children(rows, 'question');
    expect(sub.map((t) => (t.name, t.path, t.count)), [
      ('llm', 'question-llm', 2),
      ('flutter', 'question-flutter', 1),
    ]);
    expect(TagTree.children(rows, 'question-llm').map((t) => t.path), [
      'question-llm-rag',
    ]);
    expect(TagTree.children(rows, 'kitap'), isEmpty);
  });

  test('ancestry and within', () {
    expect(TagTree.ancestry('a-b-c'), ['a', 'a-b', 'a-b-c']);
    expect(TagTree.within('question-llm', 'question'), isTrue);
    expect(TagTree.within('question', 'question'), isTrue);
    expect(TagTree.within('questions', 'question'), isFalse);
  });

  test('filtering by a tag includes its sub-tags, not look-alikes', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = NotesRepository(db);
    final main = await repo.create('Genel soru #question');
    final llm = await repo.create('LLM sorusu #question-LLM');
    final rag = await repo.create('RAG #question-llm-rag');
    await repo.create('Benzer ama değil #questions');
    await repo.create('Alt çizgi #question_x');

    Future<Set<String>> ids(String tag) async => {
      for (final n in await repo.search(tag: tag)) n.id,
    };

    expect(await ids('question'), {main, llm, rag});
    expect(await ids('question-llm'), {llm, rag});
    expect(await ids('question-llm-rag'), {rag});
    // Typed in the search box too.
    expect(
      {for (final n in await repo.search(query: '#question-llm')) n.id},
      {llm, rag},
    );
    final tree = await repo.watchTagRows().first;
    expect(TagTree.children(tree, 'question').map((t) => t.path), [
      'question-llm',
    ]);
    await db.close();
  });
}
