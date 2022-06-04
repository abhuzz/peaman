class PeamanFollower {
  final String? uid;
  final int? createdAt;
  final int? updatedAt;

  PeamanFollower({
    this.uid,
    this.createdAt,
    this.updatedAt,
  });

  static PeamanFollower fromJson(final Map<String, dynamic> data) {
    return PeamanFollower(
      uid: data['uid'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }
}
