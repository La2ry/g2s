import 'package:cloud_firestore/cloud_firestore.dart';

class G2SStored {
  final String? id;
  final String storageID, description;
  final num stored;
  final List attachement;
  final DateTime created;

  const G2SStored({
    this.id,
    required this.storageID,
    required this.description,
    this.stored = 0,
    this.attachement = const [],
    required this.created,
  });

  static Map<String, dynamic> convertToMap({required G2SStored g2sStored}) {
    return {
      if (g2sStored.id is String) 'id': g2sStored.id,
      'storageID': g2sStored.storageID,
      'description': g2sStored.description,
      'stored': FieldValue.increment(g2sStored.stored),
      'attachement': g2sStored.attachement,
      'created': g2sStored.created.toString(),
    };
  }

  static G2SStored convertToG2SStored({required Map<String, dynamic> data}) {
    return G2SStored(
      id: data['id'],
      storageID: data['storageID'],
      description: data['description'],
      stored: data['stored'],
      attachement: data['attachement'],
      created: DateTime.parse(data['created']),
    );
  }
}
