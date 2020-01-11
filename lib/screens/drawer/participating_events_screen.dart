import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../widgets/event_list.dart';
import '../../model/eventlink/user.dart';
import '../../api/eventlink_handler.dart';

class ParticipatingEventsScreen extends StatefulWidget {
  final User user;
  final List<User> buddies;

  ParticipatingEventsScreen({@required this.user, @required this.buddies});

  @override
  _ParticipatingEventsScreenState createState() =>
      _ParticipatingEventsScreenState();
}

class _ParticipatingEventsScreenState extends State<ParticipatingEventsScreen> {
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
              child: EventList(
                  query: query,
                  filter: '',
                  type: EventListType.Participating,
                  user: widget.user,
                  buddies: widget.buddies,
                  scaffoldContext: context),
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
        'Participating Events',
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
          hintText: "search your participating events...",
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
