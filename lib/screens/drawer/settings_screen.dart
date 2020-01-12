import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../api/eventlink_handler.dart';
import '../../constants/graphql_queries.dart';
import '../../model/eventlink/user.dart';
import '../../screens/login/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  SettingsScreen({@required this.user});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final EventLinkHandler eventLinkHandler = EventLinkHandler();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Builder(
        builder: (context) => Container(
          decoration: _createGradiant(),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                _deactivateUserButton(context),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deactivateUserButton(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.width * 0.11,
        child: RaisedButton(
            child: new Text(
              "Deactivate User",
              style: new TextStyle(color: Colors.white, fontSize: 16),
            ),
            shape: new RoundedRectangleBorder(
                side: BorderSide(color: Colors.black12),
                borderRadius: new BorderRadius.circular(30.0)),
            color: Theme.of(context).primaryColor,
            onPressed: () => _showDeactivateDialog(context)),
      ),
    );
  }

  Future updateUser(BuildContext context) async {
    var map = widget.user.toJson();

    QueryResult result = await eventLinkHandler.clientToQuery().mutate(
          MutationOptions(
            documentNode: gql(GraphQLQueries.updateUserMutation),
            variables: {
              'userInput': map,
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
      _showSnackBar(context, 'Succesfully deactivated user! 😾');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ),
          ModalRoute.withName('/'));
    }
  }

  void _showDeactivateDialog(BuildContext scaffoldContext) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Deactivate User",
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal),
          ),
          content: new Text(
            "Are you sure you want to deactivate your user? You will not be able to sign in to EventLink again!",
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal),
          ),
          backgroundColor: Theme.of(scaffoldContext).backgroundColor,
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Deactivate",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () => _deactivateUser(scaffoldContext),
            ),
            new FlatButton(
              child: new Text(
                "Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(scaffoldContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deactivateUser(BuildContext context) {
    widget.user.isActive = false;

    updateUser(context);
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
}

BoxDecoration _createGradiant() {
  return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [
        0.0,
        0.3,
        0.5,
        0.8,
        1
      ],
          colors: [
        Color(0xFF6d9074),
        Color(0xFF8dba97),
        Color(0xFF98c9a3),
        Color(0xFFbae9c5),
        Color(0xFFe0ffeb)
      ]));
}
