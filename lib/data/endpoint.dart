
class Endpoint {
  static const _baseUrl = 'https://parkirta.com/api/';
  // static const _baseUrl = 'https://prd.parkirta.test/api/';

  get baseUrl => _baseUrl;
  bool isDevelopment = _baseUrl == 'https://parkirta.com/api/';

  static const String urlLogin= '${_baseUrl}login/jukir';
  static const String urlProfile= '${_baseUrl}profile/detail';
  static const String urlNotification= '${_baseUrl}notifikasi/jukir';
  static const String urlReadNotification= '${_baseUrl}notifikasi/jukir/read/update';
  static const String urlParkingLocation= '${_baseUrl}master/lokasi_parkir';
  static const String urlArrival= '${_baseUrl}retribusi/parking/arrive';
  static const String urlCheckParking= '${_baseUrl}retribusi/parking/check/jukir';
  static const String urlCheckDetailParking= '${_baseUrl}retribusi/parking/check/detail';
  static const String urlUploadPhotoVehicle= '${_baseUrl}retribusi/upload/foto_kendaraan';
  static const String urlUpdateParkingStatus= '${_baseUrl}retribusi/parking/status';
  static const String urlPayment= '${_baseUrl}retribusi/payment/jukir';
}
