part of lib_use;

class MessageToastDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MessageToastDemoState();
  }
}

class MessageToastDemoState extends State<MessageToastDemo> {
  bool isPaintBackgroud = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Message Toast Demo"),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 72.0),
          children: <Widget>[
            RaisedButton(
              color: Colors.blue[400],
              child: Text(
                "Success",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => showMessageSuccessToast(context: context),
            ),
            RaisedButton(
              color: Colors.blue[400],
              child: Text(
                "Loading",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                var hide = showMessageLoadingToast(context: context);
                Future.delayed(Duration(seconds: 5), () {
                  hide();
                });
              },
            ),
          ].map((Widget button) {
            return Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: button);
          }).toList(),
        ));
  }
}
