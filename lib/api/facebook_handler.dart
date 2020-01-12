import 'package:EventLink/constants/graphql_queries.dart';
import 'package:EventLink/model/eventlink/user_input.dart';
import 'package:EventLink/model/signin_model.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../model/auth_model.dart';
import '../screens/home_screen.dart';
import '../model/eventlink/user.dart';
import '../api/eventlink_handler.dart';

class FacebookHandler {
  static final FacebookHandler _instance = FacebookHandler._internal();
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  static final EventLinkHandler eventLinkHandler = EventLinkHandler();

  factory FacebookHandler() {
    return _instance;
  }

  FacebookHandler._internal();

  static Future<Null> signIn(BuildContext context) async {
    eventLinkHandler.authenticateCreateUser(context);

    final FacebookLoginResult result =
        await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        _signInSuccess(context, result);
        break;

      case FacebookLoginStatus.cancelledByUser:
        Exception('Login cancelled by the user.');
        break;

      case FacebookLoginStatus.error:
        Exception(
          'Something went wrong with the login process.\n'
          'Here\'s the error Facebook gave us: ${result.errorMessage}',
        );
        break;
    }
  }

  static void _signInSuccess(
      BuildContext context, FacebookLoginResult result) async {
    final accessToken = result.accessToken.token;

    _showSnackBar(context, "Signing in with Facebook...");

    /* Find information from the facebook GraphQL API. */
    var urlQuery =
        'https://graph.facebook.com/v4.0/me?fields=first_name,middle_name,last_name,address,email,birthday,name,id&access_token=$accessToken';
    final graphResponse = await http.get(urlQuery);

    /* Decodes the GraphQL response, so it can be used in the auth model. */
    final profile = json.decode(graphResponse.body);

    final profilePicUrl = 'https://graph.facebook.com/' +
        profile['id'] +
        '/picture?type=large&redirect=false';

    final jsonProfilePic = await http.get(profilePicUrl);
    final profilePicture = json.decode(jsonProfilePic.body);

    var newEmail =
        profile['email'].toString().replaceAll(new RegExp(r'\\u0040'), "@");
    profile['email'] = newEmail;

    /* Check if user is already is in DB (email) */
    _checkForUser(context, profile, profilePicture);
  }

  Future<Null> signOut(BuildContext context) async {
    await facebookSignIn.logOut();
    _showSnackBar(context, 'Signed out!');
  }

  static Future _checkForUser(
      BuildContext context, dynamic profile, dynamic jsonProfilePic) async {
    QueryResult result = await eventLinkHandler.clientToQuery().query(
          QueryOptions(
            documentNode: gql(GraphQLQueries.getUserByEmailQuery),
            variables: {'email': profile['email']},
            pollInterval: 5,
          ),
        );

    if (result.loading) {
      _showSnackBar(context, "Getting user...");
    }

    if (result.hasException) {
      /* If theres an error, this means that the user is not created in Eventlink. */
      if (result.exception.toString().toLowerCase().contains("not found")) {
        _createUser(context, profile, jsonProfilePic);
      } else {
        throw new Exception(
            "Something went wrong: " + result.exception.toString());
      }
    } else {
      final jsonUser = result.data['userByEmail'];
      final user = User.fromJson(jsonUser);

      if (user.loginMethod != LoginMethod.Facebook) {
        _showWrongLoginMethodDialog(context, user);
      } else {
        var signInModel = new SignInModel(
            email: profile['email'], password: _hashPassword(profile));

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

  static Future _createUser(
      BuildContext context, dynamic profile, dynamic jsonProfilePic) async {
    var hashedPassword = _hashPassword(profile);

    var userInput = new UserInput(
        accountType: AccountType.Regular,
        loginMethod: LoginMethod.Facebook,
        picUrl: jsonProfilePic['data']['url'],
        firstName: profile['first_name'],
        middleName: profile['middle_name'],
        lastName: profile['last_name'],
        fullName: profile['name'],
        email: profile['email'],
        address: "",
        birthdate: DateTime.now(),
        hashedPassword: hashedPassword,
        phoneNumber: "",
        country: "Denmark",
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

  static String _hashPassword(dynamic profile) {
    var bytes = utf8.encode(profile['id'].toString());
    var hashedPassword = sha512.convert(bytes);

    return hashedPassword.toString().toUpperCase();
  }

  static Future updateUser(BuildContext context, User user) async {
    QueryResult result = await eventLinkHandler.clientToQuery().mutate(
          MutationOptions(
            documentNode: gql(GraphQLQueries.updateUserMutation),
            variables: {
              'userInput': user.toJson(),
            },
          ),
        );

    if (result.loading) {
      _showSnackBar(context, "Loading...");
    }

    if (result.hasException) {
      var errors = result.exception.toString();
      _showSnackBar(context, "Something went wrong: " + errors);
    } else {
      _showSnackBar(context, 'Succesfully updated user! 👏');
      Navigator.of(context).pop();
    }
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
}
