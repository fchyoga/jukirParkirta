
class Endpoint {
  static const _baseUrl = 'https://parkirta.com/api/';
  // static const _baseUrl = 'https://prd.parkirta.test/api/';

  get baseUrl => _baseUrl;
  bool isDevelopment = _baseUrl == 'https://parkirta.com/api/';

  static const String urlLogin= '${_baseUrl}login/pelanggan';
}
