import 'package:dry_cleaners/constants/app_colors.dart';
import 'package:dry_cleaners/constants/input_field_decorations.dart';
import 'package:dry_cleaners/generated/l10n.dart';
import 'package:dry_cleaners/misc/misc_global_variables.dart';
import 'package:dry_cleaners/models/addres_list_model/address.dart';
import 'package:dry_cleaners/providers/address_provider.dart';
import 'package:dry_cleaners/utils/context_less_nav.dart';
import 'package:dry_cleaners/widgets/buttons/full_width_button.dart';
import 'package:dry_cleaners/widgets/misc_widgets.dart';
import 'package:dry_cleaners/widgets/nav_bar.dart';
import 'package:dry_cleaners/widgets/screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

class AddOrEditAddress extends ConsumerStatefulWidget {
  const AddOrEditAddress({
    super.key,
    this.address,
  });
  final Address? address;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddOrEditAddressState();
}

class _AddOrEditAddressState extends ConsumerState<AddOrEditAddress> {
  var latee;
  var longaa;
  final GlobalKey<FormBuilderState> _formkey = GlobalKey<FormBuilderState>();
  TextEditingController addresss = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ref.watch(addAddresProvider);
    ref.watch(updateAddresProvider);

    return ScreenWrapper(
      padding: EdgeInsets.zero,
      child: Container(
        height: 812.h,
        width: 375.w,
        color: AppColors.grayBG,
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
                    title: widget.address == null
                        ? S.of(context).adadres
                        : S.of(context).updtadrs,
                    onBack: () {
                      context.nav.pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formkey,
                  initialValue:
                      widget.address != null ? widget.address!.toMap() : {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        AppSpacerH(20.h),

                        FormBuilderTextField(
                          cursorColor: AppColors.goldenButton,
                          name: 'address_name',
                          decoration:
                              AppInputDecor.loginPageInputDecor.copyWith(
                            hintText: S.of(context).adrsname,
                            prefixIcon: const Icon(Icons.home),
                          ),
                        ),

                        AppSpacerH(20.h),

                        FormBuilderTextField(
                          readOnly: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlacePicker(
                                  // apiKey:"AIzaSyBl2FY2AnfX6NwR4LlOOlT9dDve0VwQLAA",
                                  apiKey:
                                      "AIzaSyCBiZkX5n-WccQRkQ_s3yX3gd_QD7yFlrs",

                                  onPlacePicked: (result) {
                                    print(result.formattedAddress);
                                    setState(() {
                                      addresss.text =
                                          result.formattedAddress.toString();
                                      latee = result.geometry!.location.lat;
                                      longaa = result.geometry!.location.lng;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  initialPosition: LatLng(22.719568, 75.857727),
                                  useCurrentLocation: true,
                                ),
                              ),
                            );
                          },
                          validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required()],
                          ),
                          cursorColor: AppColors.goldenButton,
                          controller: addresss,
                          name: 'area',
                          decoration:
                              AppInputDecor.loginPageInputDecor.copyWith(
                            hintText: S.of(context).areaex,
                            suffixIcon: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlacePicker(
                                        // apiKey:"AIzaSyBl2FY2AnfX6NwR4LlOOlT9dDve0VwQLAA",
                                        apiKey:
                                            "AIzaSyCBiZkX5n-WccQRkQ_s3yX3gd_QD7yFlrs",

                                        onPlacePicked: (result) {
                                          print(result.formattedAddress);
                                          setState(() {
                                            addresss.text = result
                                                .formattedAddress
                                                .toString();
                                            latee =
                                                result.geometry!.location.lat;
                                            longaa =
                                                result.geometry!.location.lng;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        initialPosition:
                                            LatLng(22.719568, 75.857727),
                                        useCurrentLocation: true,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.location_searching_rounded)),
                          ),
                        ),

                        AppSpacerH(20.h),
                        SizedBox(
                          width: 335.w,
                          child: Row(
                            children: [
                              Expanded(
                                child: FormBuilderTextField(
                                  cursorColor: AppColors.goldenButton,
                                  name: 'flat_no',
                                  decoration: AppInputDecor.loginPageInputDecor
                                      .copyWith(
                                    hintText: S.of(context).flat,
                                  ),
                                ),
                              ),
                              AppSpacerW(5.w),
                              Expanded(
                                child: FormBuilderTextField(
                                  cursorColor: AppColors.goldenButton,
                                  name: 'house_no',
                                  decoration: AppInputDecor.loginPageInputDecor
                                      .copyWith(
                                    hintText: S.of(context).houseno,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // AppSpacerH(20.h),
                        // FormBuilderTextField(
                        //   cursorColor: AppColors.goldenButton,
                        //   onTap: () {},
                        //   validator: FormBuilderValidators.compose(
                        //     [FormBuilderValidators.required()],
                        //   ),
                        //   name: 'post_code',
                        //   decoration:
                        //       AppInputDecor.loginPageInputDecor.copyWith(
                        //     hintText: S.of(context).postcode,
                        //   ),
                        // ),
                        AppSpacerH(20.h),
                        FormBuilderTextField(
                          cursorColor: AppColors.goldenButton,
                          // validator: FormBuilderValidators.compose(
                          //   [FormBuilderValidators.required()],
                          // ),
                          name: 'address_line',
                          decoration:
                              AppInputDecor.loginPageInputDecor.copyWith(
                            hintText: S.of(context).adrsline,
                          ),
                        ),
                        AppSpacerH(20.h),
                        FormBuilderTextField(
                          cursorColor: AppColors.goldenButton,
                          name: S.of(context).adrsline_two,
                          decoration:
                              AppInputDecor.loginPageInputDecor.copyWith(
                            hintText: S.of(context).adrsline_two,
                          ),
                        ),
                        AppSpacerH(40.h),
                        if (widget.address == null)
                          SizedBox(
                            height: 50.h,
                            child: ref.watch(addAddresProvider).map(
                                  initial: (_) => AppTextButton(
                                    title: S.of(context).adadres,
                                    onTap: () {
                                      if (_formkey.currentState!
                                          .saveAndValidate()) {
                                        final Map<String, dynamic>
                                            existingData = _formkey
                                                .currentState!
                                                .value; // Assuming this contains the existing map

                                        Map<String, dynamic> newData = {
                                          ...existingData, // Copy the existing data
                                          'latitude':
                                              latee, // Add the new key-value pair
                                          'longitude':
                                              longaa, // Add the new key-value pair
                                        };

                                        ref
                                            .watch(addAddresProvider.notifier)
                                            .addAddress(
                                              address: newData,
                                            );

                                        print('=================${newData}');
                                      }

                                      // if (_formkey.currentState!
                                      //     .saveAndValidate()) {
                                      //   ref
                                      //       .watch(addAddresProvider.notifier)
                                      //       .addAddress(
                                      //         address:
                                      //             _formkey.currentState!.value,
                                      //       );
                                      //
                                      // }
                                    },
                                  ),
                                  loading: (_) => const LoadingWidget(),
                                  loaded: (_) {
                                    Future.delayed(transissionDuration)
                                        .then((value) {
                                      ref.refresh(updateAddresProvider);
                                      ref.refresh(addresListProvider);
                                      ref.refresh(addAddresProvider);
                                      Future.delayed(transissionDuration)
                                          .then((value) {
                                        context.nav.pop();
                                      });
                                    });
                                    return const MessageTextWidget(
                                      msg: 'Success',
                                    );
                                  },
                                  error: (_) {
                                    Future.delayed(transissionDuration)
                                        .then((_) {
                                      ref.refresh(addAddresProvider);
                                      ref.refresh(updateAddresProvider);
                                      ref.refresh(addresListProvider);
                                    });
                                    return ErrorTextWidget(
                                      error: _.error,
                                    );
                                  },
                                ),
                          )
                        else
                          SizedBox(
                            height: 50.h,
                            child: ref.watch(updateAddresProvider).map(
                                  initial: (_) => AppTextButton(
                                    title: S.of(context).updtadrs,
                                    onTap: () {
                                      if (_formkey.currentState!
                                          .saveAndValidate()) {
                                        final Map<String, dynamic>
                                            existingData = _formkey
                                                .currentState!
                                                .value; // Assuming this contains the existing map

                                        Map<String, dynamic> newData = {
                                          ...existingData, // Copy the existing data
                                          'latitude':
                                              latee, // Add the new key-value pair
                                          'longitude':
                                              longaa, // Add the new key-value pair
                                        };
                                        ref
                                            .watch(
                                              updateAddresProvider.notifier,
                                            )
                                            .updateAddress(
                                              address: newData,
                                              addressID: widget.address!.id!
                                                  .toString(),
                                            );
                                      }
                                    },
                                  ),
                                  loading: (_) => const LoadingWidget(),
                                  loaded: (_) {
                                    Future.delayed(transissionDuration)
                                        .then((value) {
                                      ref.refresh(updateAddresProvider);
                                      ref.refresh(addresListProvider);
                                      ref.refresh(addAddresProvider);
                                      Future.delayed(transissionDuration)
                                          .then((value) {
                                        context.nav.pop();
                                      });
                                    });
                                    return const MessageTextWidget(
                                      msg: 'Success',
                                    );
                                  },
                                  error: (_) {
                                    Future.delayed(transissionDuration)
                                        .then((_) {
                                      ref.refresh(addAddresProvider);
                                      ref.refresh(updateAddresProvider);
                                      ref.refresh(addresListProvider);
                                    });
                                    return ErrorTextWidget(
                                      error: _.error,
                                    );
                                  },
                                ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
