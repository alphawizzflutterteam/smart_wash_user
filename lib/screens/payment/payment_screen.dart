import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:dry_cleaners/constants/app_box_decoration.dart';
import 'package:dry_cleaners/constants/app_colors.dart';
import 'package:dry_cleaners/constants/app_text_decor.dart';
import 'package:dry_cleaners/constants/hive_contants.dart';
import 'package:dry_cleaners/constants/input_field_decorations.dart';
import 'package:dry_cleaners/generated/l10n.dart';
import 'package:dry_cleaners/misc/global_functions.dart';
import 'package:dry_cleaners/providers/address_provider.dart';
import 'package:dry_cleaners/providers/misc_providers.dart';
import 'package:dry_cleaners/screens/order/payment_method_card.dart';
import 'package:dry_cleaners/screens/payment/payment_controller.dart';
import 'package:dry_cleaners/screens/payment/payment_section.dart';
import 'package:dry_cleaners/screens/payment/schedule_picker_widget.dart';
import 'package:dry_cleaners/utils/context_less_nav.dart';
import 'package:dry_cleaners/utils/routes.dart';
import 'package:dry_cleaners/widgets/buttons/button_with_icon.dart';
import 'package:dry_cleaners/widgets/misc_widgets.dart';
import 'package:dry_cleaners/widgets/nav_bar.dart';
import 'package:dry_cleaners/widgets/screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? selectedValue;

class CheckOutScreen extends ConsumerStatefulWidget {
  const CheckOutScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends ConsumerState<CheckOutScreen> {
  final PaymentController pay = PaymentController();
  final TextEditingController _instruction = TextEditingController();
  final TextEditingController couponController = TextEditingController();
  final Box appSettingsBox = Hive.box(AppHSC.appSettingsBox);
  PaymentType selectedPaymentType = PaymentType.cod;

  String? male;
  String couponAmount = "";
  int? couponId;
  @override
  Widget build(BuildContext context) {
    // int? couponID;
    ref.watch(addressIDProvider);
    ref.watch(dateProvider('Pick Up'));
    ref.watch(dateProvider('Delivery'));
    // ref.watch(couponProvider).maybeWhen(
    //       orElse: () {},
    //       loaded: (_) {
    //         couponID = _.data?.coupon?.id;
    //       },
    //     );
    return WillPopScope(
      onWillPop: () {
        ref.watch(dateProvider('Pick Up').notifier).state = null;
        ref.watch(dateProvider('Delivery').notifier).state = null;
        return Future.value(true);
      },
      child: ScreenWrapper(
        padding: EdgeInsets.zero,
        child: Container(
          height: 812.h,
          width: 375.w,
          color: AppColors.grayBG,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    color: AppColors.white,
                    height: 88.h,
                    width: 375.w,
                    child: Column(
                      children: [
                        AppSpacerH(44.h),
                        AppNavbar(
                          title: S.of(context).shpngndpymnt,
                          onBack: () {
                            context.nav.pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        AppSpacerH(10.h),
                        Container(
                          width: 375.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 15.h,
                          ),
                          decoration: AppBoxDecorations.pageCommonCard,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).shptpe,
                                style: AppTextDecor.osSemiBold18black,
                              ),
                              // const CutomDatePicker('Collection Date'),
                              AppSpacerH(10.h),

                              Row(
                                children: [
                                  Radio(
                                      value: "1",
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      groupValue: selectedValue,
                                      activeColor: Colors.blueAccent,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedValue = val.toString();
                                          print("${selectedValue}");
                                        });
                                      }),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    S.of(context).selfpic,
                                    style: AppTextDecor.osSemiBold18black,
                                  ),
                                ],
                              ),
                              Row(children: [
                                Radio(
                                    value: "2",
                                    groupValue: selectedValue,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    activeColor: Colors.blueAccent,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedValue = val.toString();
                                        print("${selectedValue}");
                                      });
                                    }),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  S.of(context).pickupbydriver,
                                  style: AppTextDecor.osSemiBold18black,
                                ),
                              ]),
                              AppSpacerH(10.h),
                              Text(
                                S.of(context).shpngschdl,
                                style: AppTextDecor.osSemiBold18black,
                              ),
                              // const CutomDatePicker('Collection Date'),
                              AppSpacerH(10.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: ShedulePicker(
                                      image: 'assets/images/pickup-car.png',
                                      title: S.of(context).pickupat,
                                    ),
                                  ),
                                  AppSpacerW(10.w),
                                  Expanded(
                                    child: ShedulePicker(
                                      image: 'assets/images/pick-up-truck.png',
                                      title: S.of(context).dlvryat,
                                    ),
                                  ),
                                ],
                              ),

                              AppSpacerH(10.h),
                            ],
                          ),
                        ),
                        AppSpacerH(10.h),
                        Container(
                          width: 375.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 15.h,
                          ),
                          decoration: AppBoxDecorations.pageCommonCard,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 335.w,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).adrs,
                                      style: AppTextDecor.osSemiBold18black,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.nav.pushNamed(
                                          Routes.manageAddressScreen,
                                        );
                                      },
                                      // ignore: use_decorated_box
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.grayBG,
                                          borderRadius:
                                              BorderRadius.circular(5.w),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            S.of(context).mngaddrs,
                                            style:
                                                AppTextDecor.osSemiBold14navy,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacerH(11.h),
                              ref.watch(addresListProvider).map(
                                    initial: (_) => const SizedBox(),
                                    loading: (_) => const LoadingWidget(),
                                    loaded: (_) => _
                                            .data.data!.addresses!.isEmpty
                                        ? AppIconTextButton(
                                            icon: Icons.add,
                                            title: S.of(context).adadres,
                                            onTap: () {
                                              context.nav.pushNamed(
                                                Routes.addOrUpdateAddressScreen,
                                              );
                                            },
                                          )
                                        : FormBuilderDropdown(
                                            decoration: AppInputDecor
                                                .loginPageInputDecor
                                                .copyWith(
                                              hintText: S.of(context).chsadrs,
                                            ),
                                            onChanged: (val) {
                                              ref
                                                  .watch(
                                                    addressIDProvider.notifier,
                                                  )
                                                  .state = val.toString();
                                            },
                                            name: 'address',
                                            items: _.data.data!.addresses!
                                                .map(
                                                  (e) => DropdownMenuItem(
                                                    value: e.id.toString(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 5),
                                                      child: Text(
                                                        AppGFunctions
                                                            .processAdAddess(
                                                          e,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                    error: (_) =>
                                        ErrorTextWidget(error: _.error),
                                  )
                            ],
                          ),
                        ),
                        AppSpacerH(10.h),
                        Container(
                          width: 375.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 15.h,
                          ),
                          decoration: AppBoxDecorations.pageCommonCard,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).instrctn,
                                style: AppTextDecor.osSemiBold18black,
                              ),
                              AppSpacerH(11.h),
                              TextField(
                                controller: _instruction,
                                decoration:
                                    AppInputDecor.loginPageInputDecor.copyWith(
                                  hintText: S.of(context).adinstrctnop,
                                ),
                                maxLines: 3,
                              )
                            ],
                          ),
                        ),
                        AppSpacerH(10.h),
                        Container(
                          width: 375.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 15.h,
                          ),
                          decoration: AppBoxDecorations.pageCommonCard,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).pymntmthd,
                                style: AppTextDecor.osSemiBold18black,
                              ),
                              AppSpacerH(11.h),

                              PaymentMethodCard(
                                onTap: () {
                                  setState(() {
                                    selectedPaymentType = PaymentType.cod;
                                  });
                                },
                                imageLocation: 'assets/images/logo_cod.png',
                                title: S.of(context).cshondlvry,
                                subtitle: S.of(context).pywhndlvry,
                                isSelected:
                                    selectedPaymentType == PaymentType.cod,
                              ),
                              AppSpacerH(11.h),
                              PaymentMethodCard(
                                onTap: () {
                                  setState(() {
                                    selectedPaymentType = PaymentType.Razorpay;
                                  });
                                },
                                imageLocation: 'assets/images/logo_cod.png',
                                title: S.of(context).rzrpay,
                                subtitle: 'Pay Online',
                                isSelected:
                                    selectedPaymentType == PaymentType.Razorpay,
                              ),

//Apply Coupon Code
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text("Coupon")),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: SizedBox(
                                      height: 50,
                                      child: TextField(
                                        controller: couponController,
                                        decoration: new InputDecoration(
                                            border: new OutlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.teal)),
                                            hintText: 'PROMO123',
                                            labelText: 'Apply Coupon',
                                            prefixIcon: const Icon(
                                              Icons.local_offer,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                            //  prefixText: ' ',

                                            suffixStyle: const TextStyle(
                                                color: Colors.green)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      AppColors.goldenButton)),
                                          onPressed: () async {
                                            var amount = await getAmountFinal();
                                            if (couponController.text == "") {
                                              EasyLoading.showError(
                                                "Invalid Coupon",
                                              );
                                            } else {
                                              final params = {
                                                "amount": await getAmountFinal()
                                              };
                                              final res = await postRequest(
                                                  "http://smarttwash.com/api/coupons/" +
                                                      couponController.text +
                                                      "/apply",
                                                  params);
                                              print(res.toString());

                                              if (res["message"] ==
                                                  "Invalid coupon") {
                                                Fluttertoast.showToast(
                                                    msg: "Invalid coupon");
                                                couponController.text = "";
                                                couponAmount = "";
                                                payableAmount = "";
                                                couponId = null;
                                                EasyLoading.showError(
                                                  "Invalid Coupon",
                                                );
                                              } else {
                                                print(res["coupon"].toString());

                                                try {
                                                  if (res["coupon"]["type"] ==
                                                      "percent") {
                                                    print("HERE");

                                                    amount = (((int.parse(res[
                                                                            "coupon"]
                                                                        [
                                                                        "discount"]
                                                                    .toString())) /
                                                                100) *
                                                            double.parse(
                                                                amount))
                                                        .toString();
                                                    print(amount.toString());
                                                    couponAmount =
                                                        amount.toString();
                                                    couponId =
                                                        res["coupon"]["id"];

                                                    payableAmount =
                                                        await getAmountFinal();
                                                    payableAmount = (double.parse(
                                                                payableAmount) -
                                                            double.parse(
                                                                couponAmount))
                                                        .toString();

                                                    print(payableAmount
                                                            .toString() +
                                                        "PAYABLE AMOUNT");
                                                    EasyLoading.showSuccess(
                                                      "Coupon Applied Successfully",
                                                    );
                                                  } else {
                                                    couponAmount = res["coupon"]
                                                            ["discount"]
                                                        .toString();
                                                    couponId =
                                                        res["coupon"]["id"];
                                                    payableAmount = (double
                                                                .parse(amount) -
                                                            double.parse(res[
                                                                            "data"]
                                                                        [
                                                                        "coupon"]
                                                                    ["discount"]
                                                                .toString()))
                                                        .toString();
                                                  }
                                                  EasyLoading.showSuccess(
                                                    "Coupon Applied Successfully",
                                                  );
                                                } catch (stacktrace, error) {
                                                  print(stacktrace.toString());
                                                  print(error.toString());
                                                }
                                              }
                                              setState(() {});
                                            }
                                          },
                                          child: Text(
                                            "Apply",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    ),
                                  )
                                ],
                              ),

                              // AppSpacerH(11.h),
                              // PaymentMethodCard(
                              //   onTap: () {
                              //     setState(() {
                              //       selectedPaymentType =
                              //           PaymentType.onlinePayment;
                              //     });
                              //   },
                              //   imageLocation:
                              //       'assets/images/logo_master_card.png',
                              //   title: S.of(context).mkpymnt,
                              //   subtitle: S.of(context).payonlinewithcard,
                              //   isSelected: selectedPaymentType ==
                              //       PaymentType.onlinePayment,
                              // ),
                            ],
                          ),
                        ),
                        PaymentSection(
                          couponId ?? 0,
                          instruction: _instruction,
                          selectedPaymentType: selectedPaymentType,
                          couponAmount: couponAmount == ""
                              ? "0.0"
                              : double.parse(couponAmount).toStringAsFixed(2),
                          payableAmount: payableAmount,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  var payableAmount = "";

  void applyCouupon() {}

  static Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String res = await prefs
        .getString(
          'bearerToken',
        )
        .toString();

    print(res.toString() + "TOKEN");

    return res;
  }

  static Future<String> getAmountFinal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String res = await prefs
        .getString(
          'amountFinal',
        )
        .toString();

    print(res);

    return res;
  }

  static Future<Map<String, dynamic>> postRequest(String api, Map params,
      {String type = "raw"}) async {
    // var userid = SharedPref.shared.pref?.getInt(PrefKeys.userId);
    // var sCode = SharedPref.shared.pref?.getString(PrefKeys.sCode);
    final url = Uri.parse(api);
    final http.Response res;

    print(api.toString() +
        "-------------------------------- ${params.toString()}");
    var token = await getToken();

    res = await http
        .post(url, body: type == "raw" ? jsonEncode(params) : params, headers: {
      'Content-type': type == "raw"
          ? 'application/json'
          : "application/x-www-form-urlencoded",
      'Authorization': 'Bearer $token',
    });

    // Get.log("userId $userid");
    // Get.log("userId  $sCode");

    final Map<String, dynamic> json = await jsonDecode(res.body);
    return json;
  }
}

enum PaymentType { cod, Razorpay }
