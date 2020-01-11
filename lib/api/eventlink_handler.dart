import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../model/auth_model.dart';
import '../model/signin_model.dart';

class EventLinkHandler {
  static final EventLinkHandler _instance = EventLinkHandler._internal();

  final HttpLink _apiUrl = HttpLink(
    uri: Constants.elGraphqlApiUrl,
  );

  AuthLink _authLink;
  Link _link;
  ValueNotifier<GraphQLClient> client;

  factory EventLinkHandler() {
    return _instance;
  }

  EventLinkHandler._internal();

  void initHandler(String token) {
    _authLink = AuthLink(getToken: () async => 'Bearer $token');
    _link = _authLink.concat(_apiUrl);
    client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: _link,
      ),
    );
  }

  GraphQLClient clientToQuery() {
    return GraphQLClient(
      cache: InMemoryCache(),
      link: _link,
    );
  }

  Future<AuthModel> authenticateUser(
      BuildContext context, SignInModel signInModel) async {
    if (signInModel == null) throw Exception("SignInModel is null!");

    var body = "{ \"Email\": \"" +
        signInModel.email +
        "\", \"Password\": \"" +
        signInModel.password +
        "\"}";

    var response = await http.post(
      Constants.elAuthApiUrl,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
      body: body,
    );

    var jsonStr = json.decode(response.body);

    var auth = new AuthModel(
      token: jsonStr["token"],
      message: jsonStr["message"],
      email: signInModel.email,
    );

    if (response.statusCode != HttpStatus.ok) {
      Exception('Something went wrong with sign in!');
    }

    return auth;
  }

  void authenticateCreateUser(BuildContext context) async {
    var signInModel = new SignInModel(
        email: "CreateUser@eventlink.ml",
        password: "EventLinkCreateUserPassword");

    AuthModel authModel;
    await authenticateUser(context, signInModel).then(
      (result) async {
        authModel = result;
      },
    );

    if (authModel == null) {
      throw Exception("AuthModel is null!");
    }

    initHandler(authModel.token);
  }

  Future<String> sendForgotPasswordEmail(String email) async {
    if (email == null || email.length == 0) {
      throw Exception("Invalid email!");
    }

    var body = "{ \"Email\": \"" + email + "\" }";

    var apiUrl = Constants.elAuthApiUrl + '/forgotpassword';

    var response = await http.post(
      apiUrl,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
      body: body,
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to reset password for " +
          email +
          ". Ensure the email is valid.");
    }

    return response.body;
  }
}