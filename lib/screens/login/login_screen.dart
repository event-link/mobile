import 'package:EventLink/screens/login/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../constants/constants.dart';
import './sign_in_screen.dart';
import '../login/sign_up_screen.dart';
import '../../api/facebook_handler.dart';
import '../../api/google_handler.dart';

class LoginScreen extends StatefulWidget {
  @override
  MyButtonState createState() {
    return new MyButtonState();
  }
}

class MyButtonState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: MediaQuery.of(context).size.width * 0.3),
              _createButtonContainer(
                context,
                () => FacebookHandler.signIn(context),
                () => GoogleHandler.signIn(context),
                () {},
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(),
                  ),
                ),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(),
                  ),
                ),
              ),
              _createVersionText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createLoginButton(
      BuildContext context, String text, Function onPressed) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(5),
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

  Widget _createButtonContainer(
      BuildContext context,
      Function facebookOnPressed,
      Function googleOnPressed,
      Function appleOnPressed,
      Function elOnPressed,
      Function signUpPressed) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _createLoginButton(context, "Facebook", facebookOnPressed),
          _createLoginButton(context, "Google", googleOnPressed),
          _createLoginButton(context, "Apple", appleOnPressed),
          _createLoginButton(context, "EventLink", elOnPressed),
          _createSignUpButton(context, "Sign Up", signUpPressed),
        ],
      ),
    );
  }

  Widget _createSignUpButton(
      BuildContext context, String text, Function onPressed) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.61,
        height: MediaQuery.of(context).size.width * 0.12,
        child: RaisedButton(
          child: new Text(
            text,
            style: new TextStyle(color: Colors.white, fontSize: 16),
          ),
          shape: new RoundedRectangleBorder(
              side: BorderSide(color: Colors.black12),
              borderRadius: new BorderRadius.circular(30.0)),
          color: Theme.of(context).accentColor,
          onPressed: onPressed,
        ),
      ),
    );
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

  Widget _createVersionText() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.bottomCenter,
        child: Text(
          Constants.appName + " " + Constants.version + ". All Rights Reserved",
          style: TextStyle(color: Theme.of(context).accentColor, fontSize: 12),
        ),
      ),
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
}
