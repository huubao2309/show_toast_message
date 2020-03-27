# Show Toast Message

![Show_Toast](https://github.com/huubao2309/show_toast_message/blob/master/images/show_message.gif)

### Show Toast Success Message:

```dart
  onPressed: () {
    return showMessageSuccessToast(context: context),
  }
```

### Show Toast Loading Message:

```dart
   onPressed: () {
     var hide = showMessageLoadingToast(context: context);
     // Hide after 5s
     Future.delayed(Duration(seconds: 5), () {
         hide();
     });
    },
```
