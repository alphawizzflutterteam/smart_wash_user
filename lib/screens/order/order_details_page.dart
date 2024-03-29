import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dry_cleaners/constants/app_box_decoration.dart';
import 'package:dry_cleaners/constants/app_colors.dart';
import 'package:dry_cleaners/constants/app_text_decor.dart';
import 'package:dry_cleaners/constants/hive_contants.dart';
import 'package:dry_cleaners/generated/l10n.dart';
import 'package:dry_cleaners/misc/global_functions.dart';
import 'package:dry_cleaners/models/hive_cart_item_model.dart';
import 'package:dry_cleaners/models/order_details_model/product.dart';
import 'package:dry_cleaners/providers/order_providers.dart';
import 'package:dry_cleaners/screens/order/order_dialouges.dart';
import 'package:dry_cleaners/utils/context_less_nav.dart';
import 'package:dry_cleaners/widgets/buttons/order_cancel_button.dart';
import 'package:dry_cleaners/widgets/dashed_line.dart';
import 'package:dry_cleaners/widgets/global_functions.dart';
import 'package:dry_cleaners/widgets/misc_widgets.dart';
import 'package:dry_cleaners/widgets/nav_bar.dart';
import 'package:dry_cleaners/widgets/screen_wrapper.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../../constants/config.dart';
import '../../utils/routes.dart';
import '../map_tracking.dart';

class OrderDetails extends ConsumerWidget {
  OrderDetails({
    super.key,
    required this.orderID,
  });

  final String orderID;
  final Box cartsBox = Hive.box(AppHSC.cartBox);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Box settingsBox = Hive.box(AppHSC.appSettingsBox);
    ref.watch(orderDetailsProvider(orderID));
    return ScreenWrapper(
      padding: EdgeInsets.zero,
      child: Container(
        height: 812.h,
        width: 375.w,
        color: AppColors.grayBG,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: AppColors.white,
                height: 88.h,
                width: 375.w,
                child: Column(
                  children: [
                    AppSpacerH(44.h),
                    AppNavbar(
                      title: S.of(context).ordrdtls,
                      onBack: () {
                        context.nav.pop();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 724.h,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ref.watch(orderDetailsProvider(orderID)).map(
                      initial: (_) => const LoadingWidget(),
                      loading: (_) => const LoadingWidget(),
                      loaded: (_) {
                        print(_.data.data!.order!.deliveryCharge.runtimeType);
                        print(_.data.data!.order!.totalAmount.runtimeType);
                        double? totalAmounttt;
                        if (_.data.data!.order!.deliveryCharge == 0 &&
                            _.data.data!.order!.discount == 0) {
                          totalAmounttt = _.data.data!.order!.totalAmount;
                        } else {
                          totalAmounttt = _.data.data!.order!.amount!
                                  .toDouble() +
                              _.data.data!.order!.deliveryCharge!.toDouble() -
                              _.data.data!.order!.discount!.toDouble();
                        }

                        final List<OrderDetailsTile> orderWidgets = [];
                        final List<CarItemHiveModel> products = [];
                        for (var i = 0;
                            i < _.data.data!.order!.products!.length;
                            i++) {
                          var subproductprice = 0;
                          for (final subproduct
                              in _.data.data!.order!.products![i].sbproducts!) {
                            for (final orderedsubproduct
                                in _.data.data!.order!.orderSubProduct!) {
                              if (subproduct.id == orderedsubproduct.id) {
                                subproductprice = orderedsubproduct.price!;
                              }
                            }
                          }
                          orderWidgets.add(
                            OrderDetailsTile(
                              product: _.data.data!.order!.products![i],
                              qty: _.data.data!.order!.quantity!.quantity[i]
                                  .quantity,
                              subprice: subproductprice,
                            ),
                          );
                          if (_.data.data!.order!.orderStatus == 'Pending') {
                            cartsBox.clear();
                          }
                          final CarItemHiveModel product = CarItemHiveModel(
                            productsId:
                                _.data.data!.order!.products![i].id ?? 0,
                            productsName:
                                _.data.data!.order!.products![i].name ?? '',
                            productsImage:
                                _.data.data!.order!.products![i].imagePath ??
                                    '',
                            productsQTY: _.data.data!.order!.quantity!
                                .quantity[i].quantity,
                            unitPrice:
                                _.data.data!.order!.products![i].currentPrice ??
                                    0.0,
                            serviceName: _.data.data!.order!.products![i]
                                    .service!.name ??
                                '',
                          );
                          products.add(product);
                        }
                        return ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            AppSpacerH(10.h),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                              decoration: AppBoxDecorations.pageCommonCard,
                              child: ExpandablePanel(
                                header: Text(
                                  '${S.of(context).itms} (${_.data.data!.order!.products!.length})',
                                  style: AppTextDecor.osBold14black,
                                ),
                                collapsed: const SizedBox(),
                                expanded: Column(
                                  children: orderWidgets,
                                ),
                              ),
                            ),
                            AppSpacerH(15.h),

                            Container(
                              width: 335.w,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                              decoration: AppBoxDecorations.pageCommonCard,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // context.nav.pushNamed(
                                          //   Routes.trackScreen,
                                          // );
                                          // context.nav.pushNamed(
                                          //   Routes.chooseItemScreen,
                                          // );
                                          //////////////////////
                                          // Navigator.push(context, MaterialPageRoute(builder: TrackLocation()));
                                        },
                                        child: Icon(
                                          Icons.location_pin,
                                          size: 40.w,
                                        ),
                                      ),
                                      AppSpacerW(10.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _.data.data!.order!.customer!.user!
                                                .name!,
                                            style:
                                                AppTextDecor.osRegular14black,
                                          ),
                                          if (_.data.data!.order!.customer!
                                                  .user!.mobile ==
                                              null)
                                            const SizedBox()
                                          else
                                            Text(
                                              _.data.data!.order!.customer!
                                                  .user!.mobile!,
                                              style:
                                                  AppTextDecor.osRegular14black,
                                            ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            S.of(context).shpngadrs,
                                            style: AppTextDecor.osBold14black,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.8,
                                            child: Text(
                                              _.data.data!.order!.address!
                                                      .area ??
                                                  '',
                                              style:
                                                  AppTextDecor.osRegular14black,
                                            ),
                                          ),
                                          Text(
                                            _.data.data!.order!.address!
                                                    .addressLine ??
                                                '',
                                            style:
                                                AppTextDecor.osRegular14black,
                                          ),
                                          Text(
                                            _.data.data!.order!.address!
                                                    .addressLine2 ??
                                                '',
                                            style:
                                                AppTextDecor.osRegular14black,
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),

                            AppSpacerH(15.h),

                            _.data.data!.order!.orderStatus ==
                                        "Picked your order" &&
                                    _.data.data!.order!.drivers!.isNotEmpty
                                ? InkWell(
                                    onTap: () {
                                      print(_.data.data!.order!.orderStatus);
                                      print(_.data.data!.order!.drivers);

                                      print(_.data.data!.order!.drivers![0]
                                          .userId);

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserMapScreen(
                                              driverId: _.data.data!.order!
                                                  .drivers![0].userId,
                                              userlat: _.data.data!.order!
                                                  .address!.latitude
                                                  .toString(),
                                              userlong: _.data.data!.order!
                                                  .address!.longitude
                                                  .toString(),
                                            ),
                                          ));
                                    },
                                    child: Card(
                                      elevation: 3,
                                      child: Container(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Center(
                                            child: Text('Track To Driver')),
                                      ),
                                    ),
                                  )
                                : SizedBox(),

                            AppSpacerH(15.h),

                            InkWell(
                              onTap: () {
                                downlodInvoice();
                              },
                              child: Card(
                                elevation: 3,
                                child: Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                      child: timeee == 1
                                          ? Text('Waiting...')
                                          : Text('Download Invoice')),
                                ),
                              ),
                            ),
                            AppSpacerH(15.h),
                            Container(
                              width: 335.w,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                              decoration: AppBoxDecorations.pageCommonCard,
                              child: Column(
                                children: [
                                  Table(
                                    children: [
                                      AppGFunctions.tableTitleTextRow(
                                        title: S.of(context).ordrid,
                                        data:
                                            '#${_.data.data!.order!.orderCode}',
                                      ),
                                      AppGFunctions.tableTextRow(
                                        title: S.of(context).pickupat,
                                        data:
                                            '${_.data.data!.order!.pickDate} - ${_.data.data!.order!.pickHour}',
                                      ),
                                      AppGFunctions.tableTextRow(
                                        title: S.of(context).dlvryat,
                                        data:
                                            '${_.data.data!.order!.deliveryDate} - ${_.data.data!.order!.deliveryHour}',
                                      ),
                                      AppGFunctions.tableTextRow(
                                        title: S.of(context).ordrstats,
                                        data: getLng(
                                          en: _.data.data!.order!.orderStatus,
                                          changeLang: _
                                              .data.data!.order!.orderStatusbn
                                              .toString(),
                                        ),
                                      ),
                                      AppGFunctions.tableTextRow(
                                        title: S.of(context).pymntstats,
                                        data: getLng(
                                          en: _.data.data!.order!.paymentStatus,
                                          changeLang: _
                                              .data.data!.order!.paymentStatusbn
                                              .toString(),
                                        ),
                                      ),
                                      AppGFunctions.tableTextRow(
                                        title: S.of(context).delivertpe,
                                        data:
                                            '${_.data.data!.order!.delivertype}',
                                      ),
                                      AppGFunctions.tableTextRow(
                                        title: S.of(context).sbttl,
                                        data:
                                            '${settingsBox.get('currency') ?? '\$'}${_.data.data!.order!.amount}',
                                      ),
                                      AppGFunctions.tableTextRow(
                                        title: S.of(context).dlvrychrg,
                                        data:
                                            '${settingsBox.get('currency') ?? '\$'}${_.data.data!.order!.deliveryCharge}',
                                      ),
                                      AppGFunctions.tableDiscountTextRow(
                                        title: S.of(context).dscnt,
                                        data:
                                            '${settingsBox.get('currency') ?? '\$'}${_.data.data!.order!.discount}',
                                      ),
                                    ],
                                  ),
                                  const MySeparator(),
                                  AppSpacerH(8.5.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).ttl,
                                        style: AppTextDecor.osBold14black,
                                      ),
                                      Text(
                                        '${settingsBox.get('currency') ?? '\$'}'
                                        //'${_.data.data!.order!.totalAmount}',
                                        '${totalAmounttt}',
                                        style: AppTextDecor.osBold14black,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // AppSpacerH(15.h),
                            // MARK: Order update options

                            // if (_.data.data?.order?.orderStatus == 'Pending')
                            //   AppIconTextButton(
                            //     title: S.of(context).updateproduct,
                            //     icon: Icons.edit,
                            //     onTap: () async {
                            //       if (_.data.data!.order!.orderStatus ==
                            //           'Pending') {
                            //         for (final product in products) {
                            //           await cartsBox.add(
                            //             product.toMap(),
                            //           );
                            //         }
                            //         context.nav.pop();
                            //         ref
                            //                 .read(
                            //                   orderIdProvider.notifier,
                            //                 )
                            //                 .state =
                            //             _.data.data!.order!.id.toString();
                            //         ref
                            //             .watch(
                            //               homeScreenIndexProvider.notifier,
                            //             )
                            //             .state = 0;
                            //         ref
                            //             .watch(
                            //               homeScreenPageControllerProvider,
                            //             )
                            //             .animateToPage(
                            //               0,
                            //               duration: transissionDuration,
                            //               curve: Curves.easeInOut,
                            //             );
                            //       }
                            //     },
                            //   ),
                            if (_.data.data?.order?.orderStatus ==
                                    'Delivered' &&
                                _.data.data?.order?.rating == null)
                              CancelOrderButton(
                                title: S.of(context).rateurexprnc,
                                onTap: () {
                                  AppOrderDialouges.orderFeedBackDialouge(
                                    context: context,
                                    orderID: _.data.data!.order!.id.toString(),
                                    ref: ref,
                                  );
                                },
                              ),
                            AppSpacerH(8.h)
                          ],
                        );
                      },
                      error: (_) => ErrorTextWidget(
                        error: _.error,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var timeee = 0;
  var tokenn;
  var tokentype;
  Future<void> downlodInvoice() async {
    timeee = 1;
    tokenn = Hive.box(AppHSC.authBox);
    if (tokenn!.get(AppHSC.authToken) != null &&
        tokenn!.get(AppHSC.authToken) != '') {}
    final String token = tokenn!.get(AppHSC.authToken) as String;
    final String tokenType = tokenn!.get(AppHSC.authTokenType) as String;

    var headers = {
      'Authorization': '$tokenType $token',
    };
    var request = http.Request(
        'POST', Uri.parse('${AppConfig.baseUrl}/getinvoice/${orderID}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(request.url);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalresult = jsonDecode(result);

      urlpdg = finalresult['pdf_url'];
      print(
          "===my technic=======${AppConfig.baseUrl}/getinvoice/${orderID}==============");
      print("invoice================${urlpdg}");
      downloadPdf();

      timeee = 0;
    } else {
      print(response.reasonPhrase);
    }
  }
}

var urlpdg;
Directory? dir;
downloadPdf() async {
  Dio dio = Dio();
  try {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      String fileName = urlpdg.toString().split('/').last;
      print("FileName: $fileName");
      dir = Directory('/storage/emulated/0/Download/'); // for android
      if (!await dir!.exists()) dir = await getExternalStorageDirectory();
      String path = "${dir?.path}$fileName";
      await dio.download(
        urlpdg.toString(),
        path,
        onReceiveProgress: (recivedBytes, totalBytes) {
          print(recivedBytes);
        },
        deleteOnError: true,
      ).then((value) async {
        Fluttertoast.showToast(msg: 'Invoice Downloaded !');
        await Share.shareXFiles([XFile(path)], text: fileName);
      });
    } else {
      launch(urlpdg.toString());
    }
  } catch (e, stackTrace) {
    print(stackTrace);
    throw Exception(e);
  }
}

class OrderDetailsTile extends StatelessWidget {
  const OrderDetailsTile({
    super.key,
    required this.product,
    required this.qty,
    this.subprice,
  });
  final Product product;
  final int qty;
  final int? subprice;

  @override
  Widget build(BuildContext context) {
    final Box settingsBox = Hive.box(AppHSC.appSettingsBox);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SizedBox(
        // height: 40.h,
        width: 297.w,
        child: Row(
          children: [
            Image.network(
              product.imagePath!,
              height: 40.h,
              width: 42.w,
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name!,
                          style: AppTextDecor.osBold12black,
                        ),
                      ),
                      Text(
                        '${settingsBox.get('currency') ?? '\$'}${(product.currentPrice! + (subprice != null ? subprice! : 0)) * qty}',
                        style: AppTextDecor.osBold12gold,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.service?.name ?? '',
                          style: AppTextDecor.osRegular12navy,
                          maxLines: 3,
                        ),
                      ),
                      Text(
                        '${qty}x${settingsBox.get('currency') ?? '\$'}${product.currentPrice! + (subprice != null ? subprice! : 0)} ',
                        style: AppTextDecor.osRegular12navy,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
