import 'package:flutter/material.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/widgets/custom_shimmer_container_widget.dart';
import 'package:moment/widgets/custom_shimmer_widget.dart';

class CustomAllShimmerWidget {
  static Widget creatorPostsShimmerWidget({userPostsLength}) {
    return CustomShimmerWidget(
      widget: GridView.builder(
        physics: const ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: userPostsLength > 10 ? 3 : 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
          childAspectRatio: 0.8,
        ),
        itemCount: 9,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        itemBuilder: (context, index) {
          return const CustomShimmerContainerWidget(
            height: 400,
            borderRadius: 8,
            borderColor: Colors.black,
          );
        },
      ),
    );
  }

  static Widget activityShimmerWidget({userPostsLength}) {
    return CustomShimmerWidget(
      widget: ListView.builder(
        itemCount: 15,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CustomShimmerContainerWidget(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            widget: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CustomShimmerContainerWidget(
                      shape: BoxShape.circle,
                    ),
                    hSizedBox1,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomShimmerContainerWidget(
                          height: 10.0,
                          width: appWidth(context) * 0.4,
                          borderRadius: 3,
                        ),
                        vSizedBox1,
                        CustomShimmerContainerWidget(
                          height: 10.0,
                          width: appWidth(context) * 0.2,
                          borderRadius: 3,
                        ),
                      ],
                    ),
                  ],
                ),
                hSizedBox1,
                const CustomShimmerContainerWidget(
                  height: 40,
                  width: 50,
                  borderRadius: 5,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget chatShimmerWidget({userPostsLength}) {
    return CustomShimmerWidget(
      widget: ListView.builder(
        itemCount: 15,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CustomShimmerContainerWidget(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            widget: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CustomShimmerContainerWidget(
                      shape: BoxShape.circle,
                    ),
                    hSizedBox1,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomShimmerContainerWidget(
                          height: 10.0,
                          width: appWidth(context) * 0.4,
                          borderRadius: 3,
                        ),
                        vSizedBox1,
                        CustomShimmerContainerWidget(
                          height: 10.0,
                          width: appWidth(context) * 0.2,
                          borderRadius: 3,
                        ),
                      ],
                    ),
                  ],
                ),
                hSizedBox1,
                const CustomShimmerContainerWidget(
                  shape: BoxShape.circle,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget allPostsShimmerWidget() {
    return CustomShimmerWidget(
      widget: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          physics: const BouncingScrollPhysics(),
          itemCount: 10,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const CustomShimmerContainerWidget(
                            height: 35,
                            width: 35,
                            shape: BoxShape.circle,
                          ),
                          hSizedBox1,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              CustomShimmerContainerWidget(
                                height: 10,
                                width: 50,
                                padding: EdgeInsets.all(10),
                                borderRadius: 3,
                              ),
                              vSizedBox0,
                              CustomShimmerContainerWidget(
                                height: 10,
                                width: 40,
                                borderRadius: 3,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          CustomShimmerContainerWidget(
                            height: 6,
                            width: 6,
                            shape: BoxShape.circle,
                          ),
                          vSizedBox0,
                          CustomShimmerContainerWidget(
                            height: 6,
                            width: 6,
                            shape: BoxShape.circle,
                          ),
                          vSizedBox0,
                          CustomShimmerContainerWidget(
                            height: 6,
                            width: 6,
                            shape: BoxShape.circle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  vSizedBox1,
                  CustomShimmerContainerWidget(
                    height: 250,
                    width: appWidth(context),
                  ),
                  vSizedBox1,
                  const CustomShimmerContainerWidget(
                    height: 10,
                    width: 200,
                  ),
                  vSizedBox1,
                  Row(
                    children: const [
                      CustomShimmerContainerWidget(
                        height: 10,
                        width: 20,
                      ),
                      hSizedBox1,
                      CustomShimmerContainerWidget(
                        height: 10,
                        width: 20,
                      ),
                      hSizedBox1,
                      CustomShimmerContainerWidget(
                        height: 10,
                        width: 20,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  static Widget postDetailsShimmerWidget({required BuildContext context}) {
    return CustomShimmerWidget(
      widget: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomShimmerContainerWidget(
              height: 500,
              width: appWidth(context),
            ),
            vSizedBox1,
            CustomShimmerContainerWidget(
              height: 10,
              width: appWidth(context),
            ),
            vSizedBox1,
            CustomShimmerContainerWidget(
              height: 10,
              width: appWidth(context) * 0.3,
            ),
            vSizedBox1,
            CustomShimmerContainerWidget(
              height: 50,
              width: appWidth(context),
            ),
          ],
        ),
      ),
    );
  }
}
