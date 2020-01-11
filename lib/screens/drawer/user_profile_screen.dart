import 'dart:io';

import 'package:EventLink/constants/graphql_queries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../../model/eventlink/user.dart';
import '../../api/eventlink_handler.dart';
import '../../widgets/country_dropdown.dart';
import '../../widgets/customdialogbox.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;

  UserProfileScreen({@required this.user});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final EventLinkHandler eventLinkHandler = EventLinkHandler();

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordChanged = TextEditingController();
  final emailChanged = TextEditingController();

  var profilePic;

  var dropDownValue;

  void initState() {
    super.initState();
    profilePic = NetworkImage(widget.user.picUrl);
    firstNameController.text = widget.user.firstName;
    middleNameController.text = widget.user.middleName;
    lastNameController.text = widget.user.lastName;
  }

  @override
  Widget build(BuildContext context) {
    dropDownValue = widget.user.country;

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
          "User Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Builder(
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter,
          decoration: _createGradiant(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _createUserProfilePicture(context),
                _createUserInformation(),
                _createDropDownMenu(),
                _createLoginInformation(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createUserProfilePicture(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        height: MediaQuery.of(context).size.height * 0.18,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.width * 0.29,
              width: MediaQuery.of(context).size.width * 0.29,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(500)),
                border: new Border.all(
                  color: Theme.of(context).accentColor,
                  width: 3.5,
                ),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: profilePic,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.fromLTRB(85, 90, 0, 0),
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width * 0.30,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
            Container(
              child: Text(
                widget.user.fullName,
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

  void _pickImage(BuildContext context) async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);

    var imageBytes = file.readAsBytesSync();
    String base64Image = base64.encode(imageBytes);

    QueryResult result = await eventLinkHandler.clientToQuery().mutate(
          MutationOptions(
            document: GraphQLQueries.uploadProfilePictureMutation,
            variables: {
              'userId': widget.user.id,
              'imageData': base64Image,
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
      _showSnackBar(context, 'Succesfully updated profile picture! 📸');

      setState(() {
        profilePic = FileImage(file);
      });
    }
  }

  Widget _createUserInformation() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Column(
        children: <Widget>[
          Divider(color: Color(0xFFDDE7C7)),
          Text(
            "User Information",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(color: Color(0xFFDDE7C7)),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First name",
                labelStyle: TextStyle(color: Colors.white),
              ),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'First name is required';
                }
                if (value.trim().length < 2) return 'First name is invalid';
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: TextFormField(
              obscureText: false,
              controller: middleNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Middle name",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: TextFormField(
              obscureText: false,
              controller: lastNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Last name",
                labelStyle: TextStyle(color: Colors.white),
              ),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Last name is required';
                }
                if (value.trim().length < 2) return 'First name is invalid';
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDropDownMenu() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
          alignment: Alignment.centerLeft,
          child: Text(
            "Country",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: DropdownButton<String>(
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            isExpanded: true,
            underline: Container(color: Colors.black38, height: 1.0),
            hint: Text(
              dropDownValue ?? "Please select country",
              style: TextStyle(color: Colors.white),
            ),
            items: CountryDropDown()
                .countryMap
                .map(
                  (key, value) {
                    return MapEntry(
                      key,
                      DropdownMenuItem<String>(
                        value: key,
                        child: Text(key),
                      ),
                    );
                  },
                )
                .values
                .toList(),
            value: dropDownValue,
            onChanged: (newValue) {
              setState(
                () {
                  dropDownValue = newValue;
                  widget.user.country = newValue;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _createLoginInformation(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(
        children: <Widget>[
          Divider(color: Color(0xFFDDE7C7)),
          Text(
            "Login Information",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(color: Color(0xFFDDE7C7)),
          _createEmailButton(context),
          _createPasswordButton(context),
          _createOrderHistoryButton(),
          _createUpdateButton(context),
        ],
      ),
    );
  }

  Widget _createEmailButton(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
      child: SizedBox(
        width: 200,
        height: 40,
        child: RaisedButton(
            child: new Text(
              "Change Email",
              style: new TextStyle(color: Colors.white, fontSize: 14),
            ),
            shape: new RoundedRectangleBorder(
                side: BorderSide(color: Colors.black12),
                borderRadius: new BorderRadius.circular(30.0)),
            color: Theme.of(context).primaryColor,
            onPressed: () => CustomDialogBox().createDialog(
                context,
                'New E-mail',
                'Eg. new@email.com',
                () => changeEmail(context),
                emailChanged)),
      ),
    );
  }

  Widget _createPasswordButton(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
      child: SizedBox(
        width: 200,
        height: 40,
        child: RaisedButton(
          child: new Text(
            "Change Password",
            style: new TextStyle(color: Colors.white, fontSize: 14),
          ),
          shape: new RoundedRectangleBorder(
              side: BorderSide(color: Colors.black12),
              borderRadius: new BorderRadius.circular(30.0)),
          color: Theme.of(context).primaryColor,
          onPressed: () => CustomDialogBox().createDialog(
              context,
              'New Password',
              'Eg. new@password',
              () => changePassword(context),
              passwordChanged),
        ),
      ),
    );
  }

  Widget _createOrderHistoryButton() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
      child: SizedBox(
        width: 200,
        height: 40,
        child: RaisedButton(
          child: new Text(
            "Order History",
            style: new TextStyle(color: Colors.white, fontSize: 14),
          ),
          shape: new RoundedRectangleBorder(
              side: BorderSide(color: Colors.black12),
              borderRadius: new BorderRadius.circular(30.0)),
          color: Theme.of(context).primaryColor,
          onPressed: () => {} /* Switch to Order page */,
        ),
      ),
    );
  }

  Widget _createUpdateButton(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
      child: SizedBox(
        width: 200,
        height: 40,
        child: RaisedButton(
          child: new Text(
            "Save Changes",
            style: new TextStyle(color: Colors.white, fontSize: 14),
          ),
          shape: new RoundedRectangleBorder(
              side: BorderSide(color: Colors.black12),
              borderRadius: new BorderRadius.circular(30.0)),
          color: Theme.of(context).accentColor,
          onPressed: () =>
              {} /* API Updates user (Create validater that checks if anything has changed */,
        ),
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

  Future updateUser(BuildContext context) async {
    var map = widget.user.toJson();

    QueryResult result = await eventLinkHandler.clientToQuery().mutate(
          MutationOptions(
            document: GraphQLQueries.updateUserMutation,
            variables: {
              'userInput': map,
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
      _showSnackBar(context, 'Succesfully updated user! 👏');
      Navigator.of(context).pop();
    }
  }

  void changePassword(BuildContext context) async {
    if (passwordChanged.text.length > 2) {
      var bytes = utf8.encode(passwordChanged.text);
      var hashedPassword = sha512.convert(bytes);

      widget.user.hashedPassword = hashedPassword.toString().toUpperCase();

      await updateUser(context);
      Navigator.of(context).pop();
    } else {
      _showSnackBar(context, 'Password is too short! 😠');
    }
  }

  void changeEmail(BuildContext context) async {
    if (emailChanged.text.length > 2) {
      widget.user.email = emailChanged.text;

      await updateUser(context);
      Navigator.of(context).pop();
    } else {
      _showSnackBar(context, 'E-mail is not valid! 👺');
    }
  }

  void saveChanges() {
    widget.user.firstName = firstNameController.text;
    widget.user.middleName = middleNameController.text;
    widget.user.lastName = lastNameController.text;
    widget.user.country = dropDownValue;

    if (middleNameController.text.trim().isEmpty) {
      widget.user.fullName =
          firstNameController.text + " " + lastNameController.text;
    } else {
      widget.user.fullName = firstNameController.text +
          " " +
          middleNameController.text +
          " " +
          lastNameController.text;
    }

    updateUser(context);
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
