// ignore_for_file: public_member_api_docs, sort_constructors_first


class UserModel {
  final String email;
  final String name;
  final String id;

   const UserModel({required this.email, required this.name, required this.id});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'id': id,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      name: map['name'] as String,
      id: map['id'] as String,
    );
  }

  
}
