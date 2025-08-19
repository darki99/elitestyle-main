class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': createdAt.toUtc(),
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'],
        email: map['email'],
        displayName: map['displayName'],
        createdAt: DateTime.parse(map['createdAt'].toDate().toString()),
      );
}
