import 'package:EventLink/widgets/event_list.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import '../api/eventlink_handler.dart';
import '../model/eventlink/event.dart';
import '../model/eventlink/user.dart';
import '../constants/graphql_queries.dart';
import './event_info.dart';

class EventCard extends StatefulWidget {
  final User user;
  final Event event;
  final List<User> partBuddies;
  final EventListType type;
  final BuildContext scaffoldContext;

  EventCard(
      {@required this.user,
      @required this.event,
      @required this.partBuddies,
      @required this.type,
      @required this.scaffoldContext});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final EventLinkHandler eventLinkHandler = EventLinkHandler();
  final ExpandableController _controller = ExpandableController();
  bool isFavoriteEvent;

  @override
  Widget build(BuildContext context) {
    isFavoriteEvent = isEventFavorite();
    return ExpandableNotifier(
      controller: _controller,
      // <-- Provides ExpandableController to its children
      child: ScrollOnExpand(
        child: Column(
          children: [
            Expandable(
              // <-- Driven by ExpandableController from ExpandableNotifier
              collapsed: _createCard(context),
              expanded: Column(
                children: [
                  _createCard(context),
                  ExpandableButton(
                    // <-- Collapses when tapped on
                    child: EventInfo(
                      event: widget.event,
                      user: widget.user,
                      type: widget.type,
                      partBuddies: widget.partBuddies,
                      scaffoldContext: widget.scaffoldContext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createCard(BuildContext context) {
    return Container(
      height: 175,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: Border(
          top: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          left: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          right: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          bottom: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _createCardImage(),
            ),
            Expanded(
              child: _createCardContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createCardContent(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        children: <Widget>[
          _createCardHeadline(context),
          _createCardBody(context),
        ],
      ),
    );
  }

  Widget _createCardBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _createCardContentRow(
              context, "Date", parseDate(widget.event.sales.endDateTime)),
          _createCardContentRow(context, "Venue", widget.event.venues[0].name),
          _createCardContentRow(
              context,
              "Address",
              widget.event.venues[0].address.line +
                  ", " +
                  widget.event.venues[0].city.name),
          _createCardContentRow(
              context, "Country", widget.event.venues[0].country.name),
          _createCardContentRow(context, "Price", parsePriceRange()),
          _createCardButton(context),
          _createCardBuddyText(context),
        ],
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

  Widget _createCardButton(BuildContext context) {
    return ExpandableButton(
      child: Container(
        padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
        alignment: Alignment.center,
        child: SizedBox(
          width: 180,
          height: 30,
          child: Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: new BorderRadius.circular(30.0),
              border: Border.all(color: Colors.black12),
            ),
            child: new Text(
              "Learn more",
              style: new TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createCardBuddyText(BuildContext context) {
    var partBuddyAmount = widget.partBuddies.length;
    var partBuddyText = partBuddyAmount.toString() + ' Buddies Participating';

    if (partBuddyAmount == 1) {
      partBuddyText = '1 Buddy Participating';
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Text(
        '$partBuddyText',
        style: TextStyle(
          fontSize: 11.0,
          fontFamily: 'Hind',
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _createCardHeadline(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.event.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
          _createFavoriteButton(context),
        ],
      ),
    );
  }

  Widget _createFavoriteButton(BuildContext context) {
    Icon icon = Icon(
      isFavoriteEvent ? Icons.favorite : Icons.favorite_border,
      color: isFavoriteEvent ? Colors.redAccent : Colors.grey,
    );
    return Container(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => setState(
          () {
            _favoriteButtonClick();
          },
        ),
        child: icon,
      ),
    );
  }

  void _favoriteButtonClick() {
    if (isFavoriteEvent) {
      _removeFavoriteEvent();
      _removeFavoriteEventLocal();
      showSnackBar(widget.scaffoldContext, "Bye! 🤐");
    } else {
      _addFavoriteEvent();
      _addFavoriteEventLocal();
      showSnackBar(widget.scaffoldContext, "Woo yeah! 🥰");
    }
  }

  void _addFavoriteEvent() async {
    QueryResult result;

    await eventLinkHandler
        .clientToQuery()
        .mutate(
          MutationOptions(
            document: GraphQLQueries.addFavoriteEventMutation,
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
    }
  }

  void _removeFavoriteEvent() async {
    QueryResult result;

    await eventLinkHandler
        .clientToQuery()
        .mutate(
          MutationOptions(
            document: GraphQLQueries.removeFavoriteEventMutation,
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
    }
  }

  Widget _createCardImage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: parseCardImage(widget.event),
        ),
      ),
    );
  }

  ImageProvider parseCardImage(Event e) {
    if (e.images == null || e.images.length == 0) {
      return AssetImage('assets/images/eventlink_placeholder.png');
    }

    var largestImgIndex = 0;
    var largestImgWidth = 0;
    var largestImgHeight = 0;

    for (int i = 0; i < e.images.length; i++) {
      var image = e.images[i];

      if (image.url == null || image.url == '') {
        return AssetImage('assets/images/eventlink_placeholder.png');
      }

      if (image.width == null || image.height == null) {
        return AssetImage('assets/images/eventlink_placeholder.png');
      }

      if (image.width > largestImgWidth && image.height > largestImgHeight) {
        largestImgIndex = i;
        largestImgWidth = image.width;
        largestImgHeight = image.height;
      }
    }

    return NetworkImage(e.images[largestImgIndex].url);
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

  Widget _createCardContentRow(
      BuildContext context, String leadText, String text) {
    return Row(
      children: <Widget>[
        Text(
          leadText + " ",
          style: Theme.of(context).textTheme.body1,
          overflow: TextOverflow.ellipsis,
        ),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.body2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  bool isEventFavorite() {
    return widget.user.favoriteEvents.contains(widget.event.id);
  }

  void _addFavoriteEventLocal() {
    if (!widget.user.favoriteEvents.contains(widget.event.id)) {
      widget.user.favoriteEvents.add(widget.event.id);
    }
  }

  void _removeFavoriteEventLocal() {
    if (widget.user.favoriteEvents.contains(widget.event.id)) {
      widget.user.favoriteEvents.remove(widget.event.id);
    }
  }

  void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Theme.of(context).primaryColor,
    );
    Scaffold.of(context).showSnackBar(
      snackBar,
    );
  }
}
