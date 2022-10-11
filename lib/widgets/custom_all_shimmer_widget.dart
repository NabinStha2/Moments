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
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
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

  static Widget allPostsShimmerWidget() {
    return CustomShimmerWidget(
      widget: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          physics: const BouncingScrollPhysics(),
          itemCount: 10,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
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
                            width: 4,
                            borderRadius: 3,
                          ),
                          vSizedBox0,
                          CustomShimmerContainerWidget(
                            height: 6,
                            width: 4,
                            borderRadius: 3,
                          ),
                          vSizedBox0,
                          CustomShimmerContainerWidget(
                            height: 6,
                            width: 4,
                            borderRadius: 3,
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
}
