import 'package:cloud_firestore/cloud_firestore.dart';

class G2SDestocking {
  final String? id;
  final String storageID, description;
  final num destocking;
  final List attachement;
  final DateTime created;

  const G2SDestocking({
    this.id,
    required this.storageID,
    required this.description,
    this.destocking = 0,
    this.attachement = const [],
    required this.created,
  });

  static Map<String, dynamic> convertToMap({required G2SDestocking g2sDestocking}) {
    return {
      if (g2sDestocking.id is String) 'id': g2sDestocking.id,
      'storageID': g2sDestocking.storageID,
      'description': g2sDestocking.description,
      'destocking': FieldValue.increment(g2sDestocking.destocking),
      'attachement': g2sDestocking.attachement,
      'created': g2sDestocking.created.toString(),
    };
  }

  static G2SDestocking convertToG2SStored({required Map<String, dynamic> data}) {
    return G2SDestocking(
      id: data['id'],
      storageID: data['storageID'],
      description: data['description'],
      destocking: data['destocking'],
      attachement: data['attachement'],
      created: DateTime.parse(data['created']),
    );
  }
}
