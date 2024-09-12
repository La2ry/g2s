import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g2s/mock/g2s_licence.dart';
import 'package:g2s/mock/g2s_log.dart';
import 'package:g2s/service/g2s_log_user.dart';

class Licence {
  final CollectionReference _licence =
      FirebaseFirestore.instance.collection('licence');

  Future<G2SLicence?> putLicence({required G2SLicence g2sLicence}) {
    return _licence
        .doc(g2sLicence.uid)
        .set(G2SLicence.convertToMap(g2sLicence: g2sLicence))
        .then<G2SLicence?>(
      (value) {
        G2SLog g2sLog = G2SLog(
          uid: g2sLicence.uid,
          order: 'putLicence(UID:${g2sLicence.uid})',
          description: 'creates the user license',
          created: DateTime.now(),
        );
        G2SLogUser().putLogUser(g2sLog: g2sLog);
        return getLicence(uid: g2sLicence.uid);
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Future<G2SLicence?> getLicence({required String uid}) {
    return _licence.doc(uid).get().then<G2SLicence?>(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          G2SLog g2sLog = G2SLog(
            uid: uid,
            order: 'getLicence(UID:$uid)',
            description: 'get the user licence',
            created: DateTime.now(),
          );
          G2SLogUser().putLogUser(g2sLog: g2sLog);
          return G2SLicence.convertToG2SLicence(data: data);
        }
        return null;
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Stream<G2SLicence?> streamGetLicence({required String uid}) {
    return _licence.doc(uid).snapshots().asyncMap<G2SLicence?>(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return G2SLicence.convertToG2SLicence(data: data);
        }
        return null;
      },
    );
  }
}
