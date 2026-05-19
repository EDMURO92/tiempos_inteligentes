import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../calculos/generador_numeros.dart';
import '../tiempo/control_bloqueos.dart';
import '../anuncios/gestor_admob.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  List<bool> unlockedNumbers = [true, true, true, false, false];
  List<String> dailyNumbers = ["00", "00", "00", "00", "00"];
  bool isTimeLocked = false;
  String formattedDate = "...";
  bool esUsuarioVIP = false;

  BannerAd? bannerInferior;
  List<NativeAd?> anunciosNativosLaterales = [null, null, null, null];
  bool cargandoVideo = false;
  int videosVistosParaUltimo = 0;

  @override
  void initState() {
    super.initState();
    _inicializarApp();
  }

  @override
  void dispose() {
    bannerInferior?.dispose();
    for (var ad in anunciosNativosLaterales) {
      ad?.dispose();
    }
    super.dispose();
  }

  Future<void> _inicializarApp() async {
    // Control de seguridad: Si falla RevenueCat en desarrollo, capturamos el error para no congelar la UI
    try {
      await ControlBloqueos.resetearMemoriaSiEsNuevoDia();
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      esUsuarioVIP =
          customerInfo.entitlements.all["VIP_ACCESS"]?.isActive == true;
    } catch (_) {
      esUsuarioVIP = false; // Por defecto falso para pruebas en emulador
    }

    bool bloqueado = await ControlBloqueos.estaBloqueado();
    List<String> numsDelDia = GeneradorNumeros.obtenerNumerosDelDia();
    DateTime fechaLocal = DateTime.now();

    if (!mounted) return;

    setState(() {
      dailyNumbers = numsDelDia;
      isTimeLocked = bloqueado;
      formattedDate = DateFormat('dd / MM / yyyy').format(fechaLocal);

      if (esUsuarioVIP) {
        unlockedNumbers = [true, true, true, true, true];
      } else {
        if (isTimeLocked) {
          unlockedNumbers = [true, true, true, false, false];
          videosVistosParaUltimo = 0;
        } else {
          unlockedNumbers = [true, true, true, true, true];
        }
        _cargarPublicidadFija();
        try {
          GestorAdMob.mostrarAnuncioEntrada();
        } catch (_) {}
      }
    });
  }

  void _cargarPublicidadFija() {
    try {
      setState(() {
        bannerInferior = GestorAdMob.crearBanner();
        for (int i = 0; i < 4; i++) {
          anunciosNativosLaterales[i] = GestorAdMob.crearAnuncioNativo(
            onLoaded: () => setState(() {}),
          );
        }
      });
    } catch (_) {}
  }

  void _comprarMembresiaVIP() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      Package? paqueteMensual = offerings.current?.monthly;

      if (paqueteMensual != null) {
        PurchaseParams params = PurchaseParams.package(paqueteMensual);
        PurchaseResult result = await Purchases.purchase(params);

        if (result.customerInfo.entitlements.all["VIP_ACCESS"]?.isActive ==
            true) {
          setState(() {
            esUsuarioVIP = true;
            unlockedNumbers = [true, true, true, true, true];
          });
          _inicializarApp();
        }
      }
    } catch (_) {}
  }

  void _verAnuncioParaDesbloquear(int index) {
    if (cargandoVideo || esUsuarioVIP) return;

    setState(() {
      cargandoVideo = true;
    });

    if (index == 4) {
      GestorAdMob.cargarVideoPremiado(
        onPremioGanado: (reward) {
          videosVistosParaUltimo++;
          if (videosVistosParaUltimo >= 2) {
            _completarDesbloqueoExitoso(index);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "¡Excelente! Mira 1 video más para revelar el último número secreto.",
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        onAdClosed: () {
          if (!mounted) return;
          setState(() {
            cargandoVideo = false;
          });
        },
      );
    } else {
      GestorAdMob.cargarVideoPremiado(
        onPremioGanado: (reward) => _completarDesbloqueoExitoso(index),
        onAdClosed: () {
          if (!mounted) return;
          setState(() {
            cargandoVideo = false;
          });
        },
      );
    }
  }

  void _completarDesbloqueoExitoso(int index) async {
    await ControlBloqueos.guardarDesbloqueo();
    if (!mounted) return;
    setState(() {
      unlockedNumbers[index] = true;
      cargandoVideo = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("¡Número ${index + 1} revelado con éxito!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: Column(
          children: [
            // Header: Fecha
            Container(
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF252538),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "RECOMENDACIONES PARA HOY",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Botón VIP
            if (!esUsuarioVIP)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: _comprarMembresiaVIP,
                  icon: const Icon(Icons.star, color: Colors.black, size: 18),
                  label: const Text(
                    "QUITAR ANUNCIOS (VIP \$3.99/mes)",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: const Size(double.infinity, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            // Contenido Central
            Expanded(
              child: Row(
                children: [
                  // Anuncios Pasivos Laterales
                  Container(
                    width: 95,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                        (index) => Container(
                          height: 75,
                          width: 75,
                          decoration: BoxDecoration(
                            color: const Color(0xFF252538),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child:
                              !esUsuarioVIP &&
                                  anunciosNativosLaterales[index] != null
                              ? AdWidget(ad: anunciosNativosLaterales[index]!)
                              : const Center(
                                  child: Icon(
                                    Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Círculo de Números
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double centroX = constraints.maxWidth / 2;
                        double centroY = constraints.maxHeight / 2;
                        double radio = math.min(centroX, centroY) * 0.65;

                        return Stack(
                          children: [
                            Center(
                              child: Container(
                                width: radio * 2,
                                height: radio * 2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                            ...List.generate(5, (index) {
                              double angulo =
                                  (index * 2 * math.pi / 5) - (math.pi / 2);
                              double x =
                                  centroX + radio * math.cos(angulo) - 32;
                              double y =
                                  centroY + radio * math.sin(angulo) - 32;
                              bool estaAbierto = unlockedNumbers[index];

                              return Positioned(
                                left: x,
                                top: y,
                                child: GestureDetector(
                                  onTap: () {
                                    if (!estaAbierto) {
                                      _verAnuncioParaDesbloquear(index);
                                    }
                                  },
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: estaAbierto
                                          ? const Color(0xFF138A36)
                                          : const Color(0xFF313244),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: estaAbierto
                                            ? Colors.greenAccent
                                            : Colors.amber,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: cargandoVideo && !estaAbierto
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.amber,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : estaAbierto
                                          ? Text(
                                              dailyNumbers[index],
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : (index == 4 &&
                                                videosVistosParaUltimo == 1)
                                          ? const Text(
                                              "1/2",
                                              style: TextStyle(
                                                color: Colors.amber,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.lock,
                                              color: Colors.amber,
                                              size: 24,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              height: 60,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF181825),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: !esUsuarioVIP && bannerInferior != null
                  ? AdWidget(ad: bannerInferior!)
                  : const Center(
                      child: Text(
                        "ANUNCIO DE BANNER INFERIOR (PASIVO)",
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
