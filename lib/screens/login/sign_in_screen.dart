import 'package:EventLink/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/signin_model.dart';
import '../../model/eventlink/user.dart';
import '../../screens/home_screen.dart';
import '../../api/eventlink_handler.dart';
import '../../constants/graphql_queries.dart';
import '../../constants/constants.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final EventLinkHandler eventLinkHandler = EventLinkHandler();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BuildContext scaffoldContext;

  @override
  Widget build(BuildContext context) {
    if (Constants.debugMode) {
      if (emailController.text.isEmpty)
        emailController.text = "iyyelsec@gmail.com";
      if (passwordController.text.isEmpty) passwordController.text = "password";
    }
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    return Scaffold(
      body: Builder(
        builder: (context) => Container(
          alignment: Alignment.center,
          decoration: _createGradiant(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _createLogo(),
              _createSignInForm(context),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    try {
      var authModel = await eventLinkHandler.authenticateUser(
        context,
        SignInModel(
            email: emailController.text, password: passwordController.text),
      );

      eventLinkHandler.initHandler(authModel.token);

      QueryResult result;

      await eventLinkHandler
          .clientToQuery()
          .query(
            QueryOptions(
              documentNode: gql(GraphQLQueries.getUserByEmailQuery),
              variables: {'email': authModel.email},
              pollInterval: 5,
            ),
          )
          .then(
        (queryResult) {
          result = queryResult;
        },
      );

      if (result.loading) {
        _showSnackBar(context, "Getting user...");
      }

      if (result.hasException) {
        var errors = result.exception.toString();

        if (errors.contains("credentials")) {
          _showSnackBar(scaffoldContext, "Incorrect credentials!");
        } else {
          _showSnackBar(scaffoldContext, "Couldn't sign in. Try again!");
        }
      }

      final jsonUser = result.data['userByEmail'];
      final user = User.fromJson(jsonUser);

      if (user.loginMethod != LoginMethod.Eventlink) {
        _showWrongLoginMethodDialog(context, user);
      }

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
    } catch (e) {
      var error = e.toString();
      if (error.contains("credentials")) {
        _showSnackBar(scaffoldContext, "Incorrect credentials!");
      }
      _showSnackBar(scaffoldContext, "Couldn't sign in. Try again!");
    }
  }

  Widget _createSignInForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _createSignInFields(),
            _createSpace(),
            _createSignInButton(
              context,
              "Sign In",
              () => _signIn(),
            ),
            _createSpace(),
            _createForgotPasswordButton(),
          ],
        ),
      ),
    );
  }

  Widget _createForgotPasswordButton() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.width * 0.11,
        child: InkWell(
          onTap: () {
            _sendForgotPasswordMail(emailController.text);
          },
          child: new Text(
            "Forgot Password?",
            style: new TextStyle(color: Colors.deepOrange, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _sendForgotPasswordMail(String email) async {
    var apiResult;
    await eventLinkHandler.sendForgotPasswordEmail(email).then(
      (result) async {
        apiResult = result;
      },
      onError: (err) {
        apiResult = err.toString().substring(11, err.toString().length);
      },
    );
    _showSnackBar(scaffoldContext, apiResult);
  }

  Widget _createLogo() {
    return Container(
      width: MediaQuery.of(context).size.width * 1.5,
      height: MediaQuery.of(context).size.width * 0.75,
      padding: EdgeInsets.fromLTRB(
          0, MediaQuery.of(context).size.width * 0.25, 0, 0),
      alignment: Alignment.topCenter,
      child: Image.asset('assets/images/eventlink.png'),
    );
  }

  Widget _createSignInButton(
      BuildContext context, String text, Function onPressed) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.width * 0.11,
        child: RaisedButton(
          child: new Text(
            text,
            style: new TextStyle(color: Colors.white, fontSize: 16),
          ),
          shape: new RoundedRectangleBorder(
              side: BorderSide(color: Colors.black12),
              borderRadius: new BorderRadius.circular(30.0)),
          color: Theme.of(context).primaryColor,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _createSpace() {
    return Container(
      height: 20,
    );
  }

  Widget _createSignInFields() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: InputDecoration(
              labelText: "E-mail",
              labelStyle: TextStyle(color: Colors.white),
            ),
            validator: (String value) {
              if (value.trim().isEmpty) {
                return 'E-mail is required';
              }
              if (!value.trim().contains('@') ||
                  !value.trim().contains('.') ||
                  value.trim().length < 2) return 'E-mail format is incorrect';
            },
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            obscureText: true,
            controller: passwordController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: Colors.white),
            ),
            validator: (String value) {
              if (value.trim().isEmpty) {
                return 'Password is required';
              }
              if (value.trim().length < 5) {
                return 'Password is not long enough';
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Theme.of(context).primaryColor,
    );
    Scaffold.of(context).showSnackBar(
      snackBar,
    );
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
