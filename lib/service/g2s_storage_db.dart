import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g2s/mock/g2s_destocking.dart';
import 'package:g2s/mock/g2s_storage.dart';
import 'package:g2s/mock/g2s_stored.dart';

class G2SStorageDB {
  final CollectionReference _g2sStorageDB = FirebaseFirestore.instance.collection('storage');
  final CollectionReference _stored = FirebaseFirestore.instance.collection('stored');
  final CollectionReference _destocking = FirebaseFirestore.instance.collection('destocking');

  Future<G2SStorage?> getStorage({required String id}) {
    return _g2sStorageDB.doc(id).get().then<G2SStorage?>(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          return G2SStorage.convertToG2SStorage(data: data);
        }

        return null;
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Stream<G2SStorage?> streamGetStorageWithID({required String id}) {
    return _g2sStorageDB.doc(id).snapshots().asyncMap<G2SStorage?>((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        return G2SStorage.convertToG2SStorage(data: data);
      }

      return null;
    });
  }

  Future<G2SStorage?> putStorage({required G2SStorage g2sStorage}) {
    return _g2sStorageDB.add(G2SStorage.convertToMap(g2sStorage: g2sStorage)).then<G2SStorage?>(
      (DocumentReference doc) {
        return _g2sStorageDB
            .doc(doc.id)
            .update({'id': doc.id})
            .then<G2SStorage?>(
              (value) => getStorage(id: doc.id),
            )
            .onError(
              (error, stackTrace) => null,
            );
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Future<void> updateWarningStorage({
    required String id,
    bool warning = false,
  }) {
    return _g2sStorageDB.doc(id).update(
      {
        'warning': warning,
      },
    );
  }

  Future<void> updateStoredInStorage({
    required String id,
    required num stored,
  }) {
    return _g2sStorageDB.doc(id).update({'stored': FieldValue.increment(stored)}).then(
      (value) => _g2sStorageDB.doc(id).update({
        'stock': FieldValue.increment(stored),
        'modified': DateTime.now().toString(),
      }),
    );
  }

  Future<void> updateDestockingInStorage({
    required String id,
    required num destocking,
  }) {
    return _g2sStorageDB.doc(id).update({'destocking': FieldValue.increment(destocking)}).then(
      (value) => _g2sStorageDB.doc(id).update({
        'stock': FieldValue.increment(-destocking),
        'modified': DateTime.now().toString(),
      }),
    );
  }

  Stream<List<G2SStorage?>> streamGetStorage({required String projectID}) {
    return _g2sStorageDB.where('projectID', isEqualTo: projectID).snapshots().asyncMap<List<G2SStorage?>>(
          (QuerySnapshot snapshot) => snapshot.docs.map<G2SStorage?>(
            (QueryDocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>?;

              if (data != null) {
                return G2SStorage.convertToG2SStorage(data: data);
              }

              return null;
            },
          ).toList(),
        );
  }

  Future<G2SStored?> getStored({required String id}) {
    return _stored.doc(id).get().then<G2SStored?>(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          return G2SStored.convertToG2SStored(data: data);
        }

        return null;
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Stream<List<G2SStored?>> streamGetStored({required String storageID}) {
    return _stored.where('storageID', isEqualTo: storageID).snapshots().asyncMap<List<G2SStored?>>(
          (QuerySnapshot snapshot) => snapshot.docs.map<G2SStored?>(
            (QueryDocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>?;

              if (data != null) {
                return G2SStored.convertToG2SStored(data: data);
              }

              return null;
            },
          ).toList(),
        );
  }

  Future<G2SStored?> putStored({required G2SStored g2sStored}) {
    return _stored.add(G2SStored.convertToMap(g2sStored: g2sStored)).then<G2SStored?>(
      (DocumentReference doc) {
        return _stored.doc(doc.id).update({'id': doc.id}).then(
          (value) async {
            await updateStoredInStorage(
              id: g2sStored.storageID,
              stored: g2sStored.stored,
            );
            return getStored(id: doc.id);
          },
        ).onError(
          (error, stackTrace) => null,
        );
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Future<G2SDestocking?> getDestocking({required String id}) {
    return _destocking.doc(id).get().then<G2SDestocking?>(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          return G2SDestocking.convertToG2SStored(data: data);
        }

        return null;
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }

  Stream<List<G2SDestocking?>> streamGetDestoring({required String storageID}) {
    return _destocking.where('storageID', isEqualTo: storageID).snapshots().asyncMap<List<G2SDestocking?>>(
          (QuerySnapshot snapshot) => snapshot.docs.map<G2SDestocking?>(
            (QueryDocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>?;

              if (data != null) {
                return G2SDestocking.convertToG2SStored(data: data);
              }

              return null;
            },
          ).toList(),
        );
  }

  Future<G2SDestocking?> putDestocking({required G2SDestocking g2sDestocking}) {
    return _destocking.add(G2SDestocking.convertToMap(g2sDestocking: g2sDestocking)).then<G2SDestocking?>(
      (DocumentReference doc) {
        return _destocking.doc(doc.id).update({'id': doc.id}).then<G2SDestocking?>(
          (value) async {
            await updateDestockingInStorage(
              id: g2sDestocking.storageID,
              destocking: g2sDestocking.destocking,
            );
            return getDestocking(id: doc.id);
          },
        ).onError(
          (error, stackTrace) => null,
        );
      },
    ).onError(
      (error, stackTrace) => null,
    );
  }
}
