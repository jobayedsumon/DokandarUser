import 'dart:async';

import 'package:dokandar/data/api/api_checker.dart';
import 'package:dokandar/data/model/response/flash_sale_model.dart';
import 'package:dokandar/data/model/response/product_flash_sale.dart';
import 'package:dokandar/data/repository/flash_sale_repo.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FlashSaleController extends GetxController implements GetxService {
  final FlashSaleRepo flashSaleRepo;

  FlashSaleController({required this.flashSaleRepo});

  Duration? _duration;
  Timer? _timer;
  FlashSaleModel? _flashSaleModel;
  int _pageIndex = 1;
  ProductFlashSale? _productFlashSale;

  Duration? get duration => _duration;

  FlashSaleModel? get flashSaleModel => _flashSaleModel;

  int get pageIndex => _pageIndex;

  ProductFlashSale? get productFlashSale => _productFlashSale;

  void setPageIndex(int index) {
    _pageIndex = index;
    update();
  }

  void setEmptyFlashSale() {
    _flashSaleModel = null;
  }

  Future<void> getFlashSale(bool reload, bool notify) async {
    if (_flashSaleModel == null || reload) {
      _flashSaleModel = null;
    }
    if (notify) {
      update();
    }
    if (_flashSaleModel == null || reload) {
      Response response = await flashSaleRepo.getFlashSale();
      if (response.statusCode == 200) {
        _flashSaleModel = FlashSaleModel.fromJson(response.body);

        if (_flashSaleModel?.endDate != null) {
          DateTime endTime = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS')
              .parse(_flashSaleModel!.endDate!, true)
              .toLocal();
          // print('-----------end time  : $endTime');
          _duration = endTime.difference(DateTime.now());
          _timer?.cancel();
          _timer = null;
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            _duration = _duration! - const Duration(seconds: 1);
            update();
          });
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getFlashSaleWithId(int offset, bool reload, int id) async {
    if (reload) {
      _productFlashSale = null;
      update();
    }

    Response response = await flashSaleRepo.getFlashSaleWithId(id, offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _productFlashSale = ProductFlashSale.fromJson(response.body);
      } else {
        _productFlashSale!.totalSize =
            ProductFlashSale.fromJson(response.body).totalSize;
        _productFlashSale!.offset =
            ProductFlashSale.fromJson(response.body).offset;
        _productFlashSale!.flashSale =
            ProductFlashSale.fromJson(response.body).flashSale;
        _productFlashSale!.products!
            .addAll(ProductFlashSale.fromJson(response.body).products!);
      }

      if (_productFlashSale!.flashSale!.endDate != null) {
        DateTime endTime = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS')
            .parse(_productFlashSale!.flashSale!.endDate!, true)
            .toLocal();
        _duration = endTime.difference(DateTime.now());
        _timer?.cancel();
        _timer = null;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _duration = _duration! - const Duration(seconds: 1);
          update();
        });
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }
}
