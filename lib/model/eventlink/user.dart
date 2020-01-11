enum AccountType {
  Admin,
  Regular,
}

enum LoginMethod {
  Eventlink,
  Facebook,
  Google,
  Apple,
}

class User {
  String id;
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
  List<dynamic> participatingEvents;
  List<dynamic> favoriteEvents;
  List<dynamic> pastEvents;
  List<dynamic> buddies;
  List<dynamic> payments;
  DateTime lastActivityDate;
  bool isActive;
  DateTime dbCreatedDate;
  DateTime dbModifiedDate;
  DateTime dbDeletedDate;
  DateTime dbReactivatedDate;
  bool isDeleted;

  User(
      {this.id,
      this.accountType,
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
      this.isActive,
      this.dbCreatedDate,
      this.dbModifiedDate,
      this.dbDeletedDate,
      this.dbReactivatedDate,
      this.isDeleted});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? null,
      accountType: parseAccountType(json['accountType']) ?? null,
      loginMethod: parseLoginMethod(json['loginMethod']) ?? null,
      picUrl: json['picUrl'] ?? null,
      firstName: json['firstName'] ?? null,
      middleName: json['middleName'] ?? null,
      lastName: json['lastName'] ?? null,
      fullName: json['fullName'] ?? null,
      email: json['email'] ?? null,
      address: json['address'] ?? null,
      birthdate: parseDateTimeJSON(json, 'birthdate') ?? null,
      hashedPassword: json['hashedPassword'] ?? null,
      phoneNumber: json['phoneNumber'] ?? null,
      country: json['country'] ?? null,
      participatingEvents: json['participatingEvents'] ?? null,
      favoriteEvents: json['favoriteEvents'] ?? null,
      pastEvents: json['pastEvents'] ?? null,
      buddies: json['buddies'] ?? null,
      payments: json['payments'] ?? null,
      lastActivityDate: parseDateTimeJSON(json, 'lastActivityDate') ?? null,
      isActive: json['isActive'] ?? null,
      dbCreatedDate: parseDateTimeJSON(json, 'dbCreatedDate') ?? null,
      dbModifiedDate: parseDateTimeJSON(json, 'dbModifiedDate') ?? null,
      dbDeletedDate: parseDateTimeJSON(json, 'dbDeletedDate') ?? null,
      dbReactivatedDate: parseDateTimeJSON(json, 'dbReactivatedDate') ?? null,
      isDeleted: json['isDeleted'] ?? null,
    );
  }

  static AccountType parseAccountType(String accountType) {
    if (accountType == null) {
      return AccountType.Regular;
    } else if (accountType == "0" ||
        accountType.toLowerCase().contains("admin")) {
      return AccountType.Admin;
    } else {
      return AccountType.Regular;
    }
  }

  static LoginMethod parseLoginMethod(String loginMethod) {
    try {
      if (loginMethod == "0" || loginMethod.toLowerCase().contains('event')) {
        return LoginMethod.Eventlink;
      } else if (loginMethod == "1" ||
          loginMethod.toLowerCase().contains('face')) {
        return LoginMethod.Facebook;
      } else if (loginMethod == "2" ||
          loginMethod.toLowerCase().contains('google')) {
        return LoginMethod.Google;
      } else if (loginMethod == "3" ||
          loginMethod.toLowerCase().contains('apple')) {
        return LoginMethod.Apple;
      }
    } catch (e) {
      return null;
    }
  }

  static DateTime parseDateTimeJSON(Map<String, dynamic> json, String field) {
    return json[field] == null ? null : DateTime.parse(json[field]);
  }

  Map toJson() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['accountType'] =
        accountType.toString().substring(12, accountType.toString().length);
    map['loginMethod'] =
        loginMethod.toString().substring(12, loginMethod.toString().length);
    map['picUrl'] = picUrl;
    map['firstName'] = firstName;
    map['middleName'] = middleName;
    map['lastName'] = lastName;
    map['fullName'] = fullName;
    map['email'] = email;
    map['address'] = address;
    map['birthdate'] = birthdate.toString();
    map['hashedPassword'] = hashedPassword;
    map['phoneNumber'] = phoneNumber;
    map['country'] = country;
    map['participatingEvents'] = participatingEvents;
    map['favoriteEvents'] = favoriteEvents;
    map['pastEvents'] = pastEvents;
    map['buddies'] = buddies;
    map['payments'] = payments;
    map['lastActivityDate'] = lastActivityDate.toString();
    map['isActive'] = isActive;
    map['dbCreatedDate'] = dbCreatedDate.toString();
    map['dbModifiedDate'] = dbModifiedDate.toString();
    map['dbDeletedDate'] = dbModifiedDate.toString();
    map['dbReactivatedDate'] = dbReactivatedDate.toString();
    map['isDeleted'] = isDeleted;
    return map;
  }
}
