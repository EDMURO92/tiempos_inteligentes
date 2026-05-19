import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'anuncios/gestor_suscripciones.dart';
import 'pantallas/pantalla_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enciende los dos motores comerciales en segundo plano
  await MobileAds.instance.initialize();
  await GestorSuscripciones.inicializar();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiempos Inteligentes',
      theme: ThemeData.dark(),
      home: const PantallaPrincipal(),
    );
  }
}
