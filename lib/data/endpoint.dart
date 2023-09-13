
class Endpoint {
  static const _baseUrl = 'https://parkirta.com/api/';
  // static const _baseUrl = 'https://prd.parkirta.test/api/';

  get baseUrl => _baseUrl;
  bool isDevelopment = _baseUrl == 'https://parkirta.com/api/';

  static const String urlLogin= '${_baseUrl}login/jukir';
  static const String urlArrival= '${_baseUrl}retribusi/parking/arrive';
  static const String urlCheckDetailParking= '${_baseUrl}retribusi/parking/check/detail';
  static const String urlPayment= '${_baseUrl}retribusi/payment/jukir';
}
