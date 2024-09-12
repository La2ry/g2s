import 'package:cloud_firestore/cloud_firestore.dart';

class G2SLicence {
  final String uid;
  final String organization;
  final String? urlLogo;
  final int freeProject;
  final num stock;
  final DateTime created;

  const G2SLicence({
    required this.uid,
    required this.organization,
    this.urlLogo,
    this.freeProject = 20,
    this.stock = 1048576.0,
    required this.created,
  });

  static G2SLicence convertToG2SLicence({required Map<String, dynamic> data}) {
    return G2SLicence(
      uid: data['uid'],
      organization: data['organization'],
      urlLogo: data['urlLogo'],
      freeProject: data['freeProject'],
      stock: data['stock'],
      created: DateTime.parse(data['created']),
    );
  }

  static Map<String, dynamic> convertToMap({required G2SLicence g2sLicence}) {
    return {
      'uid': g2sLicence.uid,
      'urlLogo': g2sLicence.urlLogo,
      'freeProject': FieldValue.increment(g2sLicence.freeProject),
      'stock': FieldValue.increment(g2sLicence.stock),
      'organization': g2sLicence.organization,
      'created': g2sLicence.created.toString(),
    };
  }
}
