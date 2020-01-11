import 'package:flutter/material.dart';

class CustomDialogBox {
  Future createDialog(
      BuildContext context, String title, String hint, Function onTap, TextEditingController controller) {
    return showCustomDialog(context, title, hint, onTap, controller);
  }

  showCustomDialog(
      BuildContext context, String title, String hint, Function onTap, TextEditingController controller) async {
    await showDialog<String>(
      context: context,
      child: Container(
        alignment: Alignment.center,
        child: new _SystemPadding(
          child: new AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    autofocus: true,
                    controller: controller,
                    decoration:
                        new InputDecoration(labelText: title, hintText: hint),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(child: const Text('Confirm'), onPressed: onTap)
            ],
          ),
        ),
      ),
    );
  }
}




class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
