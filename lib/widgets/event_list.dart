import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

import '../model/eventlink/event.dart';
import '../model/eventlink/user.dart';
import '../widgets/event_card.dart';
import '../constants/graphql_queries.dart';

enum EventListType {
  Regular,
  Favorite,
  Participating,
}

class EventList extends StatelessWidget {
  final String query;
  final String filter;
  final EventListType type;
  final User user;
  final List<User> buddies;
  final BuildContext scaffoldContext;

  EventList(
      {@required this.query,
      @required this.filter,
      @required this.type,
      @required this.user,
      @required this.buddies,
      @required this.scaffoldContext});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Query(
        options: QueryOptions(
          documentNode: gql(GraphQLQueries.eventSearchQuery),
          variables: {'query': query, 'filter': filter},
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
          return _eventListView(context, result);
        },
      ),
    );
  }

  Widget _eventListView(BuildContext context, QueryResult result) {
    try {
      final events = parseEvents(result);
      return ListView.builder(
        itemBuilder: (ctx, index) {
          final event = events[index];

          List<User> partBuddies = new List();

          for (var buddy in buddies) {
            if (buddy.participatingEvents.contains(event.id))
              partBuddies.add(buddy);
          }

          return EventCard(
            event: event,
            user: user,
            type: type,
            partBuddies: partBuddies,
            scaffoldContext: scaffoldContext,
          );
        },
        itemCount: events.length,
      );
    } catch (e) {
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

  List<Event> parseEvents(QueryResult result) {
    final jsonEvents = result.data['searchEvents'] as List<dynamic>;
    final List<Event> events = new List();

    if (type == EventListType.Regular) {
      jsonEvents.forEach(
        (jsonEvent) {
          if (jsonEvent['isActive'].toString() == 'true') {
            events.add(Event.fromJson(jsonEvent));
          }
        },
      );
    } else if (type == EventListType.Favorite) {
      jsonEvents.forEach(
        (jsonEvent) {
          var e = Event.fromJson(jsonEvent);
          if (e.isActive && user.favoriteEvents.contains(e.id)) {
            events.add(Event.fromJson(jsonEvent));
          }
        },
      );
    } else {
      jsonEvents.forEach(
        (jsonEvent) {
          var e = Event.fromJson(jsonEvent);
          if (e.isActive && user.participatingEvents.contains(e.id)) {
            events.add(Event.fromJson(jsonEvent));
          }
        },
      );
    }
    return events;
  }
}
