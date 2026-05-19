import 'package:purchases_flutter/purchases_flutter.dart';

class GestorSuscripciones {
  // ID de configuración que te dará RevenueCat en su panel web
  static const String apiKeyAndroid = "public_google_api_key_de_prueba";

  // Inicializa el motor de compras al arrancar la app
  static Future<void> inicializar() async {
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration = PurchasesConfiguration(apiKeyAndroid);
    await Purchases.configure(configuration);
  }

  // Retorna true si el usuario pagó los $4 USD fijos, false si debe ver anuncios
  static Future<bool> verificarSiEsVIP() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // "VIP_ACCESS" será el nombre identificador que crearemos en las tiendas
      if (customerInfo.entitlements.all["VIP_ACCESS"]?.isActive == true) {
        return true; 
      }
    } catch (_) {
      // Si el celular no tiene internet, por seguridad asume que es usuario gratis
    }
    return false;
  }
}
