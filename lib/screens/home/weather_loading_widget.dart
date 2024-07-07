import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sky_snap/screens/place_search/city_management_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/navigation.dart';

class WeatherLoadingWidget extends StatelessWidget {
  final bool fromMain;

  const WeatherLoadingWidget({super.key, required this.fromMain});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 132, 214, 252),
            Color.fromARGB(255, 132, 214, 252),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        color: primaryColor,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background_world.png',
            fit: BoxFit.fitHeight,
            color: primaryColor.withOpacity(0.5),
          ),
          Scaffold(
            appBar: _buildAppBar(context),
            backgroundColor: transparentColor,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _buildPageView(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: !fromMain,
      iconTheme: IconThemeData(color: textColor),
      title: Text(
        'Sky Snap',
        style: TextStyle(color: textColor),
      ),
      leading: !fromMain
          ? null
          : IconButton(
              onPressed: () {
                startScreen(context, CityManagementScreen());
              },
              icon: Icon(
                Icons.add_outlined,
                color: textColor,
              ),
            ),
      backgroundColor: transparentColor,
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: PageController(),
      onPageChanged: (page) {},
      itemCount: 1,
      itemBuilder: (context, index) {
        return _buildPageContent(
          context,
        );
      },
    );
  }

  Widget _buildForecastHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: transparentColor,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: cardBackgroundColor,
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 12,
                color: textBackgroundColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '5-day forecast',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
        InkWell(
          child: const Row(
            children: [
              Text('More details'),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
              ),
            ],
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPageContent(BuildContext context) {
    return EasyRefresh(
      controller: EasyRefreshController(),
      refreshOnStart: false,
      header: const ClassicHeader(),
      footer: null,
      onRefresh: () {},
      onLoad: () async {},
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Shimmer.fromColors(
                  baseColor: shimer300!,
                  highlightColor: shimer100!,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: BoxDecoration(
                      color: transparentColor,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: cardBackgroundColor,
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              _buildForecastContainer(context),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              _buildWeatherDetailsRow(context),
              const SizedBox(height: 10),
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "SkySnap has been developed by ",
                      style: TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    Text(
                      " 🌐 Nyein Chan Toe",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastContainer(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: shimer300!,
        highlightColor: shimer100!,
        child: Container(
          height: MediaQuery.of(context).size.height / 2.75,
          decoration: BoxDecoration(
            color: transparentColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: cardBackgroundColor,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildForecastHeader(),
                const Expanded(child: ShimmerLoadingWidget())
              ],
            ),
          ),
        ));
  }

  Widget _buildWeatherDetailsRow(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width / 2.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Shimmer.fromColors(
                        baseColor: shimer300!,
                        highlightColor: shimer100!,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                            color: transparentColor,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: cardBackgroundColor,
                              ),
                            ],
                          ),
                        ))),
                const SizedBox(height: 10),
                Expanded(
                    child: Shimmer.fromColors(
                        baseColor: shimer300!,
                        highlightColor: shimer100!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: transparentColor,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: cardBackgroundColor,
                              ),
                            ],
                          ),
                        ))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Shimmer.fromColors(
                  baseColor: shimer300!,
                  highlightColor: shimer100!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: transparentColor,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: cardBackgroundColor,
                        ),
                      ],
                    ),
                  ))),
        ],
      ),
    );
  }
}

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: shimer300!,
      highlightColor: shimer100!,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _shimmerBox(context, height: 32),
          const SizedBox(height: 5),
          _shimmerBox(context, height: 32),
          const SizedBox(height: 5),
          _shimmerBox(context, height: 32),
          const SizedBox(height: 5),
          _shimmerBox(context, height: 32),
          const SizedBox(height: 5),
          _shimmerBox(context, height: 32),
        ],
      ),
    );
  }

  Widget _shimmerBox(BuildContext context,
      {double? width, required double height}) {
    return Container(
      width: width ?? MediaQuery.of(context).size.width,
      height: height,
      decoration: BoxDecoration(
        color: textBackgroundColor ,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
