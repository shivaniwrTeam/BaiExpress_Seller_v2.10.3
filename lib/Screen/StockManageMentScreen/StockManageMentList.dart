import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sellermultivendor/Helper/Color.dart';
import 'package:sellermultivendor/Screen/StockManageMentScreen/widget/manageStockBottomsheet.dart';
import 'package:sellermultivendor/Widget/bottomsheet.dart';
import '../../Helper/Constant.dart';
import '../../Model/ProductModel/Product.dart';
import '../../Provider/settingProvider.dart';
import '../../Provider/stockmanagementProvider.dart';
import '../../Widget/ButtonDesing.dart';
import '../../Widget/desing.dart';
import '../../Widget/networkAvailablity.dart';
import '../../Widget/routes.dart';
import '../../Widget/simmerEffect.dart';
import '../../Widget/validation.dart';
import '../../Widget/noNetwork.dart';
import '../HomePage/home.dart';

class StockManagementList extends StatefulWidget {
  final bool fromNavbar;

  const StockManagementList({super.key, required this.fromNavbar});
  @override
  State<StatefulWidget> createState() => StateProductStock();
}

StockProviderProvider? stockManagementProvider;
bool isUpdateDone = false;

final TextEditingController controllerForStock = TextEditingController();

class StateProductStock extends State<StockManagementList>
    with TickerProviderStateMixin {
  int selectedValue = 1;
  setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controllerForStock.text = '';
    stockManagementProvider =
        Provider.of<StockProviderProvider>(context, listen: false);
    stockManagementProvider!.initializaedVariableWithDefualtValue();
    stockManagementProvider!.controller.addListener(_scrollListener);
    stockManagementProvider!.getProduct("0", context, setStateNow);
    stockManagementProvider!.buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    stockManagementProvider!.buttonSqueezeanimation = Tween(
      begin: width * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: stockManagementProvider!.buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  @override
  void dispose() {
    stockManagementProvider!.buttonController!.dispose();
    stockManagementProvider!.controller.removeListener(() {});
    for (int i = 0; i < stockManagementProvider!.controllers.length; i++) {
      stockManagementProvider!.controllers[i].dispose();
    }
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await stockManagementProvider!.buttonController!.forward();
    } on TickerCanceled {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightWhite,
      key: stockManagementProvider!.scaffoldKey,
      body: isNetworkAvail
          ? Stack(
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [grad1Color, grad2Color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0, 1],
                          tileMode: TileMode.clamp,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(circularBorderRadius10),
                          bottomRight: Radius.circular(circularBorderRadius10),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                widget.fromNavbar
                                    ? Container()
                                    : InkWell(
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                        child: const Padding(
                                          padding: EdgeInsetsDirectional.only(
                                              start: 15.0),
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                Expanded(
                                  child: SizedBox(
                                    height: 36,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        top: 9.0,
                                        start: 15,
                                        end: 15,
                                      ),
                                      child: Text(
                                        getTranslated(
                                            context, 'Stock Management')!,
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          color: white,
                                          fontSize: textFontSize16,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _showBottomSheet();
                                      },
                                      icon: const Icon(
                                        Icons.sort,
                                        color: white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        filterDialog();
                                      },
                                      icon: const Icon(
                                        Icons.filter_alt_outlined,
                                        color: white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(child: _showForm()),
                  ],
                ),
                DesignConfiguration.showCircularProgress(
                  stockManagementProvider!.isProgress,
                  primary,
                ),
              ],
            )
          : noInternet(
              context,
              setStateNoInternate,
              stockManagementProvider!.buttonSqueezeanimation,
              stockManagementProvider!.buttonController,
            ),
    );
  }

  setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          stockManagementProvider!.offset = 0;
          stockManagementProvider!.total = 0;
          stockManagementProvider!.getProduct('0', context, setStateNow);
        } else {
          await stockManagementProvider!.buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  Widget listItem(int index) {
    if (index < stockManagementProvider!.productList.length) {
      Product? model = stockManagementProvider!.productList[index];
      stockManagementProvider!.totalProduct = model.total;

      if (stockManagementProvider!.controllers.length < index + 1) {
        stockManagementProvider!.controllers.add(TextEditingController());
      }
      if (model.prVarientList!.isNotEmpty) {
        stockManagementProvider!.controllers[index].text =
            model.prVarientList![model.selVarient!].cartCount!;
        double price =
            double.parse(model.prVarientList![model.selVarient!].disPrice!);
        if (price == 0) {
          price = double.parse(model.prVarientList![model.selVarient!].price!);
        }
      }
      stockManagementProvider!.items = List<String>.generate(
          model.totalAllow != "" ? int.parse(model.totalAllow!) : 10,
          (i) => (i + 1).toString());
      return Padding(
        padding: const EdgeInsets.only(
          right: 15.0,
          left: 15.0,
          top: 13,
        ),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: blarColor,
                  offset: Offset(0, 0),
                  blurRadius: 4,
                  spreadRadius: 0),
            ],
            color: white,
            borderRadius: BorderRadius.all(
              Radius.circular(circularBorderRadius10),
            ),
          ),
          child: InkWell(
            onTap: () {
              showStockManageBottomsheet(context, model).then((value) {
                if (value == true) {
                  if (mounted) {
                    setState(
                      () {
                        stockManagementProvider!.isLoading = true;
                        stockManagementProvider!.offset = 0;
                        stockManagementProvider!.total = 0;
                        stockManagementProvider!.productList.clear();
                      },
                    );
                  }
                  Future.delayed(const Duration(
                    seconds: 01,
                  )).then(
                    (_) {
                      stockManagementProvider!
                          .getProduct("0", context, setStateNow);
                    },
                  );
                }
              });
            },
            borderRadius: BorderRadius.circular(circularBorderRadius5),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: 12.0,
                        start: 12.0,
                        end: 12.0,
                        bottom: 5.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              end: 12.0,
                            ),
                            child: Hero(
                              tag: "$index${model.id}+ $index${model.name}",
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    circularBorderRadius5),
                                child: DesignConfiguration.getCacheNotworkImage(
                                  boxFit: BoxFit.cover,
                                  context: context,
                                  heightvalue: 70.0,
                                  placeHolderSize: 70.0,
                                  imageurlString: model.image!,
                                  widthvalue: 70.0,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    model.name!,
                                    style: const TextStyle(
                                      color: black,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "PlusJakartaSans",
                                      fontStyle: FontStyle.normal,
                                      fontSize: textFontSize14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                model.prVarientList!.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                                "${getTranslated(context, 'PRICE_LBL')} : ",
                                                style: const TextStyle(
                                                  color: lightBlack,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: "PlusJakartaSans",
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: textFontSize14,
                                                ),
                                                textAlign: TextAlign.left),
                                            model.prVarientList!.isNotEmpty
                                                ? Text(
                                                    double.parse(model
                                                                .prVarientList![
                                                                    model
                                                                        .selVarient!]
                                                                .disPrice!) !=
                                                            0
                                                        ? DesignConfiguration
                                                            .getPriceFormat(
                                                            context,
                                                            double.parse(model
                                                                .prVarientList![
                                                                    model
                                                                        .selVarient!]
                                                                .disPrice!),
                                                          )!
                                                        : DesignConfiguration
                                                            .getPriceFormat(
                                                            context,
                                                            double.parse(model
                                                                .prVarientList![
                                                                    model
                                                                        .selVarient!]
                                                                .price!),
                                                          )!,
                                                    style: const TextStyle(
                                                        color: black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            "PlusJakartaSans",
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        fontSize:
                                                            textFontSize14),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Row(
                                  children: [
                                    Text(
                                      '${getTranslated(context, "Quantity")} : ',
                                      style: const TextStyle(
                                        color: lightBlack,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "PlusJakartaSans",
                                        fontStyle: FontStyle.normal,
                                        fontSize: textFontSize14,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      model.stockType == "2"
                                          ? model.totalStock == null ||
                                                  model.totalStock! == ""
                                              ? "0"
                                              : model.totalStock!
                                          : model.stockType == "1"
                                              ? model.prVarientList![0].stock ==
                                                          null ||
                                                      model.prVarientList![0]
                                                              .stock ==
                                                          ""
                                                  ? "0"
                                                  : model
                                                      .prVarientList![0].stock!
                                              : model.stock == null ||
                                                      model.stock! == ""
                                                  ? "0"
                                                  : model.stock!,
                                      style: const TextStyle(
                                        color: black,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "PlusJakartaSans",
                                        fontStyle: FontStyle.normal,
                                        fontSize: textFontSize14,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _showBottomSheet() async {
    await CustomBottomSheet.showBottomSheet(
      context: context,
      enableDrag: true,
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 10,
                  right: 10),
              child: Column(
                children: [
                  Center(child: CustomBottomSheet.bottomSheetHandle(context)),
                  CustomBottomSheet.bottomSheetLabel(
                    context,
                    getTranslated(context, "SortBy")!,
                  ),
                  Divider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RadioListTile<int>(
                        value: 1,
                        groupValue: selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            selectedValue = value!;
                            stockManagementProvider!.sortBy = '';
                            stockManagementProvider!.orderBy = 'DESC';
                            stockManagementProvider!.isLoading = true;
                            stockManagementProvider!.total = 0;
                            stockManagementProvider!.offset = 0;
                            stockManagementProvider!.productList.clear();
                          });
                          stockManagementProvider!
                              .getProduct("1", context, setStateNow);
                          Navigator.pop(context, 'option 1');
                        },
                        title: Text(
                          getTranslated(context, "TopRated")!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(),
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        controlAffinity: ListTileControlAffinity
                            .trailing, // Moves the radio button to the right
                      ),
                      RadioListTile<int>(
                        value: 2,
                        groupValue: selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            selectedValue = value!;
                            stockManagementProvider!.sortBy = 'p.date_added';
                            stockManagementProvider!.orderBy = 'DESC';
                            stockManagementProvider!.isLoading = true;
                            stockManagementProvider!.total = 0;
                            stockManagementProvider!.offset = 0;
                            stockManagementProvider!.productList.clear();
                          });
                          stockManagementProvider!
                              .getProduct("0", context, setStateNow);
                          Navigator.pop(context, 'option 1');
                        },
                        title: Text(
                          getTranslated(context, "NewestFirst")!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(),
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      RadioListTile<int>(
                        value: 3,
                        groupValue: selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            selectedValue = value!;
                            stockManagementProvider!.sortBy = 'p.date_added';
                            stockManagementProvider!.orderBy = 'ASC';
                            stockManagementProvider!.isLoading = true;
                            stockManagementProvider!.total = 0;
                            stockManagementProvider!.offset = 0;
                            stockManagementProvider!.productList.clear();
                          });
                          stockManagementProvider!
                              .getProduct("0", context, setStateNow);
                          Navigator.pop(context, 'option 2');
                        },
                        title: Text(
                          getTranslated(context, "OldestFirst")!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(),
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      RadioListTile<int>(
                        value: 4,
                        groupValue: selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            selectedValue = value!;
                            stockManagementProvider!.sortBy = 'pv.price';
                            stockManagementProvider!.orderBy = 'ASC';
                            stockManagementProvider!.isLoading = true;
                            stockManagementProvider!.total = 0;
                            stockManagementProvider!.offset = 0;
                            stockManagementProvider!.productList.clear();
                          });
                          stockManagementProvider!
                              .getProduct("0", context, setStateNow);
                          Navigator.pop(context, 'option 3');
                        },
                        title: Text(
                          getTranslated(context, "LOWTOHIGH")!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(),
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      RadioListTile<int>(
                        value: 5,
                        groupValue: selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            selectedValue = value!;
                            stockManagementProvider!.sortBy = 'pv.price';
                            stockManagementProvider!.orderBy = 'DESC';
                            stockManagementProvider!.isLoading = true;
                            stockManagementProvider!.total = 0;
                            stockManagementProvider!.offset = 0;
                            stockManagementProvider!.productList.clear();
                          });
                          stockManagementProvider!
                              .getProduct("0", context, setStateNow);
                          Navigator.pop(context, 'option 4');
                        },
                        title: Text(
                          getTranslated(context, "HIGHTOLOW")!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(),
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ],
                  ),
                  Platform.isIOS
                      ? const Padding(padding: EdgeInsets.only(bottom: 20))
                      : const Padding(padding: EdgeInsets.zero)
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  _scrollListener() {
    if (stockManagementProvider!.controller.offset >=
            stockManagementProvider!.controller.position.maxScrollExtent &&
        !stockManagementProvider!.controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(
            () {
              isLoadingmore = true;
              if (stockManagementProvider!.offset <
                  stockManagementProvider!.total) {
                stockManagementProvider!.getProduct("0", context, setStateNow);
              }
            },
          );
        }
      }
    }
  }

  Future<void> _refresh() {
    if (mounted) {
      setState(
        () {
          stockManagementProvider!.isLoading = true;
          isLoadingmore = true;
          stockManagementProvider!.offset = 0;
          stockManagementProvider!.total = 0;
          stockManagementProvider!.productList.clear();
        },
      );
    }
    return stockManagementProvider!.getProduct("0", context, setStateNow);
  }

  _showForm() {
    return stockManagementProvider!.isLoading
        ? const ShimmerEffect()
        : stockManagementProvider!.productList.isEmpty
            ? DesignConfiguration.getNoItem(context)
            : RefreshIndicator(
                key: stockManagementProvider!.refreshIndicatorKey,
                onRefresh: _refresh,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: stockManagementProvider!.controller,
                    itemCount: (stockManagementProvider!.offset <
                            stockManagementProvider!.total)
                        ? stockManagementProvider!.productList.length + 1
                        : stockManagementProvider!.productList.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return (index ==
                                  stockManagementProvider!.productList.length &&
                              isLoadingmore)
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : listItem(index);
                    },
                  ),
                ),
              );
  }

  productDeletDialog(
    String productName,
    String id,
    BuildContext cntx,
  ) async {
    String pName = productName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(circularBorderRadius5),
                ),
              ),
              content: Text(
                "${getTranslated(context, "sure")!} \"  $pName \" ${getTranslated(context, "PRODUCTS")!}",
                style: Theme.of(this.context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      getTranslated(context, "LOGOUTNO")!,
                      style: Theme.of(this.context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTYES")!,
                    style: Theme.of(this.context)
                        .textTheme
                        .titleSmall!
                        .copyWith(
                            color: fontColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Routes.pop(context);
                    stockManagementProvider!.deleteProductApi(
                      id,
                      cntx,
                      setStateNow,
                    );

                    setState(
                      () {
                        stockManagementProvider!.isLoading = true;
                        isLoadingmore = true;
                        stockManagementProvider!.offset = 0;
                        stockManagementProvider!.total = 0;
                        stockManagementProvider!.productList.clear();
                        stockManagementProvider!
                            .getProduct("0", context, setStateNow);
                      },
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  void filterDialog() {
    if (stockManagementProvider!.filterList!.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
        builder: (builder) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 30.0),
                    child: AppBar(
                      backgroundColor: lightWhite,
                      title: Text(
                        getTranslated(context, "Filter")!,
                        style: const TextStyle(
                          color: fontColor,
                        ),
                      ),
                      elevation: 5,
                      leading: Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.all(10),
                            decoration: DesignConfiguration.shadow(),
                            child: Card(
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    circularBorderRadius5),
                                onTap: () => Navigator.of(context).pop(),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.only(end: 4.0),
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsetsDirectional.only(end: 10.0),
                          alignment: Alignment.center,
                          child: InkWell(
                            child: Text(
                              getTranslated(context, "ClearFilters")!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: fontColor,
                                  ),
                            ),
                            onTap: () {
                              if (mounted) {
                                setState(
                                  () {
                                    stockManagementProvider!.selectedId.clear();
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: lightWhite,
                      padding: const EdgeInsetsDirectional.only(
                        start: 7.0,
                        end: 7.0,
                        top: 7.0,
                      ),
                      child: Card(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                color: lightWhite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 10.0),
                                  itemCount: stockManagementProvider!
                                      .filterList!.length,
                                  itemBuilder: (context, index) {
                                    stockManagementProvider!.attsubList =
                                        stockManagementProvider!
                                            .filterList![index]
                                                ['attribute_values']
                                            .split(',');

                                    stockManagementProvider!.attListId =
                                        stockManagementProvider!
                                            .filterList![index]
                                                ['attribute_values_id']
                                            .split(',');

                                    if (stockManagementProvider!.filter == "") {
                                      stockManagementProvider!.filter =
                                          stockManagementProvider!
                                              .filterList![0]["name"];
                                    }

                                    return InkWell(
                                      onTap: () {
                                        if (mounted) {
                                          setState(
                                            () {
                                              stockManagementProvider!.filter =
                                                  stockManagementProvider!
                                                          .filterList![index]
                                                      ['name'];
                                            },
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 20,
                                                top: 10.0,
                                                bottom: 10.0),
                                        decoration: BoxDecoration(
                                          color: stockManagementProvider!
                                                      .filter ==
                                                  stockManagementProvider!
                                                          .filterList![index]
                                                      ['name']
                                              ? white
                                              : lightWhite,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(
                                                circularBorderRadius7),
                                            bottomLeft: Radius.circular(
                                              7,
                                            ),
                                          ),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          stockManagementProvider!
                                              .filterList![index]['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: stockManagementProvider!
                                                            .filter ==
                                                        stockManagementProvider!
                                                                .filterList![
                                                            index]['name']
                                                    ? fontColor
                                                    : lightBlack,
                                                fontWeight: FontWeight.normal,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsetsDirectional.only(top: 10.0),
                                scrollDirection: Axis.vertical,
                                itemCount:
                                    stockManagementProvider!.filterList!.length,
                                itemBuilder: (context, index) {
                                  if (stockManagementProvider!.filter ==
                                      stockManagementProvider!
                                          .filterList![index]["name"]) {
                                    stockManagementProvider!.attsubList =
                                        stockManagementProvider!
                                            .filterList![index]
                                                ['attribute_values']
                                            .split(',');

                                    stockManagementProvider!.attListId =
                                        stockManagementProvider!
                                            .filterList![index]
                                                ['attribute_values_id']
                                            .split(',');
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: stockManagementProvider!
                                          .attListId!.length,
                                      itemBuilder: (context, i) {
                                        return CheckboxListTile(
                                          dense: true,
                                          title: Text(
                                              stockManagementProvider!
                                                  .attsubList![i],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      color: lightBlack,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                          value: stockManagementProvider!
                                              .selectedId
                                              .contains(stockManagementProvider!
                                                  .attListId![i]),
                                          activeColor: primary,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          onChanged: (bool? val) {
                                            if (mounted) {
                                              setState(
                                                () {
                                                  if (val == true) {
                                                    stockManagementProvider!
                                                        .selectedId
                                                        .add(
                                                            stockManagementProvider!
                                                                .attListId![i]);
                                                  } else {
                                                    stockManagementProvider!
                                                        .selectedId
                                                        .remove(
                                                            stockManagementProvider!
                                                                .attListId![i]);
                                                  }
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: white,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stockManagementProvider!.total.toString()),
                              Text(getTranslated(context, "Productsfound")!),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SimBtn(
                          size: 0.4,
                          title: getTranslated(context, "Apply")!,
                          onBtnSelected: () {
                            stockManagementProvider!.selId =
                                stockManagementProvider!.selectedId.join(',');

                            if (mounted) {
                              setState(
                                () {
                                  stockManagementProvider!.isLoading = true;
                                  stockManagementProvider!.total = 0;
                                  stockManagementProvider!.offset = 0;
                                  stockManagementProvider!.productList.clear();
                                },
                              );
                            }
                            stockManagementProvider!
                                .getProduct("0", context, setStateNow);
                            Navigator.pop(context, 'Product Filter');
                          },
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
      );
    }
  }
}
