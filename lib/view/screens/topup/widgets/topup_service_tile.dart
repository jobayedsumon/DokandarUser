import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/util/styles.dart';
import 'package:flutter/material.dart';

class TopupServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool hideDivider;

  const TopupServiceTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.hideDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: Row(children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeExtraSmall),
                        child: Text(
                          subtitle!,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).disabledColor,
              ),
            ]),
          ),
          if (!hideDivider)
            Divider(
              height: 1,
              color: Theme.of(context).disabledColor.withOpacity(0.3),
            ),
        ],
      ),
    );
  }
}
