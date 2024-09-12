class G2SLog {
  final String? id;
  final String uid;
  final String order, description;
  final DateTime created;

  const G2SLog({
    this.id,
    required this.uid,
    required this.order,
    required this.description,
    required this.created,
  });

  static G2SLog convertToG2SLog({required Map<String, dynamic> data}) {
    return G2SLog(
      id: data['id'],
      uid: data['uid'],
      order: data['order'],
      description: data['description'],
      created: DateTime.parse(data['created']),
    );
  }

  static Map<String, dynamic> convertToMap({required G2SLog g2sLog}) {
    return {
      'uid': g2sLog.uid,
      'order': g2sLog.order,
      'description': g2sLog.description,
      'created': g2sLog.created.toString(),
    };
  }
}
