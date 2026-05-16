// ignore_for_file: public_member_api_docs, sort_constructors_first


class UserModel {
  final String email;
  final String? name;
  final String id;
  final String? avatarUrl;
  final String? fullName;

  const UserModel({
    required this.email,
    this.name,
    required this.id,
    this.avatarUrl,
    this.fullName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'id': id,
      "avatarUrl": avatarUrl,
      "fullName": fullName
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      name: map['name'] as String?,
      id: map['id'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      fullName: map['fullName'] as String?,
    );
  }

  
}
