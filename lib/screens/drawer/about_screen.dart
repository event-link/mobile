import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/constants.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
          "About",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Builder(
        builder: (context) => Container(
          decoration: _createGradiant(),
          child: Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                _createLogo(),
                Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                Divider(color: Color(0xFFDDE7C7)),
                _createAboutText(),
                Divider(color: Color(0xFFDDE7C7)),
                _createContactButton(context),
                _createFAQButton(),
                Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                Divider(color: Color(0xFFDDE7C7)),
                _createVersionText()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createLogo() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      alignment: Alignment.topCenter,
      child: Column(
        children: <Widget>[
          Image.asset('assets/images/eventlink.png'),
          SizedBox(
            child: Image.asset('assets/images/pin.png'),
            width: 50,
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _createAboutText() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Text(
        Constants.aboutText,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _createContactButton(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
      child: SizedBox(
        width: 250,
        height: 50,
        child: RaisedButton(
            child: new Text(
              "Support",
              style: new TextStyle(color: Colors.white, fontSize: 16),
            ),
            shape: new RoundedRectangleBorder(
                side: BorderSide(color: Colors.black12),
                borderRadius: new BorderRadius.circular(30.0)),
            color: Theme.of(context).primaryColor,
            onPressed: () => _sendMail()),
      ),
    );
  }

  _sendMail() async {
    // Android and iOS
    const uri =
        'mailto:eventlinkmail@gmail.com?subject=Support&body=';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Widget _createFAQButton() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
      child: SizedBox(
        width: 250,
        height: 50,
        child: RaisedButton(
            child: new Text(
              "FAQ",
              style: new TextStyle(color: Colors.white, fontSize: 16),
            ),
            shape: new RoundedRectangleBorder(
                side: BorderSide(color: Colors.black12),
                borderRadius: new BorderRadius.circular(30.0)),
            color: Theme.of(context).primaryColor,
            onPressed: () => {}),
      ),
    );
  }

  Widget _createVersionText() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.bottomCenter,
        child: Text(
          Constants.appName + " " + Constants.version + ". All Rights Reserved",
          style: TextStyle(color: Theme.of(context).accentColor, fontSize: 12),
        ),
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
