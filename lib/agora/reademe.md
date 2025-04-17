# in call_manager.dart :

# update line **162 ```'callerType': 'customer'``` and line **211 ```userType: 'customer'```

# in main.dart :

# if logged in (line 132-136) :

```
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
CallButton(
userId: order.deliveryMan!.id ?? 0,
userType: 'deliveryman',
name:
    '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}',
image:
    '${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${order.deliveryMan!.image}',
),
```