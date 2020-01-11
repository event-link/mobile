class AuthModel {
  final String token;
  final String message;
  final String email;

  AuthModel({this.token, this.message, this.email});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json["token"],
      message: json["message"],
      email: json["email"],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["token"] = token;
    map["message"] = message;
    map["email"] = email;
    return map;
  }
}
