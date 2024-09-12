import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g2s/mock/g2s_log.dart';

class G2SLogUser {
  final _g2sLogUser = FirebaseFirestore.instance.collection('log');

  Future<G2SLog?> putLogUser({required G2SLog g2sLog}) {
    return _g2sLogUser
        .add(G2SLog.convertToMap(g2sLog: g2sLog))
        .then<G2SLog?>(
          (DocumentReference doc) => _g2sLogUser
              .doc(doc.id)
              .update({'id': doc.id})
              .then(
                (value) => getLogUser(id: doc.id),
              )
              .onError(
                (error, stackTrace) => null,
              ),
        )
        .onError(
          (error, stackTrace) => null,
        );
  }

  Future<G2SLog?> getLogUser({required String id}) {
    return _g2sLogUser.doc(id).get().then<G2SLog?>(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          return G2SLog.convertToG2SLog(data: data);
        }
        return null;
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Stream<List<G2SLog?>> streamGetLogUser({required String uid}) {
    return _g2sLogUser.where('uid', isEqualTo: uid).orderBy('created').snapshots().asyncMap<List<G2SLog?>>(
          (QuerySnapshot snapshot) => snapshot.docs.map<G2SLog?>(
            (QueryDocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>?;

              if (data != null) {
                return G2SLog.convertToG2SLog(data: data);
              }
              return null;
            },
          ).toList(),
        );
  }
}
