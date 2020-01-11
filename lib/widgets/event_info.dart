import 'package:EventLink/widgets/event_list.dart';
import 'package:EventLink/widgets/part_buddy_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/eventlink/event.dart';
import '../model/eventlink/user.dart';
import '../api/eventlink_handler.dart';
import '../constants/graphql_queries.dart';

class EventInfo extends StatefulWidget {
  final User user;
  final Event event;
  final List<User> partBuddies;
  final EventListType type;
  final BuildContext scaffoldContext;

  EventInfo(
      {@required this.user,
      @required this.event,
      @required this.partBuddies,
      @required this.type,
      @required this.scaffoldContext});

  @override
  _EventInfoState createState() => _EventInfoState();
}

class _EventInfoState extends State<EventInfo> {
  final EventLinkHandler eventLinkHandler = EventLinkHandler();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          _createEventDescription(context),
          _createCardBuddyImages(context),
          _createCardButton(context),
        ],
      ),
    );
  }

  String _getCardButtonText(bool alreadyParticipating) {
    if (alreadyParticipating) {
      return "Remove Participation";
    } else {
      return "Participate";
    }
  }

  Widget _createCardButton(BuildContext context) {
    var alreadyParticipating = false;

    if (widget.user.participatingEvents.contains(widget.event.id)) {
      alreadyParticipating = true;
    }

    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
      child: SizedBox(
        width: 200,
        height: 40,
        child: RaisedButton(
          child: new Text(
            _getCardButtonText(alreadyParticipating),
            style: alreadyParticipating
                ? new TextStyle(
                    color: Colors.white30,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )
                : new TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
          ),
          shape: new RoundedRectangleBorder(
            side: BorderSide(color: Colors.black12),
            borderRadius: new BorderRadius.circular(30.0),
          ),
          color: alreadyParticipating
              ? Colors.grey
              : Theme.of(context).primaryColor,
          onPressed: _getButtonFunctionality(alreadyParticipating),
        ),
      ),
    );
  }

  Function _getButtonFunctionality(bool alreadyParticipating) {
    if (alreadyParticipating) {
      return _removeParticipation;
    } else {
      return _participateInEvent;
    }
  }

  void _removeParticipation() async {
    QueryResult result;

    await eventLinkHandler
        .clientToQuery()
        .mutate(
          MutationOptions(
            document: GraphQLQueries.removeParticipatingEventMutation,
            variables: {
              'userId': widget.user.id,
              'eventId': widget.event.id,
            },
          ),
        )
        .then(
      (apiResult) {
        result = apiResult;
      },
    );

    if (result.loading) {
      print("loading...");
    }

    if (result.hasErrors) {
      var errors = result.errors.toString();
      print(errors);
    } else {
      _showSnackBar(
          widget.scaffoldContext, "We'll let them know you aren't coming 🤧");
      setState(() {
        widget.user.participatingEvents.remove(widget.event.id);
      });
    }
  }

  void _participateInEvent() async {
    QueryResult result;

    await eventLinkHandler
        .clientToQuery()
        .mutate(
          MutationOptions(
            document: GraphQLQueries.addParticipatingEventMutation,
            variables: {
              'userId': widget.user.id,
              'eventId': widget.event.id,
            },
          ),
        )
        .then(
      (apiResult) {
        result = apiResult;
      },
    );

    if (result.loading) {
      print("loading...");
    }

    if (result.hasErrors) {
      var errors = result.errors.toString();
      print(errors);
    } else {
      _showSnackBar(
          widget.scaffoldContext, "You are now participating in the event! 🤑");
      setState(() {
        widget.user.participatingEvents.add(widget.event.id);
      });
    }

    String url = widget.event.url;
    if (await canLaunch(widget.event.url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _createEventDescription(BuildContext context) {
    return Column(
      children: <Widget>[
        _createDescriptionDivider(),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Container(
            padding: widget.event.description == null ||
                    widget.event.description == ""
                ? EdgeInsets.all(30)
                : EdgeInsets.all(10),
            child: Text(
              widget.event.description == null || widget.event.description == ""
                  ? "No description available for this event 😓"
                  : widget.event.description,
              style: TextStyle(
                  fontFamily: 'Hind', fontSize: 14.0, color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createDescriptionDivider() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        children: <Widget>[
          Divider(color: Color(0xFFDDE7C7)),
          Text(
            "Description",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Divider(color: Color(0xFFDDE7C7)),
        ],
      ),
    );
  }

  Widget _createPartBuddiesDivider() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        children: <Widget>[
          Divider(color: Color(0xFFDDE7C7)),
          Text(
            "Participating Buddies",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Divider(color: Color(0xFFDDE7C7)),
        ],
      ),
    );
  }

  Widget _createCardBuddyImages(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _createPartBuddiesDivider(),
          Container(
            height: 80,
            alignment: Alignment.center,
            child: PartBuddyList(
              eventId: widget.event.id,
              partBuddies: widget.partBuddies,
              user: widget.user,
            ),
          ),
          Container(
            child: Divider(
              color: Color(0xFFDDE7C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createShareButton(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: Icon(
        Icons.share,
        color: Colors.black,
      ),
    );
  }

  String parseDate(DateTime dt) {
    if (dt != null) {
      String date = DateFormat.yMMMd().format(dt);
      return date;
    } else {
      return "To Be Announced";
    }
  }

  ImageProvider parseCardImage(Event e) {
    if (e.images == null ||
        e.images.length == 0 ||
        e.images[1].url == null ||
        e.images[1].url == "") {
      return AssetImage('assets/images/eventlink_placeholder.png');
    } else {
      return NetworkImage(e.images[1].url);
    }
  }

  String parsePriceRange() {
    var min = double.infinity, max = double.negativeInfinity;
    var priceRanges = widget.event.priceRanges;

    if (priceRanges == null || priceRanges.length == 0) {
      return "To Be Announced";
    }

    for (var priceRange in priceRanges) {
      if (priceRange.min < min) min = priceRange.min;
      if (priceRange.max > max) max = priceRange.max;
    }
    return min.toInt().toString() + "-" + max.toInt().toString();
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
