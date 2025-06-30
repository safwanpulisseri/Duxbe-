import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class CustomAppBar extends PreferredSize {
  CustomAppBar({
    super.key,
    Widget? title,
    bool? centerTitle,
    List<Widget>? actions,
  }) : super(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                  color: const Color(0xff1B1D3C).withOpacity(.07),
                ),
              ],
            ),
            child: AppBar(
              title: title,
              centerTitle: centerTitle,
              actions: actions,
              automaticallyImplyLeading: false,
              leadingWidth: 70,
              leading: Builder(
                builder: (context) {
                  final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
                  return parentRoute?.impliesAppBarDismissal ?? false
                      ? Padding(
                          padding: const EdgeInsets.only(left: 24, top: 6, bottom: 6),
                          child: Ink(
                            height: 30,
                            width: 30,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: const Color(0xffF7F8F8),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: context.pop,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox();
                },
              ),
            ),
          ),
        );
}
