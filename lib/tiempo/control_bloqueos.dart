import 'package:shared_preferences/shared_preferences.dart';

class ControlBloqueos {
  // Retorna el bloque horario basado en la hora local del dispositivo del usuario
  static int obtenerBloqueActual() {
    int hora = DateTime.now().hour;
    
    if (hora >= 18) return 18; // Bloque 6:00 PM
    if (hora >= 16) return 16; // Bloque 4:00 PM
    if (hora >= 12) return 12; // Bloque 12:00 MD
    return 0;                  // Mañana (libre de candados iniciales)
  }

  // Verifica si el bloque actual ya fue desbloqueado por ver un video
  static Future<bool> estaBloqueado() async {
    int bloqueActual = obtenerBloqueActual();
    
    // Si es de mañana (antes de las 12 MD), la app está libre para enganchar al usuario
    if (bloqueActual == 0) return false;

    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('desbloqueado_$bloqueActual') ?? false);
  }

  // Guarda en la memoria del celular que el usuario ya vio el video de este bloque
  static Future<void> guardarDesbloqueo() async {
    int bloqueActual = obtenerBloqueActual();
    if (bloqueActual == 0) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('desbloqueado_$bloqueActual', true);
  }

  // Resetea la memoria local al cambiar de día según el calendario del teléfono
  static Future<void> resetearMemoriaSiEsNuevoDia() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime hoy = DateTime.now();
    String fechaHoy = "${hoy.year}${hoy.month}${hoy.day}";
    String? ultimaFecha = prefs.getString('ultima_fecha');

    if (ultimaFecha != fechaHoy) {
      // Es un nuevo día local, borramos los desbloqueos viejos
      await prefs.remove('desbloqueado_12');
      await prefs.remove('desbloqueado_16');
      await prefs.remove('desbloqueado_18');
      await prefs.setString('ultima_fecha', fechaHoy);
    }
  }
}
