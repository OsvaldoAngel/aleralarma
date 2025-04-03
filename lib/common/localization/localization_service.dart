import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Obtener las coordenadas de ubicación actual
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si los servicios de ubicación no están habilitados, no podemos continuar
      print('Los servicios de ubicación están deshabilitados.');
      return null;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Solicitar permiso si está denegado
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si el usuario deniega el permiso, no podemos continuar
        print('Los permisos de ubicación están denegados.');
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Si los permisos están denegados permanentemente, no podemos continuar
      print('Los permisos de ubicación están denegados permanentemente.');
      return null;
    } 

    // Obtener ubicación actual
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      
      return position;
    } catch (e) {
      print('Error al obtener la ubicación: $e');
      return null;
    }
  }

  // Obtener la dirección a partir de coordenadas
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Construir dirección
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.subLocality}' : place.subLocality!;
        }
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.locality}' : place.locality!;
        }
        
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.administrativeArea}' : place.administrativeArea!;
        }
        
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.postalCode}' : place.postalCode!;
        }
        
        if (place.country != null && place.country!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.country}' : place.country!;
        }
        
        return address;
      }
      
      return "Dirección no disponible";
    } catch (e) {
      print('Error al obtener la dirección: $e');
      return "Error al obtener la dirección";
    }
  }
}