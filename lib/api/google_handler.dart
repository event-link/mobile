import 'package:EventLink/api/eventlink_handler.dart';
import 'package:EventLink/constants/graphql_queries.dart';
import 'package:EventLink/model/auth_model.dart';
import 'package:EventLink/model/eventlink/user.dart';
import 'package:EventLink/model/eventlink/user_input.dart';
import 'package:EventLink/model/signin_model.dart';
import 'package:EventLink/screens/home_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'dart:convert';

import 'package:googleapis/people/v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleHandler {
  static final GoogleHandler _instance = GoogleHandler._internal();
  static final GoogleSignIn googleSignIn = GoogleSignIn();
  static final EventLinkHandler eventLinkHandler = EventLinkHandler();

  factory GoogleHandler() {
    return _instance;
  }

  GoogleHandler._internal();

  static Future<Null> signIn(BuildContext context) async {
    eventLinkHandler.authenticateCreateUser(context); 

     _showSnackBar(context, "Signing in with Google...");


    final _googleSignIn = new GoogleSignIn(scopes: [
      'https://www.googleapis.com/auth/contacts.readonly',
      'https://www.googleapis.com/auth/user.addresses.read',
      'https://www.googleapis.com/auth/user.birthday.read',
      'https://www.googleapis.com/auth/user.emails.read',
      'https://www.googleapis.com/auth/user.phonenumbers.read',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile'
    ]);

    await _googleSignIn.signIn();

    final authHeaders = await _googleSignIn.currentUser.authHeaders;
    final httpClient = new GoogleHttpClient(authHeaders);

    var data = await new PeopleApi(httpClient).people.get(
          'people/me',
          personFields:
              'names,photos,birthdays,phoneNumbers,addresses,residences,emailAddresses',
        );

    _checkForUser(context, data);
  }

  void signOut(BuildContext context, GoogleSignIn googleSignIn) async {
    await googleSignIn.signOut();
    _showSnackBar(context, 'Signed out!');
  }

  static String _hashPassword(String id) {
    var bytes = utf8.encode(id);
    var hashedPassword = sha512.convert(bytes);

    return hashedPassword.toString().toUpperCase();
  }

  static void _showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Theme.of(context).primaryColor,
    );
    Scaffold.of(context).showSnackBar(
      snackBar,
    );
  }

  static Future _createUser(BuildContext context, Person data) async {
    var hashedPassword = _hashPassword(data.names[0].metadata.source.id);

    String profilePicture = data.photos[0].url
            .toString()
            .substring(0, (data.photos[0].url.length - 3)) +
        "250";

    var userInput = new UserInput(
        accountType: AccountType.Regular,
        loginMethod: LoginMethod.Google,
        picUrl: profilePicture,
        firstName: data.names == null ? "" : data.names[0].givenName,
        middleName: data.names == null ? "" : data.names[0].middleName,
        lastName: data.names == null ? "" : data.names[0].familyName,
        fullName: data.names == null ? "" : data.names[0].displayName,
        email: data.emailAddresses == null ? "" : data.emailAddresses[0].value,
        address: data.addresses == null ? "" : data.addresses[0].streetAddress,
        birthdate: data.birthdays == null
            ? DateTime(1900, 1, 1)
            : DateTime(data.birthdays[0].date.year,
                data.birthdays[0].date.month, data.birthdays[0].date.day),
        hashedPassword: hashedPassword,
        phoneNumber:
            data.phoneNumbers == null ? "" : data.phoneNumbers[0].value,
        country: data.addresses == null ? "Denmark" : data.addresses[0].country,
        participatingEvents: List(),
        favoriteEvents: List(),
        pastEvents: List(),
        buddies: List(),
        payments: List(),
        lastActivityDate: DateTime.now(),
        isActive: true);

    QueryResult result = await eventLinkHandler.clientToQuery().mutate(
          MutationOptions(
            documentNode: gql(GraphQLQueries.createUserMutation),
            variables: {
              'userInput': userInput.toJson(),
            },
          ),
        );

    if (result.loading) {
      _showSnackBar(context, "Loading...");
    }

    if (result.hasException) {
      _showSnackBar(context, result.exception.toString());
    } else {
      var signInModel = new SignInModel(
          email: userInput.email, password: userInput.hashedPassword);

      AuthModel authModel =
          await eventLinkHandler.authenticateUser(context, signInModel);

      eventLinkHandler.initHandler(authModel.token);

      QueryResult result = await eventLinkHandler.clientToQuery().query(
            QueryOptions(
              documentNode: gql(GraphQLQueries.getUserByEmailQuery),
              variables: {'email': authModel.email},
              pollInterval: 5,
            ),
          );

      if (result.loading) {
        _showSnackBar(context, "Getting user...");
      }

      if (result.hasException) {
        _showSnackBar(
          context,
          result.exception.toString(),
        );
      } else {
        final jsonUser = result.data['userByEmail'];
        final user = User.fromJson(jsonUser);

        var prefs = await SharedPreferences.getInstance();
        prefs.setString("userEmail", user.email);
        prefs.setString("userToken", authModel.token);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              authModel: authModel,
              user: user,
            ),
          ),
        );
      }
    }
  }

  static Future _checkForUser(BuildContext context, Person profile) async {
    QueryResult result = await eventLinkHandler.clientToQuery().query(
          QueryOptions(
            documentNode: gql(GraphQLQueries.getUserByEmailQuery),
            variables: {'email': profile.emailAddresses[0].value},
            pollInterval: 5,
          ),
        );

    if (result.loading) {
      _showSnackBar(context, "Getting user...");
    }

    if (result.hasException) {
      /* If theres an error, this means that the user is not created in Eventlink. */

      if (result.exception.toString().toLowerCase().contains("not found")) {
        _createUser(context, profile);
      } else {
        throw new Exception(
            "Something went wrong: " + result.exception.toString());
      }

      /* If the user has been found */
    } else {
      final jsonUser = result.data['userByEmail'];
      final user = User.fromJson(jsonUser);

      if (user.loginMethod != LoginMethod.Google) {
        _showWrongLoginMethodDialog(context, user);
      } else {
        var signInModel = new SignInModel(
            email: profile.emailAddresses[0].value,
            password: _hashPassword(profile.names[0].metadata.source.id));

        AuthModel authModel =
            await eventLinkHandler.authenticateUser(context, signInModel);

        var prefs = await SharedPreferences.getInstance();
        prefs.setString("userEmail", user.email);
        prefs.setString("userToken", authModel.token);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              authModel: authModel,
              user: user,
            ),
          ),
        );
      }
    }
  }

  static void _showWrongLoginMethodDialog(BuildContext context, User user) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Wrong login method",
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal),
          ),
          content: new Text(
            "User has been logged in with " +
                user.loginMethod
                    .toString()
                    .substring(12, user.loginMethod.toString().length) +
                ", please sign in this way!",
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            new FlatButton(
              child: new Text(
                "Go back",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}
