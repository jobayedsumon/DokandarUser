import 'package:dokandar/controller/cart_controller.dart';
import 'package:dokandar/controller/splash_controller.dart';
import 'package:dokandar/data/api/api_checker.dart';
import 'package:dokandar/data/model/body/place_order_body.dart';
import 'package:dokandar/data/model/body/review_body.dart';
import 'package:dokandar/data/model/response/basic_medicine_model.dart';
import 'package:dokandar/data/model/response/cart_model.dart';
import 'package:dokandar/data/model/response/common_condition_model.dart';
import 'package:dokandar/data/model/response/item_model.dart';
import 'package:dokandar/data/model/response/order_details_model.dart';
import 'package:dokandar/data/model/response/response_model.dart';
import 'package:dokandar/data/repository/item_repo.dart';
import 'package:dokandar/helper/date_converter.dart';
import 'package:dokandar/helper/price_converter.dart';
import 'package:dokandar/helper/responsive_helper.dart';
import 'package:dokandar/helper/route_helper.dart';
import 'package:dokandar/util/app_constants.dart';
import 'package:dokandar/util/images.dart';
import 'package:dokandar/view/base/cart_snackbar.dart';
import 'package:dokandar/view/base/confirmation_dialog.dart';
import 'package:dokandar/view/base/custom_snackbar.dart';
import 'package:dokandar/view/base/item_bottom_sheet.dart';
import 'package:dokandar/view/screens/item/item_details_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemController extends GetxController implements GetxService {
  final ItemRepo itemRepo;

  ItemController({required this.itemRepo});

  // Latest products
  List<Item>? _popularItemList;
  List<Item>? _reviewedItemList;
  List<Item>? _recommendedItemList;
  List<Item>? _discountedItemList;
  List<Categories>? _reviewedCategoriesList;
  bool _isLoading = false;
  List<int>? _variationIndex;
  List<List<bool?>> _selectedVariations = [];
  int? _quantity = 1;
  List<bool> _addOnActiveList = [];
  List<int?> _addOnQtyList = [];
  String _popularType = 'all';
  String _reviewedType = 'all';
  static final List<String> _itemTypeList = ['all', 'veg', 'non_veg'];
  int _imageIndex = 0;
  int _cartIndex = -1;
  Item? _item;
  int _productSelect = 0;
  int _imageSliderIndex = 0;
  List<bool> _collapsVariation = [];
  int _currentIndex = 0;
  bool _isReadMore = false;
  BasicMedicineModel? _basicMedicineModel;
  List<CommonConditionModel>? _commonConditions;
  int _selectedCommonCondition = 0;
  List<Item>? _conditionWiseProduct;
  ItemModel? _featuredCategoriesItem;
  int _selectedCategory = 0;

  List<Item>? get popularItemList => _popularItemList;

  List<Item>? get reviewedItemList => _reviewedItemList;

  List<Item>? get recommendedItemList => _recommendedItemList;

  List<Item>? get discountedItemList => _discountedItemList;

  List<Categories>? get reviewedCategoriesList => _reviewedCategoriesList;

  bool get isLoading => _isLoading;

  List<int>? get variationIndex => _variationIndex;

  List<List<bool?>> get selectedVariations => _selectedVariations;

  int? get quantity => _quantity;

  List<bool> get addOnActiveList => _addOnActiveList;

  List<int?> get addOnQtyList => _addOnQtyList;

  String get popularType => _popularType;

  String get reviewType => _reviewedType;

  List<String> get itemTypeList => _itemTypeList;

  int get imageIndex => _imageIndex;

  int get cartIndex => _cartIndex;

  Item? get item => _item;

  int get productSelect => _productSelect;

  int get imageSliderIndex => _imageSliderIndex;

  List<bool> get collapsVariation => _collapsVariation;

  int get currentIndex => _currentIndex;

  bool get isReadMore => _isReadMore;

  BasicMedicineModel? get basicMedicineModel => _basicMedicineModel;

  List<CommonConditionModel>? get commonConditions => _commonConditions;

  int get selectedCommonCondition => _selectedCommonCondition;

  List<Item>? get conditionWiseProduct => _conditionWiseProduct;

  ItemModel? get featuredCategoriesItem => _featuredCategoriesItem;

  int get selectedCategory => _selectedCategory;

  void selectCategory(int index) {
    _selectedCategory = index;
    update();
  }

  void selectCommonCondition(int index) {
    _selectedCommonCondition = index;
    getConditionsWiseItem(_commonConditions![index].id!, true);
    update();
  }

  void changeReadMore() {
    _isReadMore = !_isReadMore;
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  Future<void> getPopularItemList(bool reload, String type, bool notify) async {
    _popularType = type;
    if (reload) {
      _popularItemList = null;
    }
    if (notify) {
      update();
    }
    if (_popularItemList == null || reload) {
      Response response = await itemRepo.getPopularItemList(type);
      if (response.statusCode == 200) {
        _popularItemList = [];
        _popularItemList!.addAll(ItemModel.fromJson(response.body).items!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getReviewedItemList(
      bool reload, String type, bool notify) async {
    _reviewedType = type;
    if (reload) {
      _reviewedItemList = null;
    }
    if (notify) {
      update();
    }
    if (_reviewedItemList == null || reload) {
      Response response = await itemRepo.getReviewedItemList(type);
      if (response.statusCode == 200) {
        _reviewedItemList = [];
        _reviewedCategoriesList = [];
        _reviewedItemList!.addAll(ItemModel.fromJson(response.body).items!);
        _reviewedCategoriesList!
            .addAll(ItemModel.fromJson(response.body).categories!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getFeaturedCategoriesItemList(bool reload, bool notify) async {
    if (reload) {
      _featuredCategoriesItem = null;
    }
    if (notify) {
      update();
    }
    if (_featuredCategoriesItem == null || reload) {
      Response response = await itemRepo.getFeaturedCategoriesItemList();
      if (response.statusCode == 200) {
        _featuredCategoriesItem = ItemModel.fromJson(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getRecommendedItemList(
      bool reload, String type, bool notify) async {
    if (reload) {
      _recommendedItemList = null;
    }
    if (notify) {
      update();
    }
    if (_recommendedItemList == null || reload) {
      Response response = await itemRepo.getRecommendedItemList(type);
      if (response.statusCode == 200) {
        _recommendedItemList = [];
        _recommendedItemList!.addAll(ItemModel.fromJson(response.body).items!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getBasicMedicine(bool reload, bool notify) async {
    if (reload) {
      _basicMedicineModel = null;
    }
    if (notify) {
      update();
    }
    if (_basicMedicineModel == null || reload) {
      Response response = await itemRepo.getBasicMedicine();
      if (response.statusCode == 200) {
        _basicMedicineModel = BasicMedicineModel.fromJson(response.body);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getConditionsWiseItem(int id, bool notify) async {
    _conditionWiseProduct = null;
    if (notify) {
      update();
    }
    Response response = await itemRepo.getConditionsWiseItem(id);
    if (response.statusCode == 200) {
      _conditionWiseProduct = [];
      _conditionWiseProduct!.addAll(ItemModel.fromJson(response.body).items!);
      _isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getCommonConditions(bool notify) async {
    _commonConditions = [];
    if (notify) {
      update();
    }
    Response response = await itemRepo.getCommonConditions();
    if (response.statusCode == 200) {
      response.body.forEach((condition) =>
          _commonConditions!.add(CommonConditionModel.fromJson(condition)));
      _isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getDiscountedItemList(bool reload, bool notify) async {
    if (reload) {
      _discountedItemList = null;
    }
    if (notify) {
      update();
    }
    if (_discountedItemList == null || reload) {
      Response response = await itemRepo.getDiscountedItemList();
      if (response.statusCode == 200) {
        _discountedItemList = [];
        _discountedItemList!.addAll(ItemModel.fromJson(response.body).items!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void initData(Item? item, CartModel? cart) {
    _variationIndex = [];
    _addOnQtyList = [];
    _addOnActiveList = [];
    _selectedVariations = [];
    _collapsVariation = [];
    if (cart != null) {
      _quantity = cart.quantity;
      List<int?> addOnIdList = [];
      for (var addOnId in cart.addOnIds!) {
        addOnIdList.add(addOnId.id);
      }
      for (var addOn in item!.addOns!) {
        if (addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList
              .add(cart.addOnIds![addOnIdList.indexOf(addOn.id)].quantity);
        } else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      }

      if (Get.find<SplashController>()
          .getModuleConfig(item.moduleType)
          .newVariation!) {
        _selectedVariations.addAll(cart.foodVariations!);
        for (int index = 0; index < item.foodVariations!.length; index++) {
          _collapsVariation.add(true);
        }
      } else {
        List<String> variationTypes = [];
        if (cart.variation!.isNotEmpty && cart.variation![0].type != null) {
          variationTypes.addAll(cart.variation![0].type!.split('-'));
        }
        int varIndex = 0;
        for (var choiceOption in item.choiceOptions!) {
          for (int index = 0; index < choiceOption.options!.length; index++) {
            if (choiceOption.options![index].trim().replaceAll(' ', '') ==
                variationTypes[varIndex].trim()) {
              _variationIndex!.add(index);
              break;
            }
          }
          varIndex++;
        }
      }
    } else {
      if (Get.find<SplashController>()
          .getModuleConfig(item!.moduleType)
          .newVariation!) {
        for (int index = 0; index < item.foodVariations!.length; index++) {
          _selectedVariations.add([]);
          _collapsVariation.add(true);
          for (int i = 0;
              i < item.foodVariations![index].variationValues!.length;
              i++) {
            _selectedVariations[index].add(false);
          }
        }
      } else {
        for (var element in item.choiceOptions!) {
          _variationIndex!.add(0);
          if (kDebugMode) {
            // print(element);
          }
        }
      }
      _quantity = 1;
      for (var addOn in item.addOns!) {
        _addOnActiveList.add(false);
        _addOnQtyList.add(1);
        if (kDebugMode) {
          // print(addOn);
        }
      }
      setExistInCart(item, notify: false);
    }
  }

  void cartIndexSet() {
    _cartIndex = -1;
  }

  int setExistInCart(Item? item, {bool notify = false}) {
    String variationType = '';
    if (!Get.find<SplashController>()
        .getModuleConfig(Get.find<SplashController>().module != null
            ? Get.find<SplashController>().module!.moduleType
            : Get.find<SplashController>().cacheModule!.moduleType)
        .newVariation!) {
      List<String> variationList = [];
      for (int index = 0; index < item!.choiceOptions!.length; index++) {
        variationList.add(item
            .choiceOptions![index].options![_variationIndex![index]]
            .replaceAll(' ', ''));
      }
      bool isFirst = true;
      for (var variation in variationList) {
        if (isFirst) {
          variationType = '$variationType$variation';
          isFirst = false;
        } else {
          variationType = '$variationType-$variation';
        }
      }
    }
    if (Get.find<SplashController>()
        .getModuleConfig(Get.find<SplashController>().module != null
            ? Get.find<SplashController>().module!.moduleType
            : Get.find<SplashController>().cacheModule!.moduleType)
        .newVariation!) {
      _cartIndex = -1;
    } else {
      _cartIndex = Get.find<CartController>()
          .isExistInCart(item!.id, variationType, false, null);
    }
    if (_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartList[_cartIndex].quantity;
      _addOnActiveList = [];
      _addOnQtyList = [];
      List<int?> addOnIdList = [];
      for (var addOnId
          in Get.find<CartController>().cartList[_cartIndex].addOnIds!) {
        addOnIdList.add(addOnId.id);
      }
      for (var addOn in item!.addOns!) {
        if (addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList.add(Get.find<CartController>()
              .cartList[_cartIndex]
              .addOnIds![addOnIdList.indexOf(addOn.id)]
              .quantity);
        } else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      }
    }
    if (notify) {
      update();
    }
    return _cartIndex;
  }

  void setAddOnQuantity(bool isIncrement, int index) {
    if (isIncrement) {
      _addOnQtyList[index] = _addOnQtyList[index]! + 1;
    } else {
      _addOnQtyList[index] = _addOnQtyList[index]! - 1;
    }
    update();
  }

  void setQuantity(bool isIncrement, int? stock, int? quantityLimit,
      {bool getxSnackBar = false}) {
    if (isIncrement) {
      if (Get.find<SplashController>()
              .configModel!
              .moduleConfig!
              .module!
              .stock! &&
          _quantity! >= stock!) {
        showCustomSnackBar('out_of_stock'.tr);
      } else {
        if (quantityLimit != null) {
          if (_quantity! >= quantityLimit && quantityLimit != 0) {
            showCustomSnackBar('${'maximum_quantity_limit'.tr} $quantityLimit',
                getXSnackBar: getxSnackBar);
          } else {
            _quantity = _quantity! + 1;
          }
        } else {
          _quantity = _quantity! + 1;
        }
      }
    } else {
      _quantity = _quantity! - 1;
    }
    update();
  }

  void setCartVariationIndex(int index, int i, Item? item) {
    _variationIndex![index] = i;
    _quantity = 1;
    setExistInCart(item);
    update();
  }

  void showMoreSpecificSection(int index) {
    _collapsVariation[index] = !_collapsVariation[index];
    update();
  }

  void setNewCartVariationIndex(int index, int i, Item item) {
    if (!item.foodVariations![index].multiSelect!) {
      for (int j = 0; j < _selectedVariations[index].length; j++) {
        if (item.foodVariations![index].required!) {
          _selectedVariations[index][j] = j == i;
        } else {
          if (_selectedVariations[index][j]!) {
            _selectedVariations[index][j] = false;
          } else {
            _selectedVariations[index][j] = j == i;
          }
        }
      }
    } else {
      if (!_selectedVariations[index][i]! &&
          selectedVariationLength(_selectedVariations, index) >=
              item.foodVariations![index].max!) {
        showCustomSnackBar(
          '${'maximum_variation_for'.tr} ${item.foodVariations![index].name} ${'is'.tr} ${item.foodVariations![index].max}',
          getXSnackBar: true,
        );
      } else {
        _selectedVariations[index][i] = !_selectedVariations[index][i]!;
      }
    }
    update();
  }

  int selectedVariationLength(List<List<bool?>> selectedVariations, int index) {
    int length = 0;
    for (bool? isSelected in selectedVariations[index]) {
      if (isSelected!) {
        length++;
      }
    }
    return length;
  }

  void addAddOn(bool isAdd, int index) {
    _addOnActiveList[index] = isAdd;
    update();
  }

  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  int _deliveryManRating = 0;

  List<int> get ratingList => _ratingList;

  List<String> get reviewList => _reviewList;

  List<bool> get loadingList => _loadingList;

  List<bool> get submitList => _submitList;

  int get deliveryManRating => _deliveryManRating;

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    for (var orderDetails in orderDetailsList) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
      if (kDebugMode) {
        // print(orderDetails);
      }
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    update();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    update();
  }

  Future<ResponseModel> submitReview(int index, ReviewBody reviewBody) async {
    _loadingList[index] = true;
    update();

    Response response = await itemRepo.submitReview(reviewBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      update();
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _loadingList[index] = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBody reviewBody) async {
    _isLoading = true;
    update();
    Response response = await itemRepo.submitDeliveryManReview(reviewBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _deliveryManRating = 0;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      update();
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  void setImageIndex(int index, bool notify) {
    _imageIndex = index;
    if (notify) {
      update();
    }
  }

  Future<void> getProductDetails(Item item) async {
    _item = null;
    if (item.name != null) {
      _item = item;
    } else {
      _item = null;
      Response response = await itemRepo.getItemDetails(item.id);
      if (response.statusCode == 200) {
        _item = Item.fromJson(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
    }
    initData(_item, null);
    setExistInCart(_item, notify: !ResponsiveHelper.isDesktop(Get.context));
  }

  void setSelect(int select, bool notify) {
    _productSelect = select;
    if (notify) {
      update();
    }
  }

  void setImageSliderIndex(int index) {
    _imageSliderIndex = index;
    update();
  }

  double? getStartingPrice(Item item) {
    double? startingPrice = 0;
    if (item.choiceOptions != null && item.choiceOptions!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in item.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
    } else {
      startingPrice = item.price;
    }
    return startingPrice;
  }

  bool isAvailable(Item item) {
    return DateConverter.isAvailable(
        item.availableTimeStarts, item.availableTimeEnds);
  }

  double? getDiscount(Item item) =>
      item.storeDiscount == 0 ? item.discount : item.storeDiscount;

  String? getDiscountType(Item item) =>
      item.storeDiscount == 0 ? item.discountType : 'percent';

  void navigateToItemPage(Item? item, BuildContext context,
      {bool inStore = false, bool isCampaign = false}) {
    if (Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .showRestaurantText! ||
        item!.moduleType == 'food') {
      ResponsiveHelper.isMobile(context)
          ? Get.bottomSheet(
              ItemBottomSheet(
                  item: item, inStorePage: inStore, isCampaign: isCampaign),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            )
          : Get.dialog(
              Dialog(
                  child: ItemBottomSheet(
                      item: item,
                      inStorePage: inStore,
                      isCampaign: isCampaign)),
            );
    } else {
      Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, inStore),
          arguments: ItemDetailsScreen(item: item, inStorePage: inStore));
    }
  }

  void itemDirectlyAddToCart(Item? item, BuildContext context,
      {bool inStore = false, bool isCampaign = false}) {
    print(
        '------check : (${(item!.foodVariations != null && item.foodVariations!.isEmpty)} && ${item.moduleType == AppConstants.food}) || (${(item.variations != null && item.variations!.isEmpty)} && ${item.moduleType != AppConstants.food})');
    // print('------check item : ${item.toJson()}');
    if (((item.foodVariations != null && item.foodVariations!.isEmpty) &&
            item.moduleType == AppConstants.food) ||
        (item.variations != null &&
            item.variations!.isEmpty &&
            item.moduleType != AppConstants.food)) {
      double price = item.price!;
      double discount = item.discount!;
      double discountPrice = PriceConverter.convertWithDiscount(
          price, discount, item.discountType)!;

      CartModel cartModel = CartModel(
        null,
        price,
        discount,
        [],
        [],
        (price - discountPrice),
        1,
        [],
        [],
        isCampaign,
        item.stock,
        item,
        item.quantityLimit,
      );

      OnlineCart onlineCart = OnlineCart(
        null,
        isCampaign ? null : item.id,
        isCampaign ? item.id : null,
        price.toString(),
        '',
        null,
        Get.find<SplashController>()
                .getModuleConfig(item.moduleType)
                .newVariation!
            ? []
            : null,
        1,
        [],
        [],
        [],
        'Item',
      );
      if (Get.find<SplashController>()
              .configModel!
              .moduleConfig!
              .module!
              .stock! &&
          item.stock! <= 0) {
        showCustomSnackBar('out_of_stock'.tr);
      } else if (Get.find<CartController>().existAnotherStoreItem(
          cartModel.item!.storeId,
          Get.find<SplashController>().module != null
              ? Get.find<SplashController>().module!.id
              : Get.find<SplashController>().cacheModule!.id)) {
        Get.dialog(
            ConfirmationDialog(
              icon: Images.warning,
              title: 'are_you_sure_to_reset'.tr,
              description: Get.find<SplashController>()
                      .configModel!
                      .moduleConfig!
                      .module!
                      .showRestaurantText!
                  ? 'if_you_continue'.tr
                  : 'if_you_continue_without_another_store'.tr,
              onYesPressed: () {
                Get.find<CartController>()
                    .clearCartOnline()
                    .then((success) async {
                  if (success) {
                    await Get.find<CartController>()
                        .addToCartOnline(onlineCart);
                    Get.back();
                    showCartSnackBar();
                  }
                });
              },
            ),
            barrierDismissible: false);
      } else {
        Get.find<CartController>().addToCartOnline(onlineCart);
        showCartSnackBar();
      }
    } else if (Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .showRestaurantText! ||
        item.moduleType == AppConstants.food) {
      ResponsiveHelper.isMobile(context)
          ? Get.bottomSheet(
              ItemBottomSheet(
                  item: item, inStorePage: inStore, isCampaign: isCampaign),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            )
          : Get.dialog(
              Dialog(
                  child: ItemBottomSheet(
                      item: item,
                      inStorePage: inStore,
                      isCampaign: isCampaign)),
            );
    } else {
      Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, inStore),
          arguments: ItemDetailsScreen(item: item, inStorePage: inStore));
    }
  }
}
