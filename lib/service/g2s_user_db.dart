import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g2s/mock/g2s_log.dart';
import 'package:g2s/mock/g2s_user.dart';
import 'package:g2s/service/g2s_log_user.dart';

class G2SUserDB {
  final _g2sUserDB = FirebaseFirestore.instance.collection('user');

  Future<G2SUser?> getUser({required String uid}) {
    return _g2sUserDB.doc(uid).get().then<G2SUser?>(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          return G2SUser.convertToG2SUser(data: data);
        }

        return null;
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Stream<G2SUser?> streamGetUser({required String uid}) {
    return _g2sUserDB.doc(uid).snapshots().asyncMap<G2SUser?>((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        return G2SUser.convertToG2SUser(data: data);
      }

      return null;
    });
  }

  Future<G2SUser?> putUser({required G2SUser g2sUser}) {
    return _g2sUserDB
        .doc(g2sUser.uid)
        .set(G2SUser.convertToMap(g2sUser: g2sUser))
        .then<G2SUser?>(
          (value) => getUser(uid: g2sUser.uid),
        )
        .onError(
          (error, stackTrace) => null,
        );
  }

  Future<void> updateLastLogin({required String uid}) {
    G2SLog g2sLog = G2SLog(
      uid: uid,
      order: 'updateUser(UID:$uid)',
      description: 'update of the last connection',
      created: DateTime.now(),
    );
    return _g2sUserDB.doc(uid).update({'lastLogin': DateTime.now().toString()}).then(
      (value) => G2SLogUser().putLogUser(g2sLog: g2sLog),
    );
  }
}
