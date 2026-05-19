import 'package:intl/intl.dart';

class GeneradorNumeros {
  
  static List<String> obtenerNumerosDelDia() {
    DateTime hoy = DateTime.now();
    String fechaStr = DateFormat('ddMMyyyy').format(hoy);
    
    List<List<int>> piramide = _calcularPiramide(fechaStr);
    Set<String> numsPiramide = _obtenerNumerosPiramide(piramide);
    
    Map<String, String> valoresTrebol = _calcularCrucetaTrebolAuto(fechaStr);
    Set<String> numsCruceta = _obtenerNumerosCruceta(valoresTrebol);
    
    // Intersección matemática de tus dos figuras
    List<String> coincidencias = numsPiramide.intersection(numsCruceta).toList();
    coincidencias.sort();
    
    List<String> resultadosFinales = [];
    for (String num in coincidencias) {
      if (resultadosFinales.length < 5) {
        resultadosFinales.add(num);
      }
    }
    
    // Relleno matemático exacto si el cruce da menos de 5 combinaciones
    int multiplicador = 1;
    while (resultadosFinales.length < 5) {
      int semilla = int.parse(fechaStr.substring(0, 4));
      int relleno = (semilla * multiplicador + 13) % 100;
      String rellenoStr = relleno.toString().padLeft(2, '0');
      if (!resultadosFinales.contains(rellenoStr)) {
        resultadosFinales.add(rellenoStr);
      }
      multiplicador++;
    }
    
    return resultadosFinales;
  }

  static List<List<int>> _calcularPiramide(String fechaStr) {
    List<int> digitos = fechaStr.split('').map((e) => int.parse(e)).toList();
    List<List<int>> piramide = [List.from(digitos)];
    
    while (digitos.length > 1) {
      List<int> nuevoNivel = [];
      for (int i = 0; i < digitos.length - 1; i++) {
        nuevoNivel.add((digitos[i] + digitos[i + 1]) % 10);
      }
      piramide.add(nuevoNivel);
      digitos = nuevoNivel;
    }
    return piramide;
  }

  static Set<String> _obtenerNumerosPiramide(List<List<int>> piramide) {
    Set<String> numeros = {};
    for (var nivel in piramide) {
      if (nivel.length >= 2) {
        for (int i = 0; i < nivel.length - 1; i++) {
          numeros.add("${nivel[i]}${nivel[i + 1]}");
          numeros.add("${nivel[i + 1]}${nivel[i]}");
        }
      }
    }
    return numeros;
  }

  static Map<String, String> _calcularCrucetaTrebolAuto(String fechaStr) {
    List<int> digitos = fechaStr.split('').map((e) => int.parse(e)).toList();
    
    int d1 = digitos.isNotEmpty ? digitos[0] : 1;
    int d2 = digitos.length > 1 ? digitos[1] : 5;
    int m1 = digitos.length > 2 ? digitos[2] : 0;
    int m2 = digitos.length > 3 ? digitos[3] : 5;
    
    int cAr = (d1 + d2) % 10;
    int cAb = (m1 + m2) % 10;
    int cIz = (d2 + m1) % 10;
    int cDe = (cAr + cAb) % 10;
    
    return {
      'circ_ar': cAr.toString(),
      'circ_ab': cAb.toString(),
      'circ_iz': cIz.toString(),
      'circ_de': cDe.toString(),
      'est_si': ((cAr + cIz) % 10).toString(),
      'est_sd': ((cAr + cDe) % 10).toString(),
      'est_ii': ((cAb + cIz) % 10).toString(),
      'est_id': ((cAb + cDe) % 10).toString()
    };
  }

  static Set<String> _obtenerNumerosCruceta(Map<String, String> v) {
    Set<String> numeros = {};
    List<List<String>> conexiones = [
      [v['est_si']!, v['circ_ar']!], [v['circ_ar']!, v['circ_de']!], [v['circ_de']!, v['est_id']!],
      [v['est_ii']!, v['circ_iz']!], [v['circ_iz']!, v['circ_ab']!], [v['circ_ab']!, v['est_sd']!],
      [v['circ_ar']!, v['circ_iz']!], [v['circ_iz']!, v['circ_ab']!], [v['circ_ab']!, v['circ_de']!], [v['circ_de']!, v['circ_ar']!]
    ];
    
    for (var par in conexiones) {
      numeros.add("${par[0]}${par[1]}");
      numeros.add("${par[1]}${par[0]}");
    }
    return numeros;
  }
}
