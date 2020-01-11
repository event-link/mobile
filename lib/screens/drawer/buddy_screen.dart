import 'package:EventLink/api/eventlink_handler.dart';
import 'package:EventLink/widgets/buddy_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../model/eventlink/user.dart';

class BuddyScreen extends StatefulWidget {
  final User user;
  final List<String> allUserIds;

  BuddyScreen({@required this.user, @required this.allUserIds});

  @override
  _BuddyScreenState createState() => _BuddyScreenState();
}

class _BuddyScreenState extends State<BuddyScreen> {
  final EventLinkHandler eventLinkHandler = EventLinkHandler();

  String query = '';
  bool activeSearch = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    return Scaffold(
      appBar: _appBar(),
      body: Builder(
        builder: (context) => Container(
          decoration: _createGradiant(),
          child: Container(
            child: GraphQLProvider(
              child: BuddyList(
                query: query,
                user: widget.user,
                allUserIds: widget.allUserIds,
                scaffoldContext: context,
              ),
              client: eventLinkHandler.client,
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
      title: Text(
        'Buddies',
        style: TextStyle(color: Colors.white),
      ),
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
          hintText: "search for buddies...",
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
