import './user.dart';

class UserInput {
  AccountType accountType;
  LoginMethod loginMethod;
  String picUrl;
  String firstName;
  String middleName;
  String lastName;
  String fullName;
  String email;
  String address;
  DateTime birthdate;
  String hashedPassword;
  String phoneNumber;
  String country;
  List<String> participatingEvents;
  List<String> favoriteEvents;
  List<String> pastEvents;
  List<String> buddies;
  List<String> payments;
  DateTime lastActivityDate;
  bool isActive;

  UserInput(
      {this.accountType,
      this.loginMethod,
      this.picUrl,
      this.firstName,
      this.middleName,
      this.lastName,
      this.fullName,
      this.email,
      this.address,
      this.birthdate,
      this.hashedPassword,
      this.phoneNumber,
      this.country,
      this.participatingEvents,
      this.favoriteEvents,
      this.pastEvents,
      this.buddies,
      this.payments,
      this.lastActivityDate,
      this.isActive});

  Map toJson() {
    var map = new Map<String, dynamic>();
    map['accountType'] = accountType == null
        ? "Regular"
        : accountType.toString().substring(12, accountType.toString().length) ??
            "Regular";
    map['loginMethod'] =
        loginMethod.toString().substring(12, loginMethod.toString().length);
    map['picUrl'] = picUrl ?? "";
    map['firstName'] = firstName ?? "";
    map['middleName'] = middleName ?? "";
    map['lastName'] = lastName ?? "";
    map['fullName'] = fullName ?? "";
    map['email'] = email ?? "";
    map['address'] = address ?? "";
    map['birthdate'] = birthdate.toString() ?? "";
    map['hashedPassword'] = hashedPassword ?? "";
    map['phoneNumber'] = phoneNumber ?? "";
    map['country'] = country ?? "";
    map['participatingEvents'] = participatingEvents ?? "";
    map['favoriteEvents'] = favoriteEvents ?? "";
    map['pastEvents'] = pastEvents ?? List();
    map['buddies'] = buddies ?? List();
    map['payments'] = payments ?? List();
    map['lastActivityDate'] = lastActivityDate.toString() ?? "";
    map['isActive'] = isActive ?? true;
    return map;
  }
}
