import 'package:EventLink/api/apple_handler.dart';
import 'package:EventLink/api/facebook_handler.dart';
import 'package:EventLink/api/google_handler.dart';
import 'package:EventLink/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/eventlink/user.dart';
import '../screens/drawer/about_screen.dart';
import '../screens/drawer/buddy_screen.dart';
import '../screens/drawer/favorite_events_screen.dart';
import '../screens/drawer/user_profile_screen.dart';
import '../screens/drawer/settings_screen.dart';
import '../widgets/event_list.dart';
import '../api/eventlink_handler.dart';
import '../constants/constants.dart';
import '../constants/graphql_queries.dart';
import 'drawer/participating_events_screen.dart';

class HomeScreen extends StatefulWidget {
  final authModel;
  final User user;

  HomeScreen({@required this.authModel, @required this.user});

  @override
  MyButtonState createState() {
    return new MyButtonState();
  }
}

class MyButtonState extends State<HomeScreen> {
  final EventLinkHandler eventLinkHandler = EventLinkHandler();
  final FacebookHandler fbHandler = FacebookHandler();
  final GoogleHandler glHandler = GoogleHandler();
  final AppleHandler aplHandler = AppleHandler();

  bool activeSearch = false;
  String query = '';
  List<User> buddies = List();
  List<String> allUserIds = List();

  @override
  void initState() {
    super.initState();
    _getBuddies(context);
    _getAllUserIds(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    eventLinkHandler.initHandler(widget.authModel.token);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        appBar: _appBar(),
        drawer: Drawer(
          child: Container(
            decoration: _createGradiant(),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      _createHeader(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      ),
                      _createDrawerItem(
                        icon: Icons.person,
                        text: "User Profile",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileScreen(user: widget.user),
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey),
                      _createDrawerItem(
                        icon: Icons.group,
                        text: "Buddies",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuddyScreen(
                              user: widget.user,
                              allUserIds: allUserIds,
                            ),
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey),
                      _createDrawerItem(
                        icon: Icons.favorite_border,
                        text: "Favorite events",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoriteEventsScreen(
                                user: widget.user, buddies: buddies),
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey),
                      _createDrawerItem(
                        icon: Icons.shopping_cart,
                        text: "Participating events",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParticipatingEventsScreen(
                                user: widget.user, buddies: buddies),
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey),
                      _createDrawerItem(
                        icon: Icons.settings,
                        text: "Settings",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SettingsScreen(user: widget.user),
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey),
                      _createDrawerItem(
                        icon: Icons.help_outline,
                        text: "About",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutScreen()),
                        ),
                      ),
                      Divider(color: Colors.grey),
                      _createDrawerItem(
                        icon: Icons.exit_to_app,
                        text: "Sign Out",
                        onTap: () => _showSignOutDialog(),
                      ),
                      Divider(color: Colors.grey),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    alignment: Alignment.bottomCenter,
                    child: createVersionText(),
                  ),
                )
              ],
            ),
          ),
        ),
        body: Builder(
          builder: (context) => Container(
            decoration: _createGradiant(),
            child: Container(
              child: GraphQLProvider(
                child: EventList(
                    query: query,
                    filter: '',
                    type: EventListType.Regular,
                    user: widget.user,
                    buddies: buddies,
                    scaffoldContext: context),
                client: eventLinkHandler.client,
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    if (activeSearch) {
      return _createSearchAppBar();
    } else {
      return _createNormalAppBar();
    }
  }

  Widget _createNormalAppBar() {
    return AppBar(
      iconTheme: new IconThemeData(color: Colors.white),
      title: Text(''),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () => setState(() => activeSearch = true),
        ),
      ],
    );
  }

  Widget _createSearchAppBar() {
    return AppBar(
      iconTheme: new IconThemeData(color: Colors.white),
      leading: Icon(
        Icons.search,
        color: Colors.white,
      ),
      title: TextField(
        onChanged: _search,
        decoration: InputDecoration(
          hintText: "search for events...",
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () => setState(() => activeSearch = false),
        )
      ],
    );
  }

  void _search(String queryString) {
    setState(
      () {
        query = queryString;
      },
    );
  }

  Widget _createHeader() {
    return Container(
      height: 210,
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(color: Color(0xFF6d9074)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.width * 0.30,
              width: MediaQuery.of(context).size.width * 0.30,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(500)),
                border: new Border.all(
                    color: Theme.of(context).accentColor, width: 3.5),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(widget.user.picUrl),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
              alignment: Alignment.bottomCenter,
              child: Text(
                widget.user.fullName,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({IconData icon, String text, Function onTap}) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: SizedBox(
        height: MediaQuery.of(context).size.width * 0.09,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              Icon(icon, color: Colors.white),
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget createVersionText() {
    return Text(
      Constants.appName + " " + Constants.version + ". All Rights Reserved",
      style: TextStyle(color: Theme.of(context).accentColor, fontSize: 12),
    );
  }

  void _getBuddies(BuildContext context) async {
    QueryResult result = await eventLinkHandler.clientToQuery().query(
          QueryOptions(
            document: GraphQLQueries.getBuddiesQuery,
            variables: {
              'userId': widget.user.id,
            },
          ),
        );

    if (result.loading) {
      _showSnackBar(context, "Loading buddies...");
    }

    if (result.hasErrors) {
      var errors = result.errors.toString();
      _showSnackBar(context, "Errors during loading buddies: " + errors);
    }

    var buddiesJson = await result.data['buddies'];

    final List<User> buddiesTmp = new List();

    for (var jsonBud in buddiesJson) {
      final User buddy = User.fromJson(jsonBud);
      buddiesTmp.add(buddy);
    }

    setState(() {
      buddies = buddiesTmp;
    });
  }

  void _getAllUserIds(BuildContext context) async {
    QueryResult result = await eventLinkHandler.clientToQuery().query(
          QueryOptions(
            document: GraphQLQueries.searchUsersIdsQuery,
            variables: {
              'query': '',
            },
          ),
        );

    if (result.loading) {
      _showSnackBar(context, "Loading users...");
    }

    if (result.hasErrors) {
      var errors = result.errors.toString();
      _showSnackBar(context, "Errors during loading users: " + errors);
    }

    var usersJson = await result.data['searchUsers'];

    final List<String> userIdsTmp = new List();

    for (var jsonUser in usersJson) {
      final User user = User.fromJson(jsonUser);
      userIdsTmp.add(user.id);
    }

    setState(() {
      allUserIds = userIdsTmp;
    });
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

  Future<bool> _onWillPop() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  void _signOut() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("userEmail", "");
    prefs.setString("userToken", "");

    fbHandler.signOut(context);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
        ),
        ModalRoute.withName('/'));
  }

  void _showSignOutDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Sign Out",
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal),
          ),
          content: new Text(
            "Are you sure you want to sign out of EventLink?",
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Sign Out",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () => _signOut(),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
