/// Compares two dotted version strings.
///
/// Returns a negative number when [a] is older than [b], zero when they are
/// the same release, and a positive number when [a] is newer.
///
/// A string is worth its own function here because none of the obvious ways
/// work. `'1.10.0'.compareTo('1.9.0')` is negative, since '1' sorts before
/// '9' as text, so a lexicographic compare tells a user on the newest build
/// to update. `double.parse` cannot hold three segments at all.
///
/// The build suffix and any pre-release tag are ignored: `1.4.0+27`,
/// `1.4.0-beta.2` and `1.4.0` are the same release as far as a store listing
/// is concerned, and the manifest publishes a marketing version. Missing
/// segments count as zero, so `1.4` equals `1.4.0`. A segment that is not a
/// number counts as zero rather than throwing, because the manifest is remote
/// text and a typo in it must not crash a launch.
int compareVersions(String a, String b) {
  final List<int> left = versionSegments(a);
  final List<int> right = versionSegments(b);
  final int length = left.length > right.length ? left.length : right.length;

  for (int i = 0; i < length; i++) {
    final int l = i < left.length ? left[i] : 0;
    final int r = i < right.length ? right[i] : 0;
    if (l != r) {
      return l < r ? -1 : 1;
    }
  }

  return 0;
}

/// True when [candidate] is a strictly newer release than [current].
///
/// Both empty and unparseable inputs answer false, so an empty manifest field
/// can never raise a prompt.
bool isNewerVersion(String candidate, String current) {
  if (candidate.isEmpty || current.isEmpty) {
    return false;
  }

  return compareVersions(candidate, current) > 0;
}

/// The numeric segments of a version string, build and pre-release stripped.
List<int> versionSegments(String version) {
  final String core = version.trim().split('+').first.split('-').first;

  return core
      .split('.')
      .map((String part) => int.tryParse(part.trim()) ?? 0)
      .toList();
}
