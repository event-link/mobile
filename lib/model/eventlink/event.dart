class Event {
  String id;
  String providerEventId;
  String providerName;
  String name;
  String type;
  String url;
  String locale;
  String description;
  Sales sales;
  Dates dates;
  List<Classification> classifications;
  Promoter promoter;
  List<PriceRange> priceRanges;
  List<Venue> venues;
  List<Attraction> attractions;
  List<Image> images;
  bool isActive;
  DateTime dbCreatedDate;
  DateTime dbModifiedDate;
  DateTime dbDeletedDate;
  DateTime dbReactivatedDate;
  bool isDeleted;

  Event(
      {this.id,
      this.providerEventId,
      this.providerName,
      this.name,
      this.type,
      this.url,
      this.locale,
      this.description,
      this.isActive,
      this.sales,
      this.dates,
      this.classifications,
      this.promoter,
      this.priceRanges,
      this.venues,
      this.attractions,
      this.images,
      this.dbCreatedDate,
      this.dbModifiedDate,
      this.dbDeletedDate,
      this.dbReactivatedDate,
      this.isDeleted});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        id: json['id'] ?? null,
        providerEventId: json['providerEventId'] ?? null,
        providerName: json['providerName'] ?? null,
        name: json['name'] ?? null,
        type: json['type'] ?? null,
        url: json['url'] ?? null,
        locale: json['locale'] ?? null,
        description: json['description'] ?? null,
        sales: Sales.fromJson(json['sales']) ?? null,
        dates: Dates.fromJson(json['dates']) ?? null,
        classifications: Classification.parseList(json) ?? null,
        promoter: json['promoter'] ?? null,
        priceRanges: PriceRange.parseList(json) ?? null,
        venues: Venue.parseList(json) ?? null,
        attractions: Attraction.parseList(json) ?? null,
        images: Image.parseList(json) ?? null,
        isActive: json['isActive'] ?? null,
        dbCreatedDate: Event.parseDateTimeJSON(json, 'dbCreatedDate'),
        dbModifiedDate: Event.parseDateTimeJSON(json, 'dbModifiedDate'),
        dbDeletedDate: Event.parseDateTimeJSON(json, 'dbDeletedDate'),
        dbReactivatedDate: Event.parseDateTimeJSON(json, 'DbReactivatedDate'),
        isDeleted: json['isDeleted'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['id'] = id;
    map['providerEventId'] = providerEventId;
    map['providerName'] = providerName;
    map['name'] = name;
    map['type'] = type;
    map['url'] = url;
    map['locale'] = locale;
    map['description'] = description;
    map['sales'] = sales;
    map['dates'] = dates;
    map['classifications'] = classifications;
    map['promoter'] = promoter;
    map['priceRanges'] = priceRanges;
    map['venues'] = venues;
    map['attractions'] = attractions;
    map['image'] = images;
    map['isActive'] = isActive;
    map['dbCreatedDate'] = dbCreatedDate;
    map['dbModifiedDate'] = dbModifiedDate;
    map['dbDeletedDate'] = dbDeletedDate;
    map['dbReactivatedDate'] = dbReactivatedDate;
    map['isDeleted'] = isDeleted;
    return map;
  }

  static DateTime parseDateTimeJSON(Map<String, dynamic> json, String field) {
    return json[field] == null ? null : DateTime.parse(json[field]);
  }
}

class Sales {
  DateTime startDateTime;
  bool startTBD;
  DateTime endDateTime;

  Sales({this.startDateTime, this.startTBD, this.endDateTime});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      startDateTime: Event.parseDateTimeJSON(json, 'startDateTime'),
      startTBD: json['startTBD'] ?? false,
      endDateTime: Event.parseDateTimeJSON(json, 'endDateTime'),
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['startDateTime'] = startDateTime;
    map['startTBD'] = startTBD;
    map['endDateTime'] = endDateTime;

    return map;
  }
}

class Dates {
  String localStartDate;
  String timezone;
  String statusCode;
  bool spanMultipleDays;

  Dates(
      {this.localStartDate,
      this.timezone,
      this.statusCode,
      this.spanMultipleDays});

  factory Dates.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Dates(
        localStartDate: json['localStartDate'] ?? null,
        timezone: json['timezone'] ?? null,
        statusCode: json['statusCode'] ?? null,
        spanMultipleDays: json['endDateTspanMultipleDaysime'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['localStartDate'] = localStartDate;
    map['timezone'] = timezone;
    map['statusCode'] = statusCode;
    map['spanMultipleDays'] = spanMultipleDays;

    return map;
  }
}

class Promoter {
  String id;
  String name;

  Promoter({this.id, this.name});

  factory Promoter.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Promoter(id: json['id'] ?? null, name: json['name'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['id'] = id;
    map['name'] = name;

    return map;
  }
}

class PriceRange {
  String type;
  String currency;
  double min;
  double max;

  PriceRange({this.type, this.currency, this.min, this.max});

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return PriceRange(
        type: json['type'] ?? null,
        currency: json['currency'] ?? null,
        min: json['min'] ?? null,
        max: json['max'] ?? null);
  }

  static List<PriceRange> parseList(Map<String, dynamic> json) {
    List<PriceRange> list = new List();
    var jsonList = json['priceRanges'];

    if (jsonList == null) return list;

    for (var item in jsonList) {
      var obj = PriceRange.fromJson(item);
      list.add(obj);
    }

    return list;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['type'] = type;
    map['currency'] = currency;
    map['min'] = min;
    map['max'] = max;

    return map;
  }
}

class Classification {
  bool primary;
  bool family;
  Segment segment;
  Genre genre;
  SubGenre subGenre;

  Classification(
      {this.primary, this.family, this.segment, this.genre, this.subGenre});

  factory Classification.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Classification(
        primary: json['primary'] ?? null,
        family: json['family'] ?? null,
        segment: parseSegment(json['segment']) ?? null,
        genre: parseGenre(json['genre']) ?? null,
        subGenre: parseSubGenre(json['subGenre']) ?? null);
  }

  static Segment parseSegment(Map<String, dynamic> json) {
    if (json == null) return null;
    return Segment(id: json['id'] ?? null, name: json['name'] ?? null);
  }

  static Genre parseGenre(Map<String, dynamic> json) {
    if (json == null) return null;
    return Genre(id: json['id'] ?? null, name: json['name'] ?? null);
  }

  static SubGenre parseSubGenre(Map<String, dynamic> json) {
    if (json == null) return null;
    return SubGenre(id: json['id'] ?? null, name: json['name'] ?? null);
  }

  static List<Classification> parseList(Map<String, dynamic> json) {
    List<Classification> list = new List();
    var jsonList = json['classifications'];

    if (jsonList == null) return list;

    for (var item in jsonList) {
      var obj = Classification.fromJson(item);
      list.add(obj);
    }

    return list;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['primary'] = primary;
    map['family'] = family;
    map['segment'] = segment;
    map['genre'] = genre;
    map['subGenre'] = subGenre;

    return map;
  }
}

class Segment {
  String id;
  String name;

  Segment({this.id, this.name});

  factory Segment.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Segment(id: json['id'] ?? null, name: json['name'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['id'] = id;
    map['name'] = name;

    return map;
  }
}

class Genre {
  String id;
  String name;

  Genre({this.id, this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Genre(id: json['id'] ?? null, name: json['name'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['id'] = id;
    map['name'] = name;

    return map;
  }
}

class SubGenre {
  String id;
  String name;

  SubGenre({this.id, this.name});

  factory SubGenre.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return SubGenre(id: json['id'] ?? null, name: json['name'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['id'] = id;
    map['name'] = name;

    return map;
  }
}

class Venue {
  String id;
  String name;
  String type;
  String url;
  String locale;
  String timezone;
  City city;
  Country country;
  Address address;

  Venue(
      {this.id,
      this.name,
      this.type,
      this.url,
      this.locale,
      this.timezone,
      this.city,
      this.country,
      this.address});

  factory Venue.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Venue(
      id: json['id'] ?? null,
      name: json['name'] ?? null,
      type: json['type'] ?? null,
      url: json['url'] ?? null,
      locale: json['locale'] ?? null,
      timezone: json['timezone'] ?? null,
      city: City.fromJson(json['city']) ?? null,
      country: Country.fromJson(json['country']) ?? null,
      address: Address.fromJson(json['address']) ?? null,
    );
  }

  static List<Venue> parseList(Map<String, dynamic> json) {
    List<Venue> list = new List();
    var jsonList = json['venues'];

    if (jsonList == null) return list;

    for (var item in jsonList) {
      var obj = Venue.fromJson(item);
      list.add(obj);
    }

    return list;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map['id'] = id;
    map['name'] = name;
    map['type'] = type;
    map['url'] = url;
    map['locale'] = locale;
    map['timezone'] = timezone;
    map['city'] = city;
    map['country'] = country;
    map['address'] = address;

    return map;
  }
}

class City {
  String name;

  City({this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return City(name: json['name'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['name'] = name;

    return map;
  }
}

class Country {
  String name;
  String code;

  Country({this.name, this.code});

  factory Country.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Country(name: json['name'] ?? null, code: json['code'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['name'] = name;
    map['code'] = code;

    return map;
  }
}

class Address {
  String line;

  Address({this.line});

  factory Address.fromJson(Map<String, dynamic> json) {
    if (json == null) return Address(line: '');
    return Address(line: json['line'] ?? '');
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['line'] = line;

    return map;
  }
}

class Attraction {
  String id;
  String name;
  String type;
  String locale;
  Externallinks externallinks;

  Attraction({this.id, this.name, this.type, this.locale, this.externallinks});

  factory Attraction.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Attraction(
        id: json['id'] ?? null,
        name: json['name'] ?? null,
        type: json['type'] ?? null,
        locale: json['locale'] ?? null,
        externallinks: json['externallinks'] ?? null);
  }

  static List<Attraction> parseList(Map<String, dynamic> json) {
    List<Attraction> list = new List();
    var jsonList = json['attractions'];

    if (jsonList == null) return list;

    for (var item in jsonList) {
      var obj = Attraction.fromJson(item);
      list.add(obj);
    }

    return list;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['type'] = type;
    map['locale'] = locale;
    map['externallinks'] = externallinks;

    return map;
  }
}

class Externallinks {
  List<Youtube> youtube;
  List<Twitter> twitter;
  List<Itune> itunes;
  List<Lastfm> lastfm;
  List<Facebook> facebook;
  List<Wiki> wiki;
  List<Instagram> instagram;
  List<Homepage> homepage;

  Externallinks(
      {this.youtube,
      this.twitter,
      this.itunes,
      this.lastfm,
      this.facebook,
      this.wiki,
      this.instagram,
      this.homepage});

  factory Externallinks.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Externallinks(
        youtube: json['youtube'] ?? null,
        twitter: json['twitter'] ?? null,
        itunes: json['itunes'] ?? null,
        lastfm: json['lastfm'] ?? null,
        facebook: json['facebook'] ?? null,
        wiki: json['wiki'] ?? null,
        instagram: json['instagram'] ?? null,
        homepage: json['homepage'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['youtube'] = youtube;
    map['twitter'] = twitter;
    map['itunes'] = itunes;
    map['lastfm'] = lastfm;
    map['facebook'] = facebook;
    map['wiki'] = wiki;
    map['instagram'] = instagram;
    map['homepage'] = homepage;

    return map;
  }
}

class Youtube {
  String url;

  Youtube({this.url});

  factory Youtube.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Youtube(url: json['url'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;

    return map;
  }
}

class Twitter {
  String url;

  Twitter({this.url});

  factory Twitter.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Twitter(url: json['url'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;

    return map;
  }
}

class Itune {
  String url;

  Itune({this.url});

  factory Itune.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Itune(url: json['url'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;

    return map;
  }
}

class Lastfm {
  String url;

  Lastfm({this.url});

  factory Lastfm.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Lastfm(url: json['url'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;

    return map;
  }
}

class Facebook {
  String url;

  Facebook({this.url});

  factory Facebook.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Facebook(url: json['url'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;

    return map;
  }
}

class Wiki {
  String url;

  Wiki({this.url});

  factory Wiki.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Wiki(url: json['url'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;

    return map;
  }
}

class Instagram {
  String url;

  Instagram({this.url});

  factory Instagram.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Instagram(url: json['url'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;

    return map;
  }
}

class Homepage {
  String url;

  Homepage({this.url});

  factory Homepage.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Homepage(url: json['url'] ?? null);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;

    return map;
  }
}

class Image {
  String url;
  String ratio;
  int width;
  int height;

  Image({this.url, this.ratio, this.width, this.height});

  factory Image.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Image(
        url: json['url'] ?? null,
        ratio: json['ratio'] ?? null,
        width: json['width'] ?? null,
        height: json['height'] ?? null);
  }

  static List<Image> parseList(Map<String, dynamic> json) {
    List<Image> list = new List();
    var jsonList = json['images'];

    if (jsonList == null) return list;

    for (var item in jsonList) {
      var obj = Image.fromJson(item);
      list.add(obj);
    }

    return list;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['url'] = url;
    map['ratio'] = ratio;
    map['width'] = width;
    map['height'] = height;

    return map;
  }
}
