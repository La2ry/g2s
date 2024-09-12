class G2SProject {
  final String? id;
  final String uid, name, description, currency;
  final List attachement;
  final bool finiched, deleted;
  final DateTime created, modified;

  const G2SProject({
    this.id,
    required this.uid,
    required this.name,
    required this.description,
    required this.currency,
    this.attachement = const <String>[],
    this.finiched = false,
    this.deleted = false,
    required this.created,
    required this.modified,
  });

  static G2SProject convertToG2SProject({required Map<String, dynamic> data}) {
    return G2SProject(
      id: data['id'],
      uid: data['uid'],
      name: data['name'],
      description: data['description'],
      currency: data['currency'],
      attachement: data['attachement'],
      finiched: data['finiched'],
      deleted: data['deleted'],
      created: DateTime.parse(data['created']),
      modified: DateTime.parse(data['modified']),
    );
  }

  static Map<String, dynamic> convertToMap({required G2SProject g2sProject}) {
    return {
      if (g2sProject.id is String) 'id': g2sProject.id,
      'uid': g2sProject.uid,
      'name': g2sProject.name,
      'description': g2sProject.description,
      'currency': g2sProject.currency,
      'attachement': g2sProject.attachement,
      'finiched': g2sProject.finiched,
      'deleted': g2sProject.deleted,
      'created': g2sProject.created.toString(),
      'modified': g2sProject.modified.toString(),
    };
  }
}
