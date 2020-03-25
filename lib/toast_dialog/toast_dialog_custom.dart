part of lib_use;

typedef HideCallback = Future Function();

class ToastMessageWidget extends StatelessWidget {
  const ToastMessageWidget({
    Key key,
    @required this.stopEvent,
    @required this.alignment,
    @required this.icon,
    @required this.message,
  }) : super(key: key);

  final bool stopEvent;
  final Alignment alignment;
  final Widget icon;
  final Widget message;

  @override
  Widget build(BuildContext context) {
    var widget = Material(
      color: Colors.transparent,
      child: Align(
        alignment: this.alignment,
        child: IntrinsicHeight(
          child: Container(
            width: 122.0,
            decoration: BoxDecoration(
                color: Color.fromRGBO(17, 17, 17, 0.7),
                borderRadius: BorderRadius.circular(5.0)),
            constraints: BoxConstraints(
              minHeight: 122.0,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 22.0),
                  constraints: BoxConstraints(minHeight: 55.0),
                  child: IconTheme(
                      data: IconThemeData(color: Colors.white, size: 55.0),
                      child: icon),
                ),
                DefaultTextStyle(
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                  child: message,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return IgnorePointer(
      ignoring: !stopEvent,
      child: widget,
    );
  }
}

class MessageLoadingIcon extends StatefulWidget {
  final double size;

  MessageLoadingIcon({this.size = 50.0});

  @override
  State<StatefulWidget> createState() => MessageLoadingIconState();
}

class MessageLoadingIconState extends State<MessageLoadingIcon>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _doubleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000))
      ..repeat();
    _doubleAnimation = Tween(begin: 0.0, end: 360.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _doubleAnimation.value ~/ 30 * 30.0 * 0.0174533,
      child: Image.asset("images/loading.png",
          width: widget.size, height: widget.size),
    );
  }
}

@immutable
class MessageToastConfigData {
  final String successText;
  final Duration successDuration;
  final bool successBackButtonClose;
  final String loadingText;
  final bool loadingBackButtonClose;
  final Alignment toastAlignment;

  const MessageToastConfigData(
      {this.successText = 'Success',
      this.successDuration = const Duration(seconds: 3),
      this.successBackButtonClose = true,
      this.loadingText = 'Loading',
      this.loadingBackButtonClose = false,
      this.toastAlignment = const Alignment(0.0, -0.2)});

  copyWith(
      {String successText,
      Duration successDuration,
      String loadingText,
      Alignment toastAlignment}) {
    return MessageToastConfigData(
        successText: successText ?? this.successText,
        successDuration: successDuration ?? this.successDuration,
        loadingText: loadingText ?? this.loadingText,
        toastAlignment: toastAlignment ?? this.toastAlignment);
  }
}

class MessageToastConfig extends InheritedWidget {
  final MessageToastConfigData data;
  MessageToastConfig({Widget child, this.data}) : super(child: child);

  @override
  bool updateShouldNotify(MessageToastConfig oldWidget) {
    return data != oldWidget.data;
  }

  static MessageToastConfigData of(BuildContext context) {
    var widget = context.inheritFromWidgetOfExactType(MessageToastConfig);
    if (widget is MessageToastConfig) {
      return widget.data;
    }
    return MessageToastConfigData();
  }
}

Future showMessageSuccessToast(
    {@required BuildContext context,
    Widget message,
    stopEvent = false,
    bool backButtonClose,
    Alignment alignment,
    Duration closeDuration}) {
  var config = MessageToastConfig.of(context);
  message = message ?? Text(config.successText);
  closeDuration = closeDuration ?? config.successDuration;
  backButtonClose = backButtonClose ?? config.successBackButtonClose;
  var hide = showMessageToast(
      context: context,
      alignment: alignment,
      message: message,
      stopEvent: stopEvent,
      backButtonClose: backButtonClose,
      icon: Icon(Icons.done));

  return Future.delayed(closeDuration, () {
    hide();
  });
}

HideCallback showMessageLoadingToast(
    {@required BuildContext context,
    Widget message,
    stopEvent = true,
    bool backButtonClose,
    Alignment alignment}) {
  var config = MessageToastConfig.of(context);
  message = message ?? Text(config.loadingText);
  backButtonClose = backButtonClose ?? config.loadingBackButtonClose;

  return showMessageToast(
      context: context,
      alignment: alignment,
      message: message,
      stopEvent: stopEvent,
      icon: MessageLoadingIcon(),
      backButtonClose: backButtonClose);
}

int backButtonIndex = 2;

HideCallback showMessageToast(
    {@required BuildContext context,
    @required Widget message,
    @required Widget icon,
    bool stopEvent = false,
    Alignment alignment,
    bool backButtonClose}) {
  var config = MessageToastConfig.of(context);
  alignment = alignment ?? config.toastAlignment;

  Completer<VoidCallback> result = Completer<VoidCallback>();
  // var backButtonName = 'CoolUI_WeuiToast$backButtonIndex';
  var backButtonName = 'Show_MessageToast $backButtonIndex';
  BackButtonInterceptor.add((stopDefaultButtonEvent) {
    print(backButtonClose);
    if (backButtonClose) {
      result.future.then((hide) {
        hide();
      });
    }
    return true;
  }, zIndex: backButtonIndex, name: backButtonName);
  backButtonIndex++;

  var overlay = OverlayEntry(
      maintainState: true,
      builder: (_) => WillPopScope(
            onWillPop: () async {
              var hide = await result.future;
              hide();
              return false;
            },
            child: ToastMessageWidget(
              alignment: alignment,
              icon: icon,
              message: message,
              stopEvent: stopEvent,
            ),
          ));
  result.complete(() {
    if (overlay == null) {
      return;
    }
    overlay.remove();
    overlay = null;
    BackButtonInterceptor.removeByName(backButtonName);
  });
  Overlay.of(context).insert(overlay);

  return () async {
    var hide = await result.future;
    hide();
  };
}
