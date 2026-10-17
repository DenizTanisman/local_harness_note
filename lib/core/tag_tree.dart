/// Hashtags are a tree: `-` separates levels, so `#question-llm` is the
/// sub-tag `llm` under `#question`. A note tagged `#question` alone belongs
/// to `question` itself. Picking a tag shows its notes and every note
/// under it.
class TagNode {
  const TagNode({required this.name, required this.path, required this.count});

  /// This level's name ("llm").
  final String name;

  /// Full tag ("question-llm").
  final String path;

  /// Notes tagged with [path] or anything under it.
  final int count;
}

class TagTree {
  TagTree._();

  static const separator = '-';

  /// True when [tag] is [path] or lies under it.
  static bool within(String tag, String path) =>
      tag == path || tag.startsWith('$path$separator');

  /// The levels of [path] from the top: `a-b-c` → `a`, `a-b`, `a-b-c`.
  static List<String> ancestry(String path) {
    final parts = path.split(separator).where((p) => p.isNotEmpty).toList();
    return [
      for (var i = 1; i <= parts.length; i++) parts.take(i).join(separator),
    ];
  }

  /// One level of the tree: the top-level tags when [parent] is null, else
  /// the tags directly under [parent]. [rows] are (note id, tag) pairs.
  /// Most notes first, then by name.
  static List<TagNode> children(
    List<({String noteId, String tag})> rows,
    String? parent,
  ) {
    final notesByPath = <String, Set<String>>{};
    final prefix = parent == null ? '' : '$parent$separator';
    for (final r in rows) {
      if (!r.tag.startsWith(prefix) || r.tag == parent) continue;
      final rest = r.tag.substring(prefix.length);
      final name = rest.split(separator).first;
      if (name.isEmpty) continue;
      notesByPath.putIfAbsent('$prefix$name', () => {}).add(r.noteId);
    }
    final nodes = [
      for (final e in notesByPath.entries)
        TagNode(
          name: e.key.substring(prefix.length),
          path: e.key,
          count: e.value.length,
        ),
    ];
    nodes.sort(
      (a, b) =>
          a.count != b.count ? b.count - a.count : a.name.compareTo(b.name),
    );
    return nodes;
  }
}
