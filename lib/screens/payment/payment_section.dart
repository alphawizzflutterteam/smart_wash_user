import 'dart:developer';

import 'package:dry_cleaners/constants/app_box_decoration.dart';
import 'package:dry_cleaners/constants/app_text_decor.dart';
import 'package:dry_cleaners/constants/hive_contants.dart';
import 'package:dry_cleaners/generated/l10n.dart';
import 'package:dry_cleaners/misc/global_functions.dart';
import 'package:dry_cleaners/misc/misc_global_variables.dart';
import 'package:dry_cleaners/models/hive_cart_item_model.dart';
import 'package:dry_cleaners/models/order_place_model/order_place_model.dart';
import 'package:dry_cleaners/providers/misc_providers.dart';
import 'package:dry_cleaners/providers/order_providers.dart';
import 'package:dry_cleaners/providers/settings_provider.dart';
import 'package:dry_cleaners/screens/payment/payment_screen.dart';
import 'package:dry_cleaners/utils/context_less_nav.dart';
import 'package:dry_cleaners/utils/routes.dart';
import 'package:dry_cleaners/widgets/buttons/full_width_button.dart';
import 'package:dry_cleaners/widgets/misc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../homePage/home_tab.dart';

// ignore: must_be_immutable
class PaymentSection extends ConsumerWidget {
  PaymentSection({
    super.key,
    required this.instruction,
    required this.selectedPaymentType,
  });
  final Box appSettingsBox = Hive.box(AppHSC.appSettingsBox);
  int? couponID;
  Razorpay? _razorpay;
  final TextEditingController instruction;
  var address;
  var pickUp;
  var delivery;
  final PaymentType selectedPaymentType;
  final List<CarItemHiveModel> cartItems = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response,
    ) async {
      print("transaction id${response.paymentId!}");
      ref
          .watch(
            placeOrdersProvider.notifier,
          )
          .addOrder(
            OrderPlaceModel(
              franchise_id: frenchId.toString(),
              vendor_id: outletid.toString(),
              deliver_type: selectedValue.toString(),
              address_id: address,
              pick_date:
                  "${pickUp.dateTime.year}-${pickUp.dateTime.month}-${pickUp.dateTime.day}",
              pick_hour: pickUp.schedule.hour.toString(),
              delivery_date:
                  "${delivery.dateTime.year}-${delivery.dateTime.month}-${delivery.dateTime.day}",
              delivery_hour: delivery.schedule.hour.toString(),
              coupon_id: couponID?.toString() ?? '',
              instruction: instruction.text,
              products: cartItems
                  .map(
                    (e) => OrderProductModel(
                      id: e.productsId.toString(),
                      quantity: e.productsQTY.toString(),
                      subid: e.subProduct != null
                          ? e.subProduct!.id.toString()
                          : null,
                    ),
                  )
                  .toList(),
              additional_service_id: [],
            ),
          );
    }

    Future<void> _handlePaymentError(PaymentFailureResponse response) async {
      log(response.message.toString());
      Fluttertoast.showToast(msg: "Payment cancelled by user");
    }

    void _handleExternalWallet(ExternalWalletResponse response) {}
    Future<void> openCheckout(amount) async {
      double res = double.parse(amount.toString());
      int pricerazorpayy = int.parse(res.toStringAsFixed(0)) * 100;
      print("res: $res");
      // Navigator.of(context).pop();
      var options = {
        'key': 'rzp_test_1DP5mmOlF5G5ag',
        'amount': "$pricerazorpayy",
        'name': 'Advertising',
        'image': 'assets/images/alpha_logo-light.png',
        'description': 'Advertising',
      };
      try {
        print("object");
        _razorpay?.open(options);
      } catch (e) {
        debugPrint('Error: e');
      }
    }

    ref.watch(couponProvider).maybeWhen(
          orElse: () {},
          loaded: (_) {
            couponID = _.data?.coupon?.id;
          },
        );
    int? minimum;
    double? dlvrychrg;
    double? free;
    final selectedLocal = appSettingsBox.get(AppHSC.appLocal);
    ref.watch(settingsProvider).whenOrNull(
      loaded: (data) {
        minimum = data.data!.minimumCost;
        dlvrychrg = data.data!.deliveryCost!.toDouble();
        free = data.data!.feeCost!.toDouble();
      },
    );

    return ValueListenableBuilder(
      valueListenable: Hive.box(AppHSC.cartBox).listenable(),
      builder: (
        BuildContext context,
        Box cartBox,
        Widget? child,
      ) {
        for (var i = 0; i < cartBox.length; i++) {
          final Map<String, dynamic> processedData = {};
          final Map<dynamic, dynamic> unprocessedData =
              cartBox.getAt(i) as Map<dynamic, dynamic>;

          unprocessedData.forEach((key, value) {
            processedData[key.toString()] = value;
          });

          cartItems.add(
            CarItemHiveModel.fromMap(
              processedData,
            ),
          );
        }
        return Container(
          width: 375.w,
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 25.h,
          ),
          decoration: AppBoxDecorations.pageCommonCard,
          child: SizedBox(
            // height: 70.h,
            child: Consumer(
              builder: (context, ref, child) {
                return ref.watch(placeOrdersProvider).map(
                      initial: (_) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).ttlpybl,
                                style: AppTextDecor.osSemiBold18black,
                              ),
                              if (AppGFunctions.calculateTotal(
                                    cartItems,
                                  ).toInt() <
                                  free!) ...[
                                Text(
                                  '${appSettingsBox.get('currency') ?? '\$'}${(AppGFunctions.calculateTotal(cartItems) + dlvrychrg! - ref.watch(discountAmountProvider)).toStringAsFixed(2)}',
                                  style: AppTextDecor.osBold14black,
                                ),
                              ] else ...[
                                Text(
                                  '${appSettingsBox.get('currency') ?? '\$'}${(AppGFunctions.calculateTotal(cartItems) - ref.watch(discountAmountProvider)).toStringAsFixed(2)}',
                                  style: AppTextDecor.osSemiBold18black,
                                ),
                              ],
                              // Text(
                              //   '${appSettingsBox.get('currency') ?? '\$'}${(calculateTotal(cartItems) + dlvrychrg! - ref.watch(discountAmountProvider)).toStringAsFixed(2)}',
                              //   style: AppTextDecor.osSemiBold18black,
                              // ),
                            ],
                          ),
                          AppSpacerH(10.h),
                          AppTextButton(
                            title: S.of(context).pynw,
                            onTap: () async {
                              print(
                                  "${selectedValue.runtimeType}================${selectedValue}");

                              /*
                                      Order Placement Data Validation and Logic Processed Here
                                      */
                              final DateFormat formatter = DateFormat(
                                'yyyy-MM-dd',
                              );
                              final isOrderProcessing =
                                  ref.watch(orderProcessingProvider);

                              if (!isOrderProcessing) {
                                ref
                                    .watch(orderProcessingProvider.notifier)
                                    .state = true;
                                pickUp = ref.watch(
                                  scheduleProvider('Pick Up'),
                                );
                                delivery = ref.watch(
                                  scheduleProvider(
                                    'Delivery',
                                  ),
                                );
                                address = ref.watch(
                                  addressIDProvider,
                                );

                                //Cheks All Reguired Data Is AvailAble
                                if (selectedValue != '' &&
                                    selectedValue != null &&
                                    outletid != null &&
                                    outletid != '' &&
                                    pickUp != null &&
                                    delivery != null &&
                                    address != '' &&
                                    cartItems.isNotEmpty) {
                                  //Has All Data
                                  print(selectedPaymentType);
                                  if (selectedPaymentType ==
                                      PaymentType.Razorpay) {
                                    try {
                                      _razorpay = Razorpay();
                                      _razorpay?.on(
                                          Razorpay.EVENT_PAYMENT_SUCCESS,
                                          _handlePaymentSuccess);
                                      _razorpay?.on(
                                          Razorpay.EVENT_PAYMENT_ERROR,
                                          _handlePaymentError);
                                      _razorpay?.on(
                                          Razorpay.EVENT_EXTERNAL_WALLET,
                                          _handleExternalWallet);
                                      await openCheckout(
                                          '${(AppGFunctions.calculateTotal(cartItems) - ref.watch(discountAmountProvider)).toStringAsFixed(2)}');
                                      // ref
                                    } catch (e, stackTrace) {
                                      print(stackTrace);
                                      throw Exception(e);
                                    }
                                  } else {
                                    ref
                                        .watch(
                                          placeOrdersProvider.notifier,
                                        )
                                        .addOrder(
                                          OrderPlaceModel(
                                            franchise_id: frenchId.toString(),
                                            vendor_id: outletid.toString(),
                                            deliver_type:
                                                selectedValue.toString(),
                                            address_id: address,
                                            pick_date:
                                                "${pickUp.dateTime.year}-${pickUp.dateTime.month}-${pickUp.dateTime.day}",
                                            pick_hour:
                                                pickUp.schedule.hour.toString(),
                                            delivery_date:
                                                "${delivery.dateTime.year}-${delivery.dateTime.month}-${delivery.dateTime.day}",
                                            delivery_hour: delivery
                                                .schedule.hour
                                                .toString(),
                                            coupon_id:
                                                couponID?.toString() ?? '',
                                            instruction: instruction.text,
                                            products: cartItems
                                                .map(
                                                  (e) => OrderProductModel(
                                                    id: e.productsId.toString(),
                                                    quantity: e.productsQTY
                                                        .toString(),
                                                    subid: e.subProduct != null
                                                        ? e.subProduct!.id
                                                            .toString()
                                                        : null,
                                                  ),
                                                )
                                                .toList(),
                                            additional_service_id: [],
                                          ),
                                        );
                                  }
                                } else {
                                  //Missing Data

                                  EasyLoading.showError(
                                    S.of(context).plsslctalflds,
                                  );
                                }
                                ref
                                    .watch(orderProcessingProvider.notifier)
                                    .state = false;
                              } else {
                                EasyLoading.showError(
                                  S.of(context).wrprcsngprvsdlvry,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      loading: (_) => const LoadingWidget(),
                      loaded: (_) {
                        final String amount = (calculateTotal(cartItems) -
                                ref.watch(
                                  discountAmountProvider,
                                ))
                            .toStringAsFixed(2);

                        Future.delayed(buildDuration).then((value) async {
                          EasyLoading.showSuccess(
                            S.of(context).ordrplcd,
                          );

                          await cartBox.clear();
                          ref.refresh(placeOrdersProvider);
                          ref.refresh(couponProvider);
                          ref.refresh(
                            discountAmountProvider,
                          );
                          ref
                              .watch(
                                dateProvider('Pick Up').notifier,
                              )
                              .state = null;
                          ref
                              .watch(
                                dateProvider('Delivery').notifier,
                              )
                              .state = null;
                          context.nav.pushNamedAndRemoveUntil(
                            Routes.orderSuccessScreen,
                            arguments: {
                              'id': _.data.data!.order!.orderCode,
                              'amount': amount,
                              'couponID': couponID.toString(),
                              'isCOD': selectedPaymentType == PaymentType.cod
                            },
                            (route) => false,
                          );
                        });
                        return MessageTextWidget(
                          msg: S.of(context).ordrplcd,
                        );
                      },
                      error: (_) {
                        Future.delayed(
                          const Duration(seconds: 2),
                        ).then((value) {
                          ref.refresh(placeOrdersProvider);
                        });
                        return ErrorTextWidget(
                          error: _.error,
                        );
                      },
                    );
              },
            ),
          ),
        );
      },
    );
  }

  double calculateTotal(List<CarItemHiveModel> cartItems) {
    double amount = 0;
    for (final element in cartItems) {
      if (element.subProduct != null) {
        amount += element.productsQTY *
            (element.unitPrice + element.subProduct!.price!);
      } else {
        amount += element.productsQTY * element.unitPrice;
      }
    }

    return amount;
  }
}
