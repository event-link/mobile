import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

import '../model/eventlink/user.dart';
import '../api/eventlink_handler.dart';
import '../constants/graphql_queries.dart';
import '../screens/profile_screen.dart';

class PartBuddyList extends StatefulWidget {
  final String eventId;
  final List<User> partBuddies;
  final User user;

  PartBuddyList(
      {@required this.eventId,
      @required this.partBuddies,
      @required this.user});

  @override
  _PartBuddyListState createState() => _PartBuddyListState();
}

class _PartBuddyListState extends State<PartBuddyList> {
  final EventLinkHandler eventLinkHandler = EventLinkHandler();

  @override
  Widget build(BuildContext context) {
    if (widget.partBuddies.length == 0) {
      return Container(
        child: Text(
          "None of your buddies are participating in this event 😪",
          style: TextStyle(
              fontFamily: 'Hind', fontSize: 14.0, color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (ctx, index) {
        try {
          return _createBuddyImage(
            NetworkImage(widget.partBuddies[index].picUrl),
            widget.partBuddies[index].firstName,
            widget.partBuddies[index].email,
          );
        } catch (e) {
          return Container(
            height: 70,
            width: 70,
            margin: EdgeInsets.all(5),
            color: Colors.transparent,
            child: Center(
              child: Loading(indicator: BallPulseIndicator(), size: 30.0),
            ),
          );
        }
      },
      itemCount: widget.partBuddies.length,
    );
  }

  Widget _createBuddyImage(NetworkImage image, String name, String email) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => _navigateToUser(image, email),
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(500)),
                border: new Border.all(
                  color: Theme.of(context).accentColor,
                  width: 3,
                ),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: image,
                ),
              ),
            ),
          ),
          Container(
            child: Text(
              name,
              style: TextStyle(
                  fontFamily: 'Hind', fontSize: 11.0, color: Colors.white70),
            ),
          )
        ],
      ),
    );
  }

  void _navigateToUser(NetworkImage image, String email) async {
    QueryResult result = await eventLinkHandler.clientToQuery().query(
          QueryOptions(
            document: GraphQLQueries.getUserByEmailQuery,
            variables: {'email': email},
            pollInterval: 5,
          ),
        );

    if (result.loading) {
      print("Loading...");
    }

    if (result.hasErrors) {
      print("Errors: " + result.errors.toString());
    }

    final jsonUser = result.data['userByEmail'] as dynamic;
    final buddy = User.fromJson(jsonUser);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(user: widget.user, buddy: buddy),
      ),
    );
  }
}
