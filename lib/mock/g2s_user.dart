class G2SUser {
  final String uid, email, displayName;
  final String? urlPhoto;
  final DateTime created, lastLogin;

  const G2SUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.urlPhoto,
    required this.created,
    required this.lastLogin,
  });

  static G2SUser convertToG2SUser({required Map<String, dynamic> data}) {
    return G2SUser(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'],
      urlPhoto: data['urlPhoto'],
      created: DateTime.parse(data['created']),
      lastLogin: DateTime.parse(data['lastLogin']),
    );
  }

  static Map<String, dynamic> convertToMap({required G2SUser g2sUser}) {
    return {
      'uid': g2sUser.uid,
      'email': g2sUser.email,
      'displayName': g2sUser.displayName,
      'urlPhoto': g2sUser.urlPhoto,
      'created': g2sUser.created.toString(),
      'lastLogin': g2sUser.lastLogin.toString(),
    };
  }
}
