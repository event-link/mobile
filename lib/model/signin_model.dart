class SignInModel {
  final String email;
  final String password;

  SignInModel({this.email, this.password});

  factory SignInModel.fromJson(Map<String, dynamic> json) {
    return SignInModel(
      email: json["email"],
      password: json["password"],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    map["password"] = password;
    return map;
  }
}
