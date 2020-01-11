import 'package:EventLink/api/eventlink_handler.dart';
import 'package:EventLink/constants/graphql_queries.dart';
import 'package:EventLink/model/eventlink/user.dart';
import 'package:EventLink/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class BuddyListItem {
  final User user1, user2, user3;

  BuddyListItem(
      {@required this.user1, @required this.user2, @required this.user3});
}

class BuddyList extends StatefulWidget {
  final String query;
  final User user;
  final List<String> allUserIds;
  final BuildContext scaffoldContext;

  BuddyList(
      {@required this.query,
      @required this.user,
      @required this.allUserIds,
      @required this.scaffoldContext});

  @override
  _BuddyListState createState() => _BuddyListState();
}

class _BuddyListState extends State<BuddyList> {
  final EventLinkHandler eventLinkHandler = EventLinkHandler();
  List<String> buddyIds;

  void initState() {
    super.initState();
    widget.allUserIds.remove(widget.user.id);
    buddyIds = List<String>.from(widget.user.buddies);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Query(
        options: QueryOptions(
          document: GraphQLQueries.searchUsersQuery,
          variables: {'query': widget.query},
          pollInterval: 5,
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          /*
          if (result.errors != null) {
            return Text(result.errors.toString());
          }
          */

          if (result.loading || result == null || result.data == null) {
            Container(
              decoration: _createGradiant(),
              child: Center(
                child: Loading(indicator: BallPulseIndicator(), size: 100.0),
              ),
            );
          }
          return _buddyListView(context, result);
        },
      ),
    );
  }

  List<BuddyListItem> parseToListItems(List<User> users) {
    List<BuddyListItem> buddyItems = new List();
    for (var i = 0; i < users.length; i += 3) {
      var item = BuddyListItem(
        user1: checkUserListIndex(users, i),
        user2: checkUserListIndex(users, i + 1),
        user3: checkUserListIndex(users, i + 2),
      );
      buddyItems.add(item);
    }
    return buddyItems;
  }

  Widget _buddyListView(BuildContext context, QueryResult result) {
    try {
      final jsonUsers = result.data['searchUsers'] as List<dynamic>;
      final List<User> users = new List();

      jsonUsers.forEach(
        (jsonUser) {
          if (jsonUser['email'].toString() == 'CreateUser@eventlink.ml' ||
              jsonUser['id'].toString() == widget.user.id ||
              jsonUser['isActive'].toString() == 'false') {
            return;
          }
          users.add(User.fromJson(jsonUser));
        },
      );

      var listItems = parseToListItems(users);

      return ListView.builder(
        itemBuilder: (ctx, index) {
          var item = listItems[index];
          return _createUserListItem(item, index, context);
        },
        itemCount: listItems.length,
      );
    } catch (e) {
      print(e.toString());
      return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: _createGradiant(),
        child: Center(
          child: Loading(indicator: BallPulseIndicator(), size: 100.0),
        ),
      );
    }
  }

  User checkUserListIndex(List<User> users, int index) {
    try {
      return users[index];
    } catch (e) {
      return null;
    }
  }

  Widget _createUserListItem(
      BuddyListItem buddyItem, int index, BuildContext context) {
    try {
      return Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.30,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _createBuddyImage(buddyItem.user1, context) ?? Container(),
            _createBuddyImage(buddyItem.user2, context) ?? Container(),
            _createBuddyImage(buddyItem.user3, context) ?? Container(),
          ],
        ),
      );
    } catch (e) {
      print(e);
      return Container(
        height: 70,
        width: 70,
        margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
        color: Colors.transparent,
        child: Center(
          child: Loading(indicator: BallPulseIndicator(), size: 50.0),
        ),
      );
    }
  }

  Widget _createBuddyImage(User user, BuildContext context) {
    var isFriend = buddyIds.contains(user.id);

    var image = NetworkImage(user.picUrl);
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 0.30,
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Flexible(
            child: GestureDetector(
              onTap: () => _navigateToUser(image, user.email, context),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.30,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.all(new Radius.circular(50)),
                  border: new Border.all(
                    color: Theme.of(context).accentColor,
                    width: 3.5,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: image,
                  ),
                ),
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFriend
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                    ),
                    child: Icon(
                      isFriend ? Icons.person : null,
                      color: isFriend ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Text(
              user.fullName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Hind', fontSize: 10.0, color: Colors.white70),
            ),
          )
        ],
      ),
    );
  }

  void _navigateToUser(
      NetworkImage image, String email, BuildContext context) async {
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
