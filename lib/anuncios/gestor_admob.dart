import 'package:google_mobile_ads/google_mobile_ads.dart';

class GestorAdMob {
  // IDs de prueba oficiales de Google AdMob para Android
  static const String idBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String idNative = 'ca-app-pub-3940256099942544/2247696110';
  static const String idIntersticial = 'ca-app-pub-3940256099942544/1033173712';
  static const String idRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // Carga un Banner horizontal estándar para el footer
  static BannerAd crearBanner() {
    return BannerAd(
      adUnitId: idBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  // Carga un anuncio nativo personalizado que cabe en tus cuadros de 75x75
  static NativeAd crearAnuncioNativo({required Function() onLoaded}) {
    return NativeAd(
      adUnitId: idNative,
      factoryId: 'adFactoryPequeña',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  // CORREGIDO: Uso del parámetro 'adLoadCallback' oficial exigido por el SDK nuevo
  static void mostrarAnuncioEntrada() {
    InterstitialAd.load(
      adUnitId: idIntersticial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback( // Nombre del parámetro corregido aquí
        onAdLoaded: (ad) {
          ad.show();
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  // Carga el video premiado de pantalla completa
  static void cargarVideoPremiado({
    required Function(RewardItem reward) onPremioGanado,
    required Function() onAdClosed,
  }) {
    RewardedAd.load(
      adUnitId: idRewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (adDisposed) {
              adDisposed.dispose();
              onAdClosed();
            },
            onAdFailedToShowFullScreenContent: (adFailed, error) {
              adFailed.dispose();
              onAdClosed();
            },
          );
          ad.show(onUserEarnedReward: (adWithoutView, reward) => onPremioGanado(reward));
        },
        onAdFailedToLoad: (error) => onAdClosed(),
      ),
    );
  }
}
