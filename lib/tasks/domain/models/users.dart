import 'dart:convert';

class Users {
  final int? userId;
  final String? userName;
  final String? userPassword;

  Users(
      { this.userId,
       this.userName,
       this.userPassword});

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        userId: json["userId"],
        userName: json["userName"],
        userPassword: json["userPassword"],
      );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userPassword': userPassword,
    };
  }

  String toJson() => json.encode(toMap());

  factory Users.fromJson(String source) =>
      Users.fromMap(json.decode(source) as Map<String, dynamic>);
}
