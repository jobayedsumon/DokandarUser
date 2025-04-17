# FLUTTER VERSION: 3.16.0

# JAVA VERSION: 17

# Copy lib/agora folder

# in pubspec.yaml :

```
dependencies:
  agora_rtc_engine: ^6.5.1
  permission_handler: ^11.3.1
  agora_token_service: ^0.1.2
```

# in call_manager.dart :

# update line **162 ```'callerType': 'customer'``` and line **211 ```userType: 'customer'```

# in main.dart :

# if logged in (line 132-136) :

```
import 'agora/call_manager.dart';

// Initialize CallManager
UserController userController = Get.find<UserController>();
await userController.getUserInfo();
Get.put(CallManager(userController.userInfoModel!), permanent: true);
Get.find<CallManager>();
```

# in notification_helper.dart :

# on FirebaseMessaging.onMessage.listen (line 107 - 108) :

```
else if (message.data['type'] != 'incoming_call' && message.data['type'] != 'call_ended') {}
```

# in order_info_widget.dart :

# update userType accordingly (customer, deliveryman, vendor)

# for running order, before chat button (line 806 - 813) :

```
import 'package:dokandar/agora/call_widgets.dart';

CallButton(
userId: order.deliveryMan!.id ?? 0,
userType: 'deliveryman',
name:
    '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}',
image:
    '${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${order.deliveryMan!.image}',
),
```

# in track_details_view..dart :

# update userType accordingly (customer, deliveryman, vendor)

# for running order, before call button (line 194 - 206) :

```
import 'package:dokandar/agora/call_widgets.dart';

CallButton(
  userId: takeAway
      ? (track.store != null ? (track.store!.id ?? 0) : 0)
      : (track.deliveryMan!.id ?? 0),
  userType: takeAway ? 'vendor' : 'deliveryman',
  name: takeAway
      ? track.store != null
          ? track.store!.name!
          : ''
      : '${track.deliveryMan!.fName} ${track.deliveryMan!.lName}',
  image:
      '${takeAway ? Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl : Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${takeAway ? track.store != null ? track.store!.logo : '' : track.deliveryMan!.image}',
),
```