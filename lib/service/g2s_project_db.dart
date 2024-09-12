import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g2s/mock/g2s_log.dart';
import 'package:g2s/mock/g2s_project.dart';
import 'package:g2s/service/g2s_log_user.dart';

class G2SProjectDB {
  final CollectionReference _g2sProjectDB = FirebaseFirestore.instance.collection('project');

  Future<G2SProject?> getProject({required String id}) {
    return _g2sProjectDB.doc(id).get().then<G2SProject?>(
      (DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          G2SLog g2sLog = G2SLog(
            uid: data['uid'],
            order: "getProject(UID:$id})",
            description: "get project in the data base.",
            created: DateTime.now(),
          );
          await G2SLogUser().putLogUser(g2sLog: g2sLog);
          return G2SProject.convertToG2SProject(data: data);
        }

        return null;
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Stream<List<G2SProject?>> streamGetProjet({required String uid}) {
    return _g2sProjectDB.where('uid', isEqualTo: uid).where('deleted', isEqualTo: false).orderBy('created').snapshots().asyncMap<List<G2SProject?>>(
          (QuerySnapshot snapshot) => snapshot.docs.map<G2SProject?>(
            (QueryDocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                return G2SProject.convertToG2SProject(data: data);
              }
              return null;
            },
          ).toList(),
        );
  }

  Stream<G2SProject?> streamGetProjetWithID({required String id}) {
    return _g2sProjectDB.doc(id).snapshots().asyncMap<G2SProject?>(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          return G2SProject.convertToG2SProject(data: data);
        }

        return null;
      },
    );
  }

  Future<G2SProject?> putProject({required G2SProject g2sProject}) {
    return _g2sProjectDB.add(G2SProject.convertToMap(g2sProject: g2sProject)).then<G2SProject?>(
      (DocumentReference doc) async {
        G2SLog g2sLog = G2SLog(
          uid: g2sProject.uid,
          order: "putProject(UID:${doc.id})",
          description: "create project in the data base.",
          created: DateTime.now(),
        );
        await G2SLogUser().putLogUser(g2sLog: g2sLog);
        return _g2sProjectDB
            .doc(doc.id)
            .update({'id': doc.id})
            .then<G2SProject?>(
              (value) => getProject(id: doc.id),
            )
            .onError(
              (error, stackTrace) => null,
            );
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Future<void> updateFinichedProject({required String id, bool finiched = false}) {
    return _g2sProjectDB.doc(id).update(
      {
        'finiched': finiched,
      },
    );
  }

  Future<void> deleteProjet({required String id}) {
    return _g2sProjectDB.doc(id).update(
      {
        'deleted': true,
      },
    );
  }
}
