import 'package:EventLink/model/signin_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/eventlink/user_input.dart';
import '../../api/eventlink_handler.dart';
import '../../constants/graphql_queries.dart';
import '../../model/auth_model.dart';
import '../../screens/home_screen.dart';
import '../../constants/constants.dart';
import '../../model/eventlink/user.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key key}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final EventLinkHandler eventLinkHandler = EventLinkHandler();

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();

  bool _agreedToTOS = false;
  BuildContext scaffoldContext;

  @override
  Widget build(BuildContext context) {
    if (Constants.debugMode) {
      if (emailController.text.isEmpty)
        emailController.text = "eventlinkmail@gmail.com";
      if (passwordController.text.isEmpty) passwordController.text = "password";
      if (firstNameController.text.isEmpty)
        firstNameController.text = "TestUser";
      if (lastNameController.text.isEmpty) lastNameController.text = "McTest";
    }
    eventLinkHandler.authenticateCreateUser(context);
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
              _createSignUpForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createSignUpForm(BuildContext context) {
    scaffoldContext = context;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _createSignUpFields(),
            _createTos(),
            _createRegisterButton(context, "Register"),
          ],
        ),
      ),
    );
  }

  bool _submittable() {
    return _agreedToTOS;
  }

  void _submit() async {
    if (!_formKey.currentState.validate()) {
       _showSnackBar(scaffoldContext, "Please solve any form issues!");
      return;
    }

    var userInput = UserInput(
      loginMethod: LoginMethod.Eventlink,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      fullName: firstNameController.text.trim() +
          " " +
          lastNameController.text.trim(),
      email: emailController.text.trim(),
      hashedPassword: passwordController.text.trim(),
      birthdate: DateTime(1990, 1, 1),
      lastActivityDate: DateTime.now()
    ).toJson();

    QueryResult result = await eventLinkHandler.clientToQuery().mutate(
          MutationOptions(
            documentNode: gql(GraphQLQueries.createUserMutation),
            variables: {
              'userInput': userInput,
            },
          ),
        );

    if (result.loading) {
      _showSnackBar(scaffoldContext, "Loading...");
    }

    if (result.hasException) {
      var errors = result.exception.toString();
      if (errors.contains("already exists!")) {
        _showSnackBar(
            scaffoldContext, userInput['email'] + " is already registered.");
      } else {
        _showSnackBar(scaffoldContext, "Something went wrong: " + errors);
        print(errors);
      }
    } else {
      var signInModel = new SignInModel(
          email: userInput['email'], password: userInput['hashedPassword']);

      AuthModel authModel =
          await eventLinkHandler.authenticateUser(scaffoldContext, signInModel);

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
          scaffoldContext,
          result.exception.toString(),
        );
      }

      final jsonUser = result.data['userByEmail'];
      final user = User.fromJson(jsonUser);

      var prefs = await SharedPreferences.getInstance();
      prefs.setString("userEmail", user.email);
      prefs.setString("userToken", authModel.token);

      _showSnackBar(scaffoldContext, "Signed in!");

      Navigator.push(
        scaffoldContext,
        MaterialPageRoute(
          builder: (scaffoldContext) =>
              HomeScreen(authModel: authModel, user: user),
        ),
      );
    }
  }

  void _setAgreedToTOS(bool newValue) {
    setState(
      () {
        _agreedToTOS = newValue;
      },
    );
  }

  Widget _createTos() {
    return Container(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Checkbox(
                checkColor: Colors.white,
                activeColor: Colors.grey,
                value: _agreedToTOS,
                onChanged: _setAgreedToTOS,
              ),
              GestureDetector(
                onTap: () => _setAgreedToTOS(!_agreedToTOS),
                child: const Text(
                  'I agree to the Terms of Services and Privacy Policy',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createSignUpFields() {
    return Container(
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
          const SizedBox(height: 10.0),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: firstNameController,
            decoration: InputDecoration(
              labelText: "First name",
              labelStyle: TextStyle(color: Colors.white),
            ),
            validator: (String value) {
              if (value.trim().isEmpty || value.trim().length < 2) {
                return 'First name is required';
              }
            },
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: lastNameController,
            decoration: InputDecoration(
              labelText: "Last name",
              labelStyle: TextStyle(color: Colors.white),
            ),
            validator: (String value) {
              if (value.trim().isEmpty || value.trim().length < 2) {
                return 'Last name is required';
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _createLogo() {
    return Container(
      width: MediaQuery.of(context).size.width * 1.5,
      height: MediaQuery.of(context).size.width * 0.50,
      padding: EdgeInsets.fromLTRB(
          0, MediaQuery.of(context).size.width * 0.19, 0, 0),
      alignment: Alignment.topCenter,
      child: Image.asset('assets/images/eventlink.png'),
    );
  }

  Widget _createRegisterButton(BuildContext context, String text) {
    return Container(
      alignment: Alignment.center,
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
          onPressed: _submittable() ? _submit : null,
        ),
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
}
