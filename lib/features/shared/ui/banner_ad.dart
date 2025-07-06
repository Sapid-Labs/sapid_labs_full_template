import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:universal_io/io.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  State<BannerAdWidget> createState() => BannerAdWidgetState();
}

class BannerAdWidgetState extends State<BannerAdWidget> {
  final testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final BannerAd myBanner = BannerAd(
    adUnitId: kReleaseMode
        ? 'ca-app-pub-XXXXXXXXXXXXXXXXXXXXXXXX'
        : 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: myBanner.load(),
      builder: (context, snapshot) {
        final AdWidget adWidget = AdWidget(ad: myBanner);

        final Container adContainer = Container(
          alignment: Alignment.center,
          child: adWidget,
          width: myBanner.size.width.toDouble(),
          height: myBanner.size.height.toDouble(),
        );

        return adContainer;
      },
    );
  }
}
