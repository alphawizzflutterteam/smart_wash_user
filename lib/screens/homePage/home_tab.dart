import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dry_cleaners/constants/app_colors.dart';
import 'package:dry_cleaners/constants/app_text_decor.dart';
import 'package:dry_cleaners/constants/config.dart';
import 'package:dry_cleaners/constants/hive_contants.dart';
import 'package:dry_cleaners/generated/l10n.dart';
import 'package:dry_cleaners/misc/misc_global_variables.dart';
import 'package:dry_cleaners/models/all_orders_model/order.dart';
import 'package:dry_cleaners/providers/guest_providers.dart';
import 'package:dry_cleaners/providers/misc_providers.dart';
import 'package:dry_cleaners/providers/order_providers.dart';
import 'package:dry_cleaners/providers/profile_update_provider.dart';
import 'package:dry_cleaners/providers/settings_provider.dart';
import 'package:dry_cleaners/screens/homePage/tab_profile_unsigned.dart';
import 'package:dry_cleaners/screens/order/my_order_home_tile.dart';
import 'package:dry_cleaners/utils/context_less_nav.dart';
import 'package:dry_cleaners/utils/routes.dart';
import 'package:dry_cleaners/widgets/home_tab_card.dart';
import 'package:dry_cleaners/widgets/misc_widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../models/getServicesModel.dart';
import '../../models/getfrenchModel.dart';
import '../../models/mm.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  late VideoPlayerController _controller;

  List postCodelist = [];

  Future<void> openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    await launch(url);
  }

  var videeeo;
  late Future my;
  @override
  void initState() {
    super.initState();
    callAPi();
  }

  callAPi() {
    print('init of Home PAGE');

    getUserCurrentLocation();

    getvideo();

    setupFirebaseMessaging();
  }

  var tokenn;
  var tokentype;
  Future<void> getvideo() async {
    tokenn = Hive.box(AppHSC.authBox);

    if (tokenn!.get(AppHSC.authToken) != null &&
        tokenn!.get(AppHSC.authToken) != '') {}
    final String token = tokenn!.get(AppHSC.authToken) as String;
    final String tokenType = tokenn!.get(AppHSC.authTokenType) as String;

    var headers = {
      'Authorization': '$tokenType $token',
    };
    var request = http.Request('GET', Uri.parse('${AppConfig.baseUrl}/video'));

    print("=============${request.body}");
    print("=============${request.url}");
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print(result);
      var finalresult = jsonDecode(result);

      videeeo = finalresult['data']['descritption'].toString();

      print("===my technic==api video=====${videeeo}===============");

      print("===my technic======video if======${videeeo}======");

      _controller =
          await VideoPlayerController.networkUrl(Uri.parse(videeeo.toString()))
            ..initialize().then((_) {
              setState(() {
                print("Initialized");
              });
            });
    } else {
      print(response.reasonPhrase);
    }
  }

  var latitude;
  var longitude;

  Position? currentLocation;

  Future getUserCurrentLocation() async {
    print('test');

    var status = await Permission.location.request();
    if (status.isDenied) {
    } else if (status.isGranted) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((position) {
        if (mounted)
          setState(() {
            currentLocation = position;
            latitude = currentLocation?.latitude;
            longitude = currentLocation?.longitude;
            print('long==============${longitude}');
            print('lat==============${latitude}');
          });
      });
      print("LOCATION===" + currentLocation.toString());
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    // getOutlet();
  }

  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ref.refresh(allOrdersProvider);
    });
  }

  Directory? dir;
  downloadBanner({required String url, required String descritption}) async {
    Dio dio = Dio();
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        String fileName = url.toString().split('/').last;
        print("FileName: $fileName");
        dir = Directory('/storage/emulated/0/Download/'); // for android
        if (!await dir!.exists()) dir = await getExternalStorageDirectory();
        String path = "${dir?.path}$fileName";
        await dio.download(
          url.toString(),
          path,
          onReceiveProgress: (recivedBytes, totalBytes) {
            print(recivedBytes);
          },
          deleteOnError: true,
        ).then((value) async =>
            await Share.shareXFiles([XFile(path)], text: descritption));
      }
    } catch (e, stackTrace) {
      print(stackTrace);
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileInfoProvider);

    ref.watch(settingsProvider).maybeWhen(
          orElse: () {},
          loaded: (_) {
            postCodelist = _.data?.postCode ?? [];
          },
        );
    //ref.watch(allServicesProvider());
    //ref.watch(allServicesProvider('${outletid.toString()}'));
    // ref.watch(allOutletProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 2));
        callAPi();
      },
      child: SizedBox(
        height: 812.h,
        width: 375.w,
        child: ValueListenableBuilder(
          valueListenable: Hive.box(AppHSC.authBox).listenable(),
          builder: (context, Box authBox, Widget? child) {
            return ValueListenableBuilder(
              valueListenable: Hive.box(AppHSC.userBox).listenable(),
              builder: (context, Box box, Widget? child) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.h),
                        bottomRight: Radius.circular(20.h),
                      ),
                      child: Container(
                        color: AppColors.white,
                        width: 375.w,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSpacerH(44.h),
                            SizedBox(
                              height: 48.h,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/icon_wave.png',
                                    height: 48.h,
                                    width: 48.w,
                                  ),
                                  AppSpacerW(15.w),
                                  // if (authBox.get('token') != null)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.of(context).hello,
                                        style: AppTextDecor.osRegular12black,
                                        textAlign: TextAlign.start,
                                      ),
                                      Expanded(
                                        child: Text(
                                          authBox.get('token') != null
                                              ? '${box.get('name')}'
                                              : S.of(context).plslgin,
                                          style: AppTextDecor.osBold20Black,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      // Text(
                                      //   address,
                                      //   style: AppTextDecor.osRegular14white,
                                      // )
                                    ],
                                  ),
                                  const Expanded(child: SizedBox()),
                                  if (authBox.get('token') != null)
                                    Container(
                                      // padding: const EdgeInsets.all(1),
                                      width: 39.h,
                                      height: 39.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.gray,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(19.r),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          print("object");
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UsignedUserTab(),
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(18.r),
                                          child: CachedNetworkImage(
                                            imageUrl: box
                                                .get('profile_photo_path')
                                                .toString(),
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () {
                                        context.nav.pushNamed(
                                          Routes.loginScreen,
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        "assets/svgs/icon_home_login.svg",
                                        width: 39.h,
                                        height: 39.h,
                                      ),
                                    )
                                ],
                              ),
                            ),
                            AppSpacerH(20.h),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          AppSpacerH(20.h),
                          SizedBox(
                            width: 375.w,
                            height: 170.h,
                            child: Consumer(
                              builder: (context, ref, child) {
                                return ref.watch(allPromotionsProvider).map(
                                      initial: (_) => const SizedBox(),
                                      loading: (_) => const LoadingWidget(
                                        showBG: true,
                                      ),
                                      loaded: (_) => CarouselSlider(
                                        options: CarouselOptions(
                                          height: 170.0.h,
                                          viewportFraction: 0.95,
                                        ),
                                        items: _.data.data!.promotions!
                                            .map(
                                              (e) => GestureDetector(
                                                onTap: () {
                                                  downloadBanner(
                                                      url: e.imagePath
                                                          .toString(),
                                                      descritption: e
                                                          .description
                                                          .toString());
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 9.w,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10.w,
                                                    ),
                                                    child: Container(
                                                      color: AppColors.white,
                                                      width: 355.w,
                                                      child: Image.network(
                                                        e.imagePath!,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      error: (_) =>
                                          ErrorTextWidget(error: _.error),
                                    );
                              },
                            ),
                          ),
                          AppSpacerH(32.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OutletScreen(
                                              lat: latitude.toString(),
                                              lang: longitude.toString()),
                                        ));
                                  },
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(15),
                                        color: AppColors.gold),
                                    child: const Center(
                                        child: Text(
                                      'Order Now',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),

                                // oyt let view commented
                                //
                                //                               Text(
                                //                                 S.of(context).getoutlet,
                                //                                 style: AppTextDecor.osBold24black,
                                //                               ),
                                //
                                //                               // Text(
                                //                               //   S.of(context).srvctgrs,
                                //                               //   style: AppTextDecor.osBold24black,
                                //                               // ),
                                //
                                //                               AppSpacerH(12.h),
                                //
                                //                               getOutletModel?.data?.outlets == null ||
                                //                                       getOutletModel?.data?.outlets == ''
                                //                                   ? Container(
                                //                                       height: 100,
                                //                                       child: Center(
                                //                                           child: CircularProgressIndicator()),
                                //                                     )
                                //                                   : getOutletModel!.data!.outlets!.isEmpty ||
                                //                                           getOutletModel!
                                //                                                   .data!.outlets!.isEmpty ==
                                //                                               []
                                //                                       ? Container(
                                //                                           height: 100,
                                //                                           child: Center(
                                //                                             child: Text(
                                //                                               S.of(context).getnoOutLet,
                                //                                               style:
                                //                                                   AppTextDecor.osRegular14black,
                                //                                             ),
                                //                                           ))
                                //                                       : Container(
                                //                                           height: 240,
                                //                                           child: ListView.builder(
                                //                                             scrollDirection: Axis.horizontal,
                                //                                             physics:
                                //                                                 AlwaysScrollableScrollPhysics(),
                                //                                             shrinkWrap: true,
                                //
                                //                                             //itemCount:outletList.length,
                                //                                             itemCount: getOutletModel
                                //                                                     ?.data?.outlets?.length ??
                                //                                                 0,
                                //                                             itemBuilder: (context, index) {
                                //                                               return Card(
                                //                                                 child: Container(
                                //                                                   width: 110,
                                //                                                   child: Padding(
                                //                                                     padding:
                                //                                                         const EdgeInsets.all(
                                //                                                             5.0),
                                //                                                     child: Column(
                                //                                                       children: [
                                //
                                //                                                         InkWell(
                                //                                                           onTap: () {
                                //
                                //                                                             print(
                                //                                                                 "token========================${authBox.get('token')}");
                                //
                                //                                                             print(
                                //                                                                 "OUT LET ID===============${getOutletModel?.data?.outlets?[index].id}");
                                //
                                //                                                             setState(()  {
                                //                                                               outletid =
                                //                                                                   '${getOutletModel?.data?.outlets?[index].id}';
                                //
                                //
                                //                                                             });
                                //
                                //
                                //                                                             Navigator.push(
                                //                                                                 context,
                                //                                                                 MaterialPageRoute(
                                //                                                                   builder: (context) =>
                                //                                                                       Servicess(
                                //                                                                           venderId:
                                //                                                                               outletid.toString(),
                                //
                                //                                                                       ),
                                //                                                                 ));
                                //
                                //                                                             },
                                //                                                           child: Column(
                                //                                                               children: [
                                //                                                                 Container(
                                //                                                                   height: 70,
                                //                                                                   //decoration: BoxDecoration(image: DecorationImage(image: AssetImage('${outletList[index]['image']}'),fit: BoxFit.fill)),
                                //                                                                   decoration: BoxDecoration(
                                //                                                                       image: DecorationImage(
                                //                                                                           image: NetworkImage(
                                //                                                                               '${getOutletModel?.data?.outlets?[index].profilePhotoId}'),
                                //                                                                           fit: BoxFit
                                //                                                                               .fill)),
                                //                                                                 ),
                                //
                                //                                                                 SizedBox(
                                //                                                                   height: 10,
                                //                                                                 ),
                                //
                                //
                                //                                                                 Row(
                                //                                                                   children: [
                                //                                                                     Text(
                                //                                                                       'Name',
                                //                                                                       style: TextStyle(
                                //                                                                           fontSize:
                                //                                                                               10,
                                //                                                                           fontWeight:
                                //                                                                               FontWeight.bold),
                                //                                                                     ),
                                //                                                                   ],
                                //                                                                 ),
                                //                                                                 Row(
                                //                                                                   children: [
                                //                                                                     SizedBox(
                                //                                                                         width:
                                //                                                                             100,
                                //
                                //                                                                         //child: Text('Address: ${outletList[index]['address']}',style: TextStyle(fontSize: 10),)),
                                //                                                                         child:
                                //                                                                             Text(
                                //                                                                           '${getOutletModel?.data?.outlets?[index].name}',
                                //                                                                           overflow:
                                //                                                                               TextOverflow.ellipsis,
                                //                                                                           maxLines:
                                //                                                                               1,
                                //                                                                           style:
                                //                                                                               TextStyle(fontSize: 10),
                                //                                                                         )),
                                //                                                                   ],
                                //                                                                 ),
                                //                                                                 SizedBox(
                                //                                                                   height: 10,
                                //                                                                 ),
                                //                                                               ]),
                                //                                                         ),
                                //
                                //
                                //                                                         InkWell(
                                //                                                           onTap: () {
                                //                                                             openMap(
                                //                                                                 '${getOutletModel?.data?.outlets?[index].address}');
                                //                                                           },
                                //                                                           child: Column(
                                //                                                             children: [
                                //                                                               Row(
                                //                                                                 children: [
                                //
                                //
                                //                                                                   Text(
                                //                                                                     'Address',
                                //                                                                     style: TextStyle(
                                //                                                                         fontSize:
                                //                                                                             10,
                                //                                                                         fontWeight:
                                //                                                                             FontWeight.bold),
                                //                                                                   ),
                                //
                                //                                                                   Icon(
                                //                                                                     Icons
                                //                                                                         .location_on,
                                //                                                                     color: AppColors
                                //                                                                         .black,size: 15,
                                //                                                                   ),
                                //
                                //                                                                 ],
                                //                                                               ),
                                //                                                               Row(
                                //                                                                 children: [
                                //                                                                   SizedBox(
                                //                                                                       width:
                                //                                                                           100,
                                //
                                //                                                                       //child: Text('Address: ${outletList[index]['address']}',style: TextStyle(fontSize: 10),)),
                                //
                                //                                                                       child:
                                //                                                                           Text(
                                //                                                                         '${getOutletModel?.data?.outlets?[index].address}' ??
                                //                                                                             "",
                                //                                                                         overflow:
                                //                                                                             TextOverflow.ellipsis,
                                //                                                                         maxLines:
                                //                                                                             1,
                                //                                                                         style: TextStyle(
                                //                                                                             fontSize:
                                //                                                                                 10),
                                //                                                                       )),
                                //                                                                 ],
                                //                                                               ),
                                //                                                               SizedBox(
                                //                                                                 height: 5,
                                //                                                               ),
                                //                                                               // Row(
                                //                                                               //   children: [
                                //                                                               //     Spacer(),
                                //                                                               //     Icon(
                                //                                                               //       Icons
                                //                                                               //           .location_on,
                                //                                                               //       color: AppColors
                                //                                                               //           .black,
                                //                                                               //     ),
                                //                                                               //   ],
                                //                                                               // ),
                                //                                                             ],
                                //                                                           ),
                                //                                                         ),
                                //
                                //
                                // SizedBox(height: 5,),
                                //
                                //                                                         InkWell(
                                //                                                           onTap: () {
                                //
                                //
                                //
                                //                                                             print(
                                //                                                                 "token========================${authBox.get('token')}");
                                //                                                             print(
                                //                                                                 "OUTLET ID===============${getOutletModel?.data?.outlets?[index].id}");
                                //
                                //                                                             setState(() {
                                //                                                               //outletid='${outletList[index]['id']}';
                                //                                                               outletid =
                                //                                                               '${getOutletModel?.data?.outlets?[index].id}';
                                //                                                             });
                                // //print("===============${outletList[index]['id']}");
                                //
                                //
                                //                                                             Navigator.push(
                                //                                                                 context,
                                //                                                                 MaterialPageRoute(
                                //                                                                   builder: (context) =>
                                //                                                                       Frenchies(
                                //                                                                           venderId:
                                //                                                                           outletid.toString()),
                                //                                                                 ));
                                //
                                //
                                //
                                //
                                //
                                //                                                             },
                                //                                                           child: Column(
                                //                                                             children: [
                                //                                                               Row(
                                //                                                                 children: [
                                //                                                                   Text(
                                //                                                                     'Near By',
                                //                                                                     style: TextStyle(
                                //                                                                         fontSize:
                                //                                                                         10,
                                //                                                                         fontWeight:
                                //                                                                         FontWeight.bold),
                                //                                                                   ),
                                //                                                                 ],
                                //                                                               ),
                                //
                                //
                                //                                                             ],
                                //                                                           ),
                                //                                                         ),
                                //
                                // SizedBox(height: 10,),
                                //
                                //                                                         InkWell(
                                //                                                           onTap: () {
                                //
                                //                                                             print(
                                //                                                                 "token========================${authBox.get('token')}");
                                //
                                //                                                             print(
                                //                                                                 "OUT LET ID===============${getOutletModel?.data?.outlets?[index].id}");
                                //
                                //                                                             setState(()  {
                                //                                                               outletid =
                                //                                                               '${getOutletModel?.data?.outlets?[index].id}';
                                //
                                //
                                //                                                             });
                                //
                                //
                                //                                                             Navigator.push(
                                //                                                                 context,
                                //                                                                 MaterialPageRoute(
                                //                                                                   builder: (context) =>
                                //                                                                       Servicess(
                                //                                                                         venderId:
                                //                                                                         outletid.toString(),
                                //
                                //                                                                       ),
                                //                                                                 ));
                                //
                                //
                                //                                                           },
                                //                                                           child: Container(
                                //
                                //                                                             height: 30,
                                //                                                             decoration: BoxDecoration(border: Border.all( )),
                                //                                                             child: Center(child: Text('Order Now',style: TextStyle(
                                //                                                               fontSize:
                                //                                                               10,
                                //                                                               fontWeight:
                                //                                                               FontWeight.bold),),),),
                                //                                                         ),
                                //
                                //                                                         SizedBox(
                                //                                                           height: 5,
                                //                                                         ),
                                //
                                //
                                //                                                       ],
                                //                                                     ),
                                //                                                   ),
                                //                                                 ),
                                //                                               );
                                //                                             },
                                //                                           ),
                                //                                         ),
                                //
                                //
                                //
                                //
                                //
                                AppSpacerH(32.h),
                                videeeo == null || videeeo == ""
                                    ? SizedBox()
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            _controller.value.isPlaying
                                                ? _controller.pause()
                                                : _controller.play();
                                          });
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 180,
                                            color: Colors.white70,
                                            child: _controller
                                                    .value.isInitialized
                                                ? Stack(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 180,
                                                        color: Colors.white70,
                                                        child: Center(
                                                          child: _controller
                                                                  .value
                                                                  .isInitialized
                                                              ? AspectRatio(
                                                                  aspectRatio:
                                                                      _controller
                                                                          .value
                                                                          .aspectRatio,
                                                                  child: VideoPlayer(
                                                                      _controller),
                                                                )
                                                              : Container(),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 5,
                                                        left: 20,
                                                        child: Icon(
                                                          _controller.value
                                                                  .isPlaying
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                          size: 35,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Center(
                                                    child:
                                                        CircularProgressIndicator())),
                                      ),
                                // ref.watch(allServicesProvider).map(
                                //       initial: (_) => const SizedBox(),
                                //       loading: (_) => const LoadingWidget(
                                //         showBG: true,
                                //       ),
                                //
                                //       loaded: (_) {
                                //         if (_.data.data!.services!.isNotEmpty) {
                                //           final widgets = _.data.data!.services!
                                //               .asMap()
                                //               .entries
                                //               .map(
                                //                 (entry) => Padding(
                                //                   padding: EdgeInsets.only(
                                //                     right: Hive.box(
                                //                               AppHSC
                                //                                   .appSettingsBox,
                                //                             )
                                //                                 .get(
                                //                                   AppHSC.appLocal,
                                //                                 )
                                //                                 .toString() ==
                                //                             "en"
                                //                         ? 20.w
                                //                         : 0.w,
                                //                     left: Hive.box(
                                //                               AppHSC
                                //                                   .appSettingsBox,
                                //                             )
                                //                                 .get(
                                //                                   AppHSC.appLocal,
                                //                                 )
                                //                                 .toString() ==
                                //                             "en"
                                //                         ? 0.w
                                //                         : 20.w,
                                //                   ),
                                //                   child: HomeTabCard(
                                //                     service: entry.value,
                                //                     ontap: () {
                                //
                                //
                                //                       ref.refresh(
                                //                         servicesVariationsProvider(
                                //                           entry.value.id
                                //                               .toString(),
                                //                         ),
                                //                       );
                                //                       ref.refresh(
                                //                         productsFilterProvider,
                                //                       );
                                //                       ref
                                //                           .watch(
                                //                             itemSelectMenuIndexProvider
                                //                                 .notifier,
                                //                           )
                                //                           .state = 0;
                                //
                                //                       context.nav.pushNamed(
                                //                         Routes.chooseItemScreen,
                                //                         arguments: entry.value,
                                //                       );
                                //
                                //
                                //                     },
                                //                   ),
                                //                 ),
                                //               )
                                //               .toList();
                                //           if (authBox.get(AppHSC.authToken) !=
                                //                   null &&
                                //               authBox.get(AppHSC.authToken) !=
                                //                   '') {
                                //             return SizedBox(
                                //               height: 112.h,
                                //               child: ListView(
                                //                 scrollDirection: Axis.horizontal,
                                //                 children: widgets,
                                //               ),
                                //             );
                                //           } else {
                                //             return GridView.count(
                                //               shrinkWrap: true,
                                //               crossAxisSpacing: 16.w,
                                //               mainAxisSpacing: 16.h,
                                //               physics:
                                //                   const NeverScrollableScrollPhysics(),
                                //               crossAxisCount: 3,
                                //               children: widgets,
                                //             );
                                //           }
                                //         } else {
                                //           return MessageTextWidget(
                                //             msg: S.of(context).nosrvcavlbl,
                                //           );
                                //         }
                                //       },
                                //
                                //
                                //       error: (_) =>
                                //           ErrorTextWidget(error: _.error),
                                //     ),
                                //
                                //

                                if (authBox.get('token') != null)
                                  ...ref.watch(allOrdersProvider).map(
                                        initial: (_) => [const SizedBox()],
                                        loading: (_) => [const LoadingWidget()],
                                        loaded: (_) {
                                          if (_.data.data!.orders!.isEmpty) {
                                            return [
                                              // AppSpacerH(100.h),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              MessageTextWidget(
                                                msg: S.of(context).noordrfnd,
                                              )
                                            ];
                                          } else {
                                            return [
                                              AppSpacerH(32.h),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(S.of(context).actvordr,
                                                      style: AppTextDecor
                                                          .osBold24black),
                                                  GestureDetector(
                                                    onTap: () {
                                                      ref
                                                          .watch(
                                                            homeScreenIndexProvider
                                                                .notifier,
                                                          )
                                                          .state = 1;
                                                      ref
                                                          .watch(
                                                            homeScreenPageControllerProvider,
                                                          )
                                                          .animateToPage(
                                                            1,
                                                            duration:
                                                                transissionDuration,
                                                            curve: Curves
                                                                .easeInOut,
                                                          );
                                                    },
                                                    child: Text(
                                                        S.of(context).vewall,
                                                        style: AppTextDecor
                                                            .osBold12gold),
                                                  ),
                                                ],
                                              ),
                                              AppSpacerH(16.h),
                                              ..._.data.data!.orders!
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                (entry) {
                                                  final int index = entry.key;
                                                  final Order data =
                                                      entry.value;

                                                  return Column(
                                                    children: [
                                                      HomeOrderTile(data: data),
                                                      if (index ==
                                                          _.data.data!.orders!
                                                                  .length -
                                                              1) // Check if it's the last widget
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            bottom: 60.h,
                                                          ), // Add desired padding
                                                        ),
                                                    ],
                                                  );
                                                },
                                              ).toList()
                                            ];
                                          }
                                        },
                                        error: (_) =>
                                            [ErrorTextWidget(error: _.error)],
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 70,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  GetFrenchModel? getFrenchModel;

  Future<void> getfrench(String outlet) async {
    print("=============get french model");
    var request = http.MultipartRequest(
        'POST', Uri.parse('${AppConfig.baseUrl}/get-franchiese'));
    request.fields.addAll({
      'vendor_id': outlet.toString(),
    });
    print(request.fields);
    print(request.url);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalresult = jsonDecode(result);
      if (finalresult['message'] == "Franchise") {
        var finalresult1 =
            GetFrenchModel.fromJson(finalresult as Map<String, dynamic>);

        setState(() {
          getFrenchModel = finalresult1;
          print('=================${getFrenchModel?.data.franchise?.length}');
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  List<String> images = [
    'assets/images/dim_00.png',
    'assets/images/dim_01.png',
    'assets/images/dim_02.png'
  ];

  GetOutletModel? getOutletModel;

  Future<void> getOutlet() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            "${AppConfig.baseUrl}/get-outlate?lat=${latitude.toString()}&lang=${longitude.toString()}"));

    http.StreamedResponse response = await request.send();
    print('getoutlet requst=============${request.url}=');

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalresult = GetOutletModel.fromJson(jsonDecode(result));

      print("rrrrrrrrrrrr");

      setState(() {
        getOutletModel = finalresult;
      });
    } else {
      print(response.reasonPhrase);
    }
  }
}

//other class

class OutletScreen extends StatefulWidget {
  String? lat;
  String? lang;
  OutletScreen({Key? key, this.lat, this.lang}) : super(key: key);

  @override
  State<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends State<OutletScreen> {
  TextEditingController searchController = TextEditingController();
  var latee;
  var longaa;

  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState

    print('lat===================${widget.lat}');
    print('lang===================${widget.lang}');
    setState(() {
      latee = widget.lat;
      longaa = widget.lang;
    });
    getOutlet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Outlets'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(children: [
            TextField(
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlacePicker(
                      // apiKey:"AIzaSyBl2FY2AnfX6NwR4LlOOlT9dDve0VwQLAA",
                      apiKey: "AIzaSyDPsdTq-a4AHYHSNvQsdAlZgWvRu11T9pM",

                      onPlacePicked: (result) {
                        print(result.formattedAddress);
                        setState(() {
                          searchController.text =
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
                ).then((value) {
                  getOutlet();
                });
              },
              controller: searchController,
              decoration: InputDecoration(
                  hintText: 'Please Enter Location',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(), //<-- SEE HERE
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 30,
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  'Outlets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            loading
                ? Container(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : getOutletModel!.data!.outlets!.isEmpty
                    ? Container(
                        height: 100,
                        child: Center(
                          child: Text(
                            S.of(context).getnoOutLet,
                            style: AppTextDecor.osRegular14black,
                          ),
                        ))
                    : Container(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,

                          //itemCount:outletList.length,
                          itemCount: getOutletModel?.data?.outlets?.length ?? 0,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Container(
                                width: 110,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // print(
                                          //     "token========================${authBox.get('token')}");

                                          print(
                                              "OUT LET ID===============${getOutletModel?.data?.outlets?[index].id}");

                                          setState(() {
                                            outletid =
                                                '${getOutletModel?.data?.outlets?[index].id}';
                                          });

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Servicess(
                                                  venderId: outletid.toString(),
                                                ),
                                              ));
                                        },
                                        child: Column(children: [
                                          Container(
                                            height: 70,
                                            //decoration: BoxDecoration(image: DecorationImage(image: AssetImage('${outletList[index]['image']}'),fit: BoxFit.fill)),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        '${getOutletModel?.data?.outlets?[index].profilePhotoId}'),
                                                    fit: BoxFit.fill)),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Name',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                  width: 100,

                                                  //child: Text('Address: ${outletList[index]['address']}',style: TextStyle(fontSize: 10),)),
                                                  child: Text(
                                                    '${getOutletModel?.data?.outlets?[index].name}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style:
                                                        TextStyle(fontSize: 10),
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          openMap(
                                              '${getOutletModel?.data?.outlets?[index].address}');
                                        },
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Address',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Icon(
                                                  Icons.location_on,
                                                  color: AppColors.black,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                    width: 100,

                                                    //child: Text('Address: ${outletList[index]['address']}',style: TextStyle(fontSize: 10),)),

                                                    child: Text(
                                                      '${getOutletModel?.data?.outlets?[index].address}' ??
                                                          "",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    )),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Spacer(),
                                            //     Icon(
                                            //       Icons
                                            //           .location_on,
                                            //       color: AppColors
                                            //           .black,
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // print(
                                          //     "token========================${authBox.get('token')}");
                                          print(
                                              "OUTLET ID===============${getOutletModel?.data?.outlets?[index].id}");

                                          setState(() {
                                            //outletid='${outletList[index]['id']}';
                                            outletid =
                                                '${getOutletModel?.data?.outlets?[index].id}';
                                          });
//print("===============${outletList[index]['id']}");

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Frenchies(
                                                    venderId:
                                                        outletid.toString()),
                                              ));
                                        },
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Near By',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // print(
                                          //     "token========================${authBox.get('token')}");

                                          print(
                                              "OUT LET ID===============${getOutletModel?.data?.outlets?[index].id}");

                                          setState(() {
                                            outletid =
                                                '${getOutletModel?.data?.outlets?[index].id}';
                                          });

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Servicess(
                                                  venderId: outletid.toString(),
                                                ),
                                              ));
                                        },
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                              border: Border.all()),
                                          child: Center(
                                            child: Text(
                                              'Order Now',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ]),
        ),
      ),
    );
  }

  Future<void> openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    await launch(url);
  }

  GetOutletModel? getOutletModel;

  void searchOutletApi() {}

  Future<void> getOutlet() async {
    loading = true;
    setState(() {});
    var request = http.Request(
        'GET',
        Uri.parse(
            "${AppConfig.baseUrl}/get-outlate?lat=${latee.toString()}&lang=${longaa.toString()}"));

    http.StreamedResponse response = await request.send();
    print('getoutlet requst=============${request.url}=');

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalresult = GetOutletModel.fromJson(jsonDecode(result));

      log(finalresult.toJson().toString());

      setState(() {
        getOutletModel = finalresult;
        loading = false;
      });
    } else {
      loading = false;

      setState(() {});
      print(response.reasonPhrase);
    }
  }
}

//other class

class Servicess extends ConsumerStatefulWidget {
  String? venderId;
  String? frenchId;
  Servicess({super.key, this.venderId, this.frenchId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServicessState();
}

class _ServicessState extends ConsumerState<Servicess> {
  @override
  void initState() {
    // TODO: implement initState

    print('venderId============${widget.venderId.toString()}');
    print('frenchId============${widget.frenchId.toString()}');

    if (widget.frenchId.toString() == 'null') {
      setState(() {
        frenchId = 0;
      });

      print('french Id null case=======================${frenchId}');
    }
  }

  List postCodelist = [];
  @override
  @override
  Widget build(BuildContext context) {
    ref.watch(profileInfoProvider);
    ref.watch(settingsProvider).maybeWhen(
          orElse: () {},
          loaded: (_) {
            postCodelist = _.data?.postCode ?? [];
          },
        );

    ref.watch(allServicesProvider('${widget.venderId.toString()}'));
    // ref.watch(allOutletProvider);

    return SizedBox(
      height: 812.h,
      width: 375.w,
      child: ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.authBox).listenable(),
        builder: (context, Box authBox, Widget? child) {
          return ValueListenableBuilder(
            valueListenable: Hive.box(AppHSC.userBox).listenable(),
            builder: (context, Box box, Widget? child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.h),
                      bottomRight: Radius.circular(20.h),
                    ),
                    child: Container(
                      color: AppColors.white,
                      width: 375.w,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSpacerH(44.h),
                          SizedBox(
                            height: 48.h,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/icon_wave.png',
                                  height: 48.h,
                                  width: 48.w,
                                ),
                                AppSpacerW(15.w),
                                // if (authBox.get('token') != null)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      S.of(context).hello,
                                      style: AppTextDecor.osRegular12black,
                                      textAlign: TextAlign.start,
                                    ),
                                    Expanded(
                                      child: Text(
                                        authBox.get('token') != null
                                            ? '${box.get('name')}'
                                            : S.of(context).plslgin,
                                        style: AppTextDecor.osBold20Black,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    // Text(
                                    //   address,
                                    //   style: AppTextDecor.osRegular14white,
                                    // )
                                  ],
                                ),
                                const Expanded(child: SizedBox()),
                                if (authBox.get('token') != null)
                                  Container(
                                    // padding: const EdgeInsets.all(1),
                                    width: 39.h,
                                    height: 39.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.gray,
                                      ),
                                      borderRadius: BorderRadius.circular(19.r),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18.r),
                                      child: CachedNetworkImage(
                                        imageUrl: box
                                            .get('profile_photo_path')
                                            .toString(),
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      context.nav.pushNamed(
                                        Routes.loginScreen,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      "assets/svgs/icon_home_login.svg",
                                      width: 39.h,
                                      height: 39.h,
                                    ),
                                  )
                              ],
                            ),
                          ),
                          AppSpacerH(20.h),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        AppSpacerH(20.h),
                        AppSpacerH(32.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).srvctgrs,
                                style: AppTextDecor.osBold24black,
                              ),
                              AppSpacerH(12.h),
                              ref
                                  .watch(allServicesProvider(
                                      widget.venderId.toString()))
                                  .map(
                                    initial: (_) => const SizedBox(),
                                    loading: (_) => const LoadingWidget(
                                      showBG: true,
                                    ),
                                    loaded: (_) {
                                      if (_.data.data!.services!.isNotEmpty) {
                                        final widgets = _.data.data!.services!
                                            .asMap()
                                            .entries
                                            .map(
                                              (entry) => Padding(
                                                padding: EdgeInsets.only(
                                                  right: Hive.box(
                                                            AppHSC
                                                                .appSettingsBox,
                                                          )
                                                              .get(
                                                                AppHSC.appLocal,
                                                              )
                                                              .toString() ==
                                                          "en"
                                                      ? 20.w
                                                      : 0.w,
                                                  left: Hive.box(
                                                            AppHSC
                                                                .appSettingsBox,
                                                          )
                                                              .get(
                                                                AppHSC.appLocal,
                                                              )
                                                              .toString() ==
                                                          "en"
                                                      ? 0.w
                                                      : 20.w,
                                                ),
                                                child: HomeTabCard(
                                                  service: entry.value,
                                                  ontap: () {
                                                    print(
                                                        "==============ggggtab");

                                                    ref.refresh(
                                                      servicesVariationsProvider(
                                                        entry.value.id
                                                            .toString(),
                                                      ),
                                                    );
                                                    ref.refresh(
                                                      productsFilterProvider,
                                                    );
                                                    ref
                                                        .watch(
                                                          itemSelectMenuIndexProvider
                                                              .notifier,
                                                        )
                                                        .state = 0;
                                                    entry.value.vid = widget
                                                        .venderId
                                                        .toString();
                                                    print(
                                                        "Entry: ${entry.value}");
                                                    context.nav.pushNamed(
                                                      Routes.chooseItemScreen,
                                                      //arguments: [entry.value,widget.frenchId,widget.venderId],
                                                      arguments: entry.value,
                                                    );
                                                    // Navigator.push(context, MaterialPageRoute(builder: ChooseItems(service:entry.value ,VenderId: widget.venderId,frenchId: widget.frenchId,)));
                                                  },
                                                ),
                                              ),
                                            )
                                            .toList();
                                        if (authBox.get(AppHSC.authToken) !=
                                                null &&
                                            authBox.get(AppHSC.authToken) !=
                                                '') {
                                          return SizedBox(
                                            height: 112.h,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: widgets,
                                            ),
                                          );
                                        } else {
                                          return GridView.count(
                                            shrinkWrap: true,
                                            crossAxisSpacing: 16.w,
                                            mainAxisSpacing: 16.h,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            crossAxisCount: 3,
                                            children: widgets,
                                          );
                                        }
                                      } else {
                                        return MessageTextWidget(
                                          msg: S.of(context).nosrvcavlbl,
                                        );
                                      }
                                    },
                                    error: (_) =>
                                        ErrorTextWidget(error: _.error),
                                  ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  GetServicesModel? getServicesModel;
  Future<void> getcat() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            '${AppConfig.baseUrl}/services?vendore_id=${widget.venderId}'));

    http.StreamedResponse response = await request.send();
    print("===my technic=======${request.url}===============");
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult =
          GetServicesModel.fromJson(jsonDecode(result) as Map<String, dynamic>);
      setState(() {
        getServicesModel = finalResult;
        print("${getServicesModel?.data?.services?.length}");
        print("raj233333333333333333");
      });
    } else {
      print(response.reasonPhrase);
    }
  }
}

var outletid;
var frenchId;

class Frenchies extends ConsumerStatefulWidget {
  String? venderId;
  Frenchies({super.key, this.venderId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FrenchiesState();
}

class _FrenchiesState extends ConsumerState<Frenchies> {
  List postCodelist = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.venderId);
    getfrench();
  }

  @override
  @override
  Widget build(BuildContext context) {
    ref.watch(profileInfoProvider);
    ref.watch(settingsProvider).maybeWhen(
          orElse: () {},
          loaded: (_) {
            postCodelist = _.data?.postCode ?? [];
          },
        );

    ref.watch(allServicesProvider('${widget.venderId.toString()}'));
    // ref.watch(allOutletProvider);

    return SizedBox(
      height: 812.h,
      width: 375.w,
      child: ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.authBox).listenable(),
        builder: (context, Box authBox, Widget? child) {
          return ValueListenableBuilder(
            valueListenable: Hive.box(AppHSC.userBox).listenable(),
            builder: (context, Box box, Widget? child) {
              return getFrenchModel?.data == null || getFrenchModel?.data == ''
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: CircularProgressIndicator()))
                  : Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.h),
                            bottomRight: Radius.circular(20.h),
                          ),
                          child: Container(
                            color: AppColors.white,
                            width: 375.w,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppSpacerH(44.h),
                                SizedBox(
                                  height: 48.h,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/icon_wave.png',
                                        height: 48.h,
                                        width: 48.w,
                                      ),
                                      AppSpacerW(15.w),
                                      // if (authBox.get('token') != null)
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            S.of(context).hello,
                                            style:
                                                AppTextDecor.osRegular12black,
                                            textAlign: TextAlign.start,
                                          ),
                                          Expanded(
                                            child: Text(
                                              authBox.get('token') != null
                                                  ? '${box.get('name')}'
                                                  : S.of(context).plslgin,
                                              style: AppTextDecor.osBold20Black,
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                          // Text(
                                          //   address,
                                          //   style: AppTextDecor.osRegular14white,
                                          // )
                                        ],
                                      ),
                                      const Expanded(child: SizedBox()),
                                      if (authBox.get('token') != null)
                                        Container(
                                          // padding: const EdgeInsets.all(1),
                                          width: 39.h,
                                          height: 39.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.gray,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(19.r),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(18.r),
                                            child: CachedNetworkImage(
                                              imageUrl: box
                                                  .get('profile_photo_path')
                                                  .toString(),
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                        )
                                      else
                                        GestureDetector(
                                          onTap: () {
                                            context.nav.pushNamed(
                                              Routes.loginScreen,
                                            );
                                          },
                                          child: SvgPicture.asset(
                                            "assets/svgs/icon_home_login.svg",
                                            width: 39.h,
                                            height: 39.h,
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                AppSpacerH(20.h),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              AppSpacerH(20.h),
                              AppSpacerH(32.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      S.of(context).frenchies,
                                      style: AppTextDecor.osBold24black,
                                    ),
                                    AppSpacerH(12.h),
                                    getFrenchModel!.data.franchise!.isEmpty
                                        ? Container(
                                            height: 100,
                                            child: Center(
                                              child: Text(
                                                S.of(context).getnofrench,
                                                style: AppTextDecor
                                                    .osRegular14black,
                                              ),
                                            ))
                                        : Container(
                                            height: 230,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: getFrenchModel
                                                  ?.data.franchise?.length,
                                              itemBuilder: (context, index) {
                                                return Card(
                                                  child: Container(
                                                    width: 110,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                frenchId = getFrenchModel
                                                                    ?.data
                                                                    .franchise?[
                                                                        index]
                                                                    .id
                                                                    .toString();
                                                              });

                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => Servicess(
                                                                        venderId:
                                                                            outletid
                                                                                .toString(),
                                                                        frenchId:
                                                                            frenchId.toString()),
                                                                  ));
                                                            },
                                                            child: Column(
                                                                children: [
                                                                  getFrenchModel?.data.franchise?[index].profilePhotoId ==
                                                                              '' ||
                                                                          getFrenchModel?.data.franchise?[index].profilePhotoId ==
                                                                              'null'
                                                                      ? Container(
                                                                          height:
                                                                              70,
                                                                          //decoration: BoxDecoration(image: DecorationImage(image: AssetImage('${outletList[index]['image']}'),fit: BoxFit.fill)),
                                                                          decoration:
                                                                              BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/not_found.png'), fit: BoxFit.fill)),
                                                                        )
                                                                      : Container(
                                                                          height:
                                                                              70,
                                                                          //decoration: BoxDecoration(image: DecorationImage(image: AssetImage('${outletList[index]['image']}'),fit: BoxFit.fill)),
                                                                          decoration:
                                                                              BoxDecoration(image: DecorationImage(image: NetworkImage('${getFrenchModel?.data.franchise?[index].profilePhotoId}'), fit: BoxFit.fill)),
                                                                        ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Name',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        '${getFrenchModel?.data.franchise?[index].firstName}',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                10),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                ]),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              // openMap('${getOutletModel?.data?.outlets?[index].address}');
                                                            },
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'Address',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .location_on,
                                                                      color: AppColors
                                                                          .black,
                                                                      size: 15,
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                        width:
                                                                            100,

                                                                        //child: Text('Address: ${outletList[index]['address']}',style: TextStyle(fontSize: 10),)),

                                                                        child: getFrenchModel?.data.franchise?[index].address ==
                                                                                'null'
                                                                            ? Text(
                                                                                '',
                                                                                overflow: TextOverflow.ellipsis,
                                                                                maxLines: 1,
                                                                                style: TextStyle(fontSize: 10),
                                                                              )
                                                                            : Text(
                                                                                '${getFrenchModel?.data.franchise?[index].address ?? ''}',
                                                                                overflow: TextOverflow.ellipsis,
                                                                                maxLines: 1,
                                                                                style: TextStyle(fontSize: 10),
                                                                              )),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                frenchId = getFrenchModel
                                                                    ?.data
                                                                    .franchise?[
                                                                        index]
                                                                    .id
                                                                    .toString();
                                                              });

                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => Servicess(
                                                                        venderId:
                                                                            outletid
                                                                                .toString(),
                                                                        frenchId:
                                                                            frenchId.toString()),
                                                                  ));
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border: Border
                                                                          .all()),
                                                              child: Center(
                                                                child: Text(
                                                                  'Order Now',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
            },
          );
        },
      ),
    );
  }

  GetFrenchModel? getFrenchModel;

  Future<void> getfrench() async {
    print("=============get french model");
    var request = http.MultipartRequest(
        'POST', Uri.parse('${AppConfig.baseUrl}/get-franchiese'));
    request.fields.addAll({
      'vendor_id': widget.venderId.toString(),
    });
    print(request.fields);
    print(request.url);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalresult = jsonDecode(result);
      if (finalresult['message'] == "Franchise") {
        var finalresult1 =
            GetFrenchModel.fromJson(finalresult as Map<String, dynamic>);

        setState(() {
          getFrenchModel = finalresult1;
          print('=================${getFrenchModel?.data.franchise?.length}');
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }
}
