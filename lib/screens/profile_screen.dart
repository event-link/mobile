import 'package:EventLink/constants/graphql_queries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../model/eventlink/user.dart';
import '../api/eventlink_handler.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final User buddy;

  ProfileScreen({@required this.user, @required this.buddy});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      appBar: AppBar(),
      body: Builder(
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter,
          decoration: _createGradiant(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _createProfilePicture(context),
                Divider(),
                _addOrRemoveBuddy(widget.user, widget.buddy, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createProfilePicture(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.14,
              width: MediaQuery.of(context).size.width * 0.30,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(1000)),
                border: new Border.all(
                  color: Theme.of(context).accentColor,
                  width: 3.5,
                ),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(widget.buddy.picUrl),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(
                widget.buddy.fullName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _addOrRemoveBuddy(User user, User buddy, BuildContext context) {
    if (user.buddies.contains(buddy.id)) {
      return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
        child: SizedBox(
          width: 250,
          height: 50,
          child: RaisedButton(
            child: new Text(
              "Remove Buddy",
              style: new TextStyle(color: Colors.white, fontSize: 16),
            ),
            shape: new RoundedRectangleBorder(
                side: BorderSide(color: Colors.black12),
                borderRadius: new BorderRadius.circular(30.0)),
            color: Theme.of(context).primaryColor,
            onPressed: () => _mutationRemoveBuddy(context),
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
        child: SizedBox(
          width: 250,
          height: 50,
          child: RaisedButton(
            child: new Text(
              "Add Buddy",
              style: new TextStyle(color: Colors.white, fontSize: 16),
            ),
            shape: new RoundedRectangleBorder(
                side: BorderSide(color: Colors.black12),
                borderRadius: new BorderRadius.circular(30.0)),
            color: Theme.of(context).primaryColor,
            onPressed: () => _mutationAddBuddy(context),
          ),
        ),
      );
    }
  }

  Future _mutationRemoveBuddy(BuildContext context) async {
    QueryResult result = await eventLinkHandler.clientToQuery().mutate(
          MutationOptions(
            document: GraphQLQueries.removeBuddyMutation,
            variables: {
              'userId': widget.user.id,
              'buddyId': widget.buddy.id,
            },
          ),
        );

    if (result.loading) {
      _showSnackBar(context, "Loading...");
    }

    if (result.hasErrors) {
      var errors = result.errors.toString();
      _showSnackBar(context, "Something went wrong: " + errors);
    } else {
      _showSnackBar(context, widget.buddy.firstName + ' has been removed 💔');
      setState(() {
        widget.user.buddies.remove(widget.buddy.id);
      });
    }
  }

  Future _mutationAddBuddy(BuildContext context) async {
    QueryResult result = await eventLinkHandler.clientToQuery().mutate(
          MutationOptions(
            document: GraphQLQueries.addBuddyMutation,
            variables: {
              'userId': widget.user.id,
              'buddyId': widget.buddy.id,
            },
          ),
        );

    if (result.loading) {
      _showSnackBar(context, "Loading...");
    }

    if (result.hasErrors) {
      var errors = result.errors.toString();
      _showSnackBar(context, "Something went wrong: " + errors);
    } else {
      _showSnackBar(context, widget.buddy.firstName + ' has been added 💖');
      setState(() {
        widget.user.buddies.add(widget.buddy.id);
      });
    }
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
