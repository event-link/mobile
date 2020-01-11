import 'package:EventLink/api/eventlink_handler.dart';
import 'package:EventLink/model/auth_model.dart';
import 'package:EventLink/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/graphql_queries.dart';
import 'model/eventlink/user.dart';
import 'screens/login/login_screen.dart';

Future main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('userEmail');
  var token = prefs.getString('userToken');
  final isLoggedIn = email == null || email == "" ? false : true;
  runApp(MainScreen(isLoggedIn: isLoggedIn, email: email, token: token));
}

class MainScreen extends StatelessWidget {
  final isLoggedIn;
  final email;
  final token;

  MainScreen(
      {@required this.isLoggedIn, @required this.email, @required this.token});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    return MaterialApp(
      home: isLoggedIn
          ? StartHomeScreen(
              email: email,
              token: token,
            )
          : StartLoginScreen(),
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Color(0xFFBFD8BD),
        accentColor: Color(0xFFa6c998),
        backgroundColor: Color(0xFF98C9A3),
        cardColor: Color(0xFFFFFFFF),
        hintColor: Color(0xFF879B99),
        canvasColor: Color(0xFFBFD8BD),

        // Define the default font family.
        fontFamily: 'Montserrat',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          body1: TextStyle(
              fontSize: 11.0, fontFamily: 'Hind', color: Colors.black87),
          body2:
              TextStyle(fontSize: 11.0, fontFamily: 'Hind', color: Colors.grey),
        ),
        buttonTheme: ButtonThemeData(minWidth: 200.00, height: 40.00),
      ),
    );
  }
}

class StartLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginScreen(),
    );
  }
}

class StartHomeScreen extends StatelessWidget {
  final String email;
  final String token;

  final EventLinkHandler eventLinkHandler = EventLinkHandler();

  StartHomeScreen({@required this.email, @required this.token});

  @override
  Widget build(BuildContext context) {
    final authModel = new AuthModel(email: email, token: token);
    eventLinkHandler.initHandler(token);
    return new FutureBuilder<User>(
      future: _getUser(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: _createGradiant(),
              child: Center(
                child: Loading(indicator: BallPulseIndicator(), size: 100.0),
              ),
            );
          case ConnectionState.waiting:
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: _createGradiant(),
              child: Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Loading(indicator: BallPulseIndicator(), size: 100.0),
                ),
              ),
            );
          default:
            if (snapshot.hasError) {
              return new Scaffold(
                body: LoginScreen(),
              );
            } else
              return new Scaffold(
                body: HomeScreen(user: snapshot.data, authModel: authModel),
              );
        }
      },
    );
  }

  Future<User> _getUser() async {
    QueryResult result = await eventLinkHandler.clientToQuery().query(
          QueryOptions(
            document: GraphQLQueries.getUserByEmailQuery,
            variables: {'email': email},
            pollInterval: 5,
          ),
        );

    if (result.loading) {
      print("Getting user...");
    }

    if (result.hasErrors) {
      print(result.errors.toString());
    }

    final jsonUser = result.data['userByEmail'];
    User user = User.fromJson(jsonUser);
    return user;
  }

  BoxDecoration _createGradiant() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.3, 0.5, 0.8, 1],
        colors: [
          Color(0xFF6d9074),
          Color(0xFF8dba97),
          Color(0xFF98c9a3),
          Color(0xFFbae9c5),
          Color(0xFFe0ffeb)
        ],
      ),
    );
  }
}
