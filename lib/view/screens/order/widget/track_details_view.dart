import 'package:dokandar/agora/call_widgets.dart';
import 'package:dokandar/controller/splash_controller.dart';
import 'package:dokandar/data/model/response/order_model.dart';
import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/util/images.dart';
import 'package:dokandar/util/styles.dart';
import 'package:dokandar/view/base/custom_divider.dart';
import 'package:dokandar/view/base/custom_image.dart';
import 'package:dokandar/view/base/custom_snackbar.dart';
import 'package:dokandar/view/base/rating_bar.dart';
import 'package:dokandar/view/screens/order/widget/address_details.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TrackDetailsView extends StatelessWidget {
  final String? status;
  final OrderModel track;
  final Function? callback;

  const TrackDetailsView(
      {Key? key, required this.track, required this.status, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double distance = 0;
    bool takeAway = track.orderType == 'send_gift';
    if (track.deliveryMan != null) {
      distance = Geolocator.distanceBetween(
            double.parse(track.deliveryAddress!.latitude!),
            double.parse(track.deliveryAddress!.longitude!),
            double.parse(track.deliveryMan!.lat ?? '0'),
            double.parse(track.deliveryMan!.lng ?? '0'),
          ) /
          1000;
    }

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
      ),
      alignment: Alignment.center,
      child: (track.deliveryMan == null)
          ? Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Text(
                'delivery_man_not_assigned'.tr,
                style: robotoMedium,
                textAlign: TextAlign.center,
              ),
            )
          : Column(children: [
              Text('trip_route'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Row(children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      takeAway
                          ? track.deliveryAddress!.address!
                          : track.deliveryMan!.location!,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                SizedBox(
                    width: 80,
                    child: CustomDivider(
                        color: Theme.of(context).primaryColor, height: 2)),
                Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  flex: 5,
                  child: (takeAway && track.orderType != 'parcel')
                      ? Text(
                          track.store != null ? track.store!.address! : '',
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : (track.orderType == 'parcel' && status == 'picked_up')
                          ? AddressDetails(
                              addressDetails: track.receiverDetails)
                          : AddressDetails(
                              addressDetails: track.deliveryAddress),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              takeAway
                  ? InkWell(
                      onTap: () async {
                        String url =
                            'https://www.google.com/maps/dir/?api=1&destination=${track.store != null ? track.store!.latitude : ''}'
                            ',${track.store != null ? track.store!.longitude : ''}&mode=d';
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          showCustomSnackBar('unable_to_launch_google_map'.tr);
                        }
                      },
                      child: Column(children: [
                        Icon(Icons.directions,
                            size: 25, color: Theme.of(context).primaryColor),
                        Text(
                          'direction'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ]),
                    )
                  : Column(children: [
                      Image.asset(Images.route,
                          height: 20,
                          width: 20,
                          color: Theme.of(context).primaryColor),
                      Text(
                        '${distance.toStringAsFixed(2)} ${'km'.tr}',
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ]),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    takeAway
                        ? Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .showRestaurantText!
                            ? 'store'.tr
                            : 'store'.tr
                        : 'delivery_man'.tr,
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall),
                  )),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(children: [
                ClipOval(
                    child: CustomImage(
                  image:
                      '${takeAway ? Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl : Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${takeAway ? track.store != null ? track.store!.logo : '' : track.deliveryMan!.image}',
                  height: 35,
                  width: 35,
                  fit: BoxFit.cover,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        takeAway
                            ? track.store != null
                                ? track.store!.name!
                                : ''
                            : '${track.deliveryMan!.fName} ${track.deliveryMan!.lName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall),
                      ),
                      RatingBar(
                        rating: takeAway
                            ? track.store != null
                                ? track.store!.avgRating
                                : '' as double?
                            : track.deliveryMan!.avgRating,
                        size: 10,
                        ratingCount: takeAway
                            ? track.store != null
                                ? track.store!.ratingCount
                                : '' as int?
                            : track.deliveryMan!.ratingCount,
                      ),
                    ])),
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
                const SizedBox(width: Dimensions.paddingSizeSmall),
                InkWell(
                  onTap: () async {
                    if (await canLaunchUrlString(
                        'tel:${takeAway ? track.store != null ? track.store!.phone : '' : track.deliveryMan!.phone}')) {
                      launchUrlString(
                          'tel:${takeAway ? track.store != null ? track.store!.phone : '' : track.deliveryMan!.phone}',
                          mode: LaunchMode.externalApplication);
                    } else {
                      showCustomSnackBar(
                          '${'can_not_launch'.tr} ${takeAway ? track.store != null ? track.store!.phone : '' : track.deliveryMan!.phone}');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall,
                        horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      color: Colors.green,
                    ),
                    child: Text(
                      'call'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).cardColor),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                InkWell(
                  onTap: callback as void Function()?,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: Get.context!.width >= 1300
                            ? 7
                            : Dimensions.paddingSizeExtraSmall,
                        horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      color: Colors.green,
                    ),
                    child: Icon(Icons.chat,
                        size: 12, color: Theme.of(context).cardColor),
                  ),
                ),
              ]),
            ]),
    );
  }
}
