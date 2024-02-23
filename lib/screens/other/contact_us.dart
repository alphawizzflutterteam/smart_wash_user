import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dry_cleaners/models/terms_of_service_model/terms_of_service_model.dart';
import 'package:dry_cleaners/utils/context_less_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../widgets/misc_widgets.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/screen_wrapper.dart';

class ContactUs extends StatefulWidget {
  ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  var data;

  Future<void> getFaq() async {
    try {
      var dio = Dio();
      var response = await dio.request(
        'https://smarttwash.com/api/legal-pages/contact-us',
        options: Options(
          method: 'GET',
        ),
      );
      print(response.data.runtimeType);
      if (response.statusCode == 200) {
        data = response.data['data']['setting']['content'];
        print(data);
      } else {
        print(response.statusMessage);
      }
    } catch (e, stackTrace) {
      print(stackTrace);
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      padding: EdgeInsets.zero,
      child: Container(
        height: 812.h,
        width: 375.w,
        color: AppColors.grayBG,
        child: Stack(
          children: [
            SizedBox(
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
                          title: 'Contact Us',
                          onBack: () {
                            context.nav.pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                        future: getFaq(),
                        builder: (context, snap) {
                          return snap.connectionState == ConnectionState.waiting
                              ? const Center(child: LoadingWidget())
                              : SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10.0.h),
                                        child: Html(
                                          style: {
                                            '*': Style(
                                              color: AppColors.navyText,
                                              fontSize: FontSize(14.sp),
                                              fontFamily: 'Open Sans',
                                            )
                                          },
                                          data: data.toString(),
                                        ),
                                      ),
                                      AppSpacerH(60.h)
                                    ],
                                  ),
                                );
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
