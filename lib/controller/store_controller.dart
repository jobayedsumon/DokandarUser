import 'package:dokandar/controller/category_controller.dart';
import 'package:dokandar/controller/coupon_controller.dart';
import 'package:dokandar/controller/location_controller.dart';
import 'package:dokandar/controller/order_controller.dart';
import 'package:dokandar/data/api/api_checker.dart';
import 'package:dokandar/data/model/response/cart_suggested_item_model.dart';
import 'package:dokandar/data/model/response/category_model.dart';
import 'package:dokandar/data/model/response/item_model.dart';
import 'package:dokandar/data/model/response/recommended_product_model.dart';
import 'package:dokandar/data/model/response/review_model.dart';
import 'package:dokandar/data/model/response/store_banner_model.dart';
import 'package:dokandar/data/model/response/store_model.dart';
import 'package:dokandar/data/model/response/zone_response_model.dart';
import 'package:dokandar/data/repository/store_repo.dart';
import 'package:dokandar/helper/date_converter.dart';
import 'package:dokandar/view/base/custom_snackbar.dart';
import 'package:dokandar/view/screens/home/home_screen.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StoreController extends GetxController implements GetxService {
  final StoreRepo storeRepo;

  StoreController({required this.storeRepo});

  StoreModel? _storeModel;
  List<Store>? _popularStoreList;
  List<Store>? _latestStoreList;
  List<Store>? _featuredStoreList;
  List<Store>? _visitAgainStoreList;
  Store? _store;
  ItemModel? _storeItemModel;
  ItemModel? _storeSearchItemModel;
  int _categoryIndex = 0;
  List<CategoryModel>? _categoryList;
  bool _isLoading = false;
  String _storeType = 'all';
  List<ReviewModel>? _storeReviewList;
  String _type = 'all';
  String _searchType = 'all';
  String _searchText = '';
  bool _currentState = true;
  bool _showFavButton = true;
  List<XFile> _pickedPrescriptions = [];
  RecommendedItemModel? _recommendedItemModel;
  CartSuggestItemModel? _cartSuggestItemModel;
  bool _isSearching = false;
  List<StoreBannerModel>? _storeBanners;
  List<Store>? _recommendedStoreList;

  StoreModel? get storeModel => _storeModel;

  List<Store>? get popularStoreList => _popularStoreList;

  List<Store>? get latestStoreList => _latestStoreList;

  List<Store>? get featuredStoreList => _featuredStoreList;

  List<Store>? get visitAgainStoreList => _visitAgainStoreList;

  Store? get store => _store;

  ItemModel? get storeItemModel => _storeItemModel;

  ItemModel? get storeSearchItemModel => _storeSearchItemModel;

  int get categoryIndex => _categoryIndex;

  List<CategoryModel>? get categoryList => _categoryList;

  bool get isLoading => _isLoading;

  String get storeType => _storeType;

  List<ReviewModel>? get storeReviewList => _storeReviewList;

  String get type => _type;

  String get searchType => _searchType;

  String get searchText => _searchText;

  bool get currentState => _currentState;

  bool get showFavButton => _showFavButton;

  List<XFile> get pickedPrescriptions => _pickedPrescriptions;

  RecommendedItemModel? get recommendedItemModel => _recommendedItemModel;

  CartSuggestItemModel? get cartSuggestItemModel => _cartSuggestItemModel;

  bool get isSearching => _isSearching;

  List<StoreBannerModel>? get storeBanners => _storeBanners;

  List<Store>? get recommendedStoreList => _recommendedStoreList;

  String filteringUrl(String slug) {
    List<String> routes = Get.currentRoute.split('?');
    String replace = '';
    if (slug.isNotEmpty) {
      replace = '${routes[0]}?slug=$slug';
    } else {
      replace = '${routes[0]}?slug=${_store!.id}';
    }
    return replace;
  }

  void pickPrescriptionImage(
      {required bool isRemove, required bool isCamera}) async {
    if (isRemove) {
      _pickedPrescriptions = [];
    } else {
      XFile? xFile = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 50);
      if (xFile != null) {
        _pickedPrescriptions.add(xFile);
      }
      update();
    }
  }

  void removePrescriptionImage(int index) {
    _pickedPrescriptions.removeAt(index);
    update();
  }

  void changeFavVisibility() {
    _showFavButton = !_showFavButton;
    update();
  }

  void hideAnimation() {
    _currentState = false;
  }

  void showButtonAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      _currentState = true;
      update();
    });
  }

  Future<void> getRestaurantRecommendedItemList(
      int? storeId, bool reload) async {
    if (reload) {
      _storeModel = null;
      update();
    }
    Response response = await storeRepo.getStoreRecommendedItemList(storeId);
    if (response.statusCode == 200) {
      _recommendedItemModel = RecommendedItemModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getCartStoreSuggestedItemList(int? storeId) async {
    Response response = await storeRepo.getCartStoreSuggestedItemList(storeId);
    if (response.statusCode == 200) {
      _cartSuggestItemModel = CartSuggestItemModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getStoreBannerList(int? storeId) async {
    Response response = await storeRepo.getStoreBannerList(storeId);
    if (response.statusCode == 200) {
      _storeBanners = [];
      response.body.forEach(
          (banner) => _storeBanners!.add(StoreBannerModel.fromJson(banner)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getStoreList(int offset, bool reload) async {
    if (reload) {
      _storeModel = null;
      update();
    }
    Response response = await storeRepo.getStoreList(offset, _storeType);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _storeModel = StoreModel.fromJson(response.body);
      } else {
        _storeModel!.totalSize = StoreModel.fromJson(response.body).totalSize;
        _storeModel!.offset = StoreModel.fromJson(response.body).offset;
        _storeModel!.stores!.addAll(StoreModel.fromJson(response.body).stores!);
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void setStoreType(String type) {
    _storeType = type;
    getStoreList(1, true);
  }

  Future<void> getPopularStoreList(
      bool reload, String type, bool notify) async {
    _type = type;
    if (reload) {
      _popularStoreList = null;
    }
    if (notify) {
      update();
    }
    if (_popularStoreList == null || reload) {
      Response response = await storeRepo.getPopularStoreList(type);
      if (response.statusCode == 200) {
        _popularStoreList = [];
        response.body['stores']
            .forEach((store) => _popularStoreList!.add(Store.fromJson(store)));
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getLatestStoreList(bool reload, String type, bool notify) async {
    _type = type;
    if (reload) {
      _latestStoreList = null;
    }
    if (notify) {
      update();
    }
    if (_latestStoreList == null || reload) {
      Response response = await storeRepo.getLatestStoreList(type);
      if (response.statusCode == 200) {
        _latestStoreList = [];
        response.body['stores']
            .forEach((store) => _latestStoreList!.add(Store.fromJson(store)));
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getFeaturedStoreList() async {
    Response response = await storeRepo.getFeaturedStoreList();
    if (response.statusCode == 200) {
      _featuredStoreList = [];
      List<Modules> moduleList = [];
      for (ZoneData zone
          in Get.find<LocationController>().getUserAddress()!.zoneData ?? []) {
        for (Modules module in zone.modules ?? []) {
          moduleList.add(module);
        }
      }
      response.body['stores'].forEach((store) {
        for (var module in moduleList) {
          if (module.id == Store.fromJson(store).moduleId) {
            if (module.pivot!.zoneId == Store.fromJson(store).zoneId) {
              _featuredStoreList!.add(Store.fromJson(store));
            }
          }
        }
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getVisitAgainStoreList() async {
    _visitAgainStoreList = null;
    Response response = await storeRepo.getVisitAgainStoreList();
    if (response.statusCode == 200) {
      _visitAgainStoreList = [];
      List<Modules> moduleList = [];
      for (ZoneData zone
          in Get.find<LocationController>().getUserAddress()!.zoneData ?? []) {
        for (Modules module in zone.modules ?? []) {
          moduleList.add(module);
        }
      }
      response.body.forEach((store) {
        for (var module in moduleList) {
          if (module.id == Store.fromJson(store).moduleId) {
            if (module.pivot!.zoneId == Store.fromJson(store).zoneId) {
              _visitAgainStoreList!.add(Store.fromJson(store));
            }
          }
        }
      });
      // print('---------ss-------$_visitAgainStoreList');
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setCategoryList() {
    if (Get.find<CategoryController>().categoryList != null && _store != null) {
      _categoryList = [];
      _categoryList!.add(CategoryModel(id: 0, name: 'all'.tr));
      for (var category in Get.find<CategoryController>().categoryList!) {
        if (_store!.categoryIds!.contains(category.id)) {
          _categoryList!.add(category);
        }
      }
    }
  }

  Future<void> initCheckoutData(int? storeId) async {
    Get.find<CouponController>().removeCouponData(false);
    Get.find<OrderController>().clearPrevData(null);
    await Get.find<StoreController>()
        .getStoreDetails(Store(id: storeId), false);
    Get.find<OrderController>().initializeTimeSlot(_store!);
  }

  Future<Store?> getStoreDetails(Store store, bool fromModule,
      {bool fromCart = false, String slug = ''}) async {
    _categoryIndex = 0;
    if (store.name != null) {
      _store = store;
    } else {
      _isLoading = true;
      _store = null;
      Response response =
          await storeRepo.getStoreDetails(store.id.toString(), fromCart, slug);
      if (response.statusCode == 200) {
        _store = Store.fromJson(response.body);
        Get.find<OrderController>().initializeTimeSlot(_store!);
        if (!fromCart && slug.isEmpty) {
          Get.find<OrderController>().getDistanceInKM(
            LatLng(
              double.parse(
                  Get.find<LocationController>().getUserAddress()!.latitude!),
              double.parse(
                  Get.find<LocationController>().getUserAddress()!.longitude!),
            ),
            LatLng(double.parse(_store!.latitude!),
                double.parse(_store!.longitude!)),
          );
        }
        if (slug.isNotEmpty) {
          await Get.find<LocationController>().setStoreAddressToUserAddress(
              LatLng(double.parse(_store!.latitude!),
                  double.parse(_store!.longitude!)));
        }
        if (fromModule) {
          HomeScreen.loadData(true);
        } else {
          Get.find<OrderController>().clearPrevData(_store!.zoneId);
        }
      } else {
        ApiChecker.checkApi(response);
      }
      Get.find<OrderController>().setOrderType(
        _store != null
            ? _store!.delivery!
                ? 'delivery'
                : 'send_gift'
            : 'delivery',
        notify: false,
      );

      _isLoading = false;
      update();
    }
    return _store;
  }

  Future<void> getRecommendedStoreList() async {
    _recommendedStoreList = null;
    Response response = await storeRepo.getRecommendedStoreList();
    if (response.statusCode == 200) {
      _recommendedStoreList = [];
      response.body['stores'].forEach(
          (store) => _recommendedStoreList!.add(Store.fromJson(store)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getStoreItemList(
      int? storeID, int offset, String type, bool notify) async {
    if (offset == 1 || _storeItemModel == null) {
      _type = type;
      _storeItemModel = null;
      if (notify) {
        update();
      }
    }
    Response response = await storeRepo.getStoreItemList(
      storeID,
      offset,
      (_store != null && _store!.categoryIds!.isNotEmpty && _categoryIndex != 0)
          ? _categoryList![_categoryIndex].id
          : 0,
      type,
    );
    if (response.statusCode == 200) {
      if (offset == 1) {
        _storeItemModel = ItemModel.fromJson(response.body);
      } else {
        _storeItemModel!.items!
            .addAll(ItemModel.fromJson(response.body).items!);
        _storeItemModel!.totalSize =
            ItemModel.fromJson(response.body).totalSize;
        _storeItemModel!.offset = ItemModel.fromJson(response.body).offset;
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getStoreSearchItemList(
      String searchText, String? storeID, int offset, String type) async {
    if (searchText.isEmpty) {
      showCustomSnackBar('write_item_name'.tr);
    } else {
      _isSearching = true;
      _searchText = searchText;
      _type = type;
      if (offset == 1 || _storeSearchItemModel == null) {
        _searchType = type;
        _storeSearchItemModel = null;
        update();
      }
      Response response = await storeRepo.getStoreSearchItemList(
          searchText,
          storeID,
          offset,
          type,
          (_store != null &&
                  _store!.categoryIds!.isNotEmpty &&
                  _categoryIndex != 0)
              ? _categoryList![_categoryIndex].id
              : 0);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _storeSearchItemModel = ItemModel.fromJson(response.body);
        } else {
          _storeSearchItemModel!.items!
              .addAll(ItemModel.fromJson(response.body).items!);
          _storeSearchItemModel!.totalSize =
              ItemModel.fromJson(response.body).totalSize;
          _storeSearchItemModel!.offset =
              ItemModel.fromJson(response.body).offset;
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void changeSearchStatus({bool isUpdate = true}) {
    _isSearching = !_isSearching;
    if (isUpdate) {
      update();
    }
  }

  void initSearchData() {
    _storeSearchItemModel = ItemModel(items: []);
    _searchText = '';
  }

  void setCategoryIndex(int index, {bool itemSearching = false}) {
    _categoryIndex = index;
    if (itemSearching) {
      _storeSearchItemModel = null;
      getStoreSearchItemList(_searchText, _store!.id.toString(), 1, type);
    } else {
      _storeItemModel = null;
      getStoreItemList(_store!.id, 1, Get.find<StoreController>().type, false);
    }

    update();
  }

  Future<void> getStoreReviewList(String? storeID) async {
    _storeReviewList = null;
    Response response = await storeRepo.getStoreReviewList(storeID);
    if (response.statusCode == 200) {
      _storeReviewList = [];
      response.body.forEach(
          (review) => _storeReviewList!.add(ReviewModel.fromJson(review)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  bool isStoreClosed(bool today, bool active, List<Schedules>? schedules) {
    if (!active) {
      return true;
    }
    DateTime date = DateTime.now();
    if (!today) {
      date = date.add(const Duration(days: 1));
    }
    int weekday = date.weekday;
    if (weekday == 7) {
      weekday = 0;
    }
    for (int index = 0; index < schedules!.length; index++) {
      if (weekday == schedules[index].day) {
        return false;
      }
    }
    return true;
  }

  bool isStoreOpenNow(bool active, List<Schedules>? schedules) {
    if (isStoreClosed(true, active, schedules)) {
      return false;
    }
    int weekday = DateTime.now().weekday;
    if (weekday == 7) {
      weekday = 0;
    }
    for (int index = 0; index < schedules!.length; index++) {
      if (weekday == schedules[index].day &&
          DateConverter.isAvailable(
              schedules[index].openingTime, schedules[index].closingTime)) {
        return true;
      }
    }
    return false;
  }

  bool isOpenNow(Store store) => store.open == 1 && store.active!;

  double? getDiscount(Store store) =>
      store.discount != null ? store.discount!.discount : 0;

  String? getDiscountType(Store store) =>
      store.discount != null ? store.discount!.discountType : 'percent';
}
