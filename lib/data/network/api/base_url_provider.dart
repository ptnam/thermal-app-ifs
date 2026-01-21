abstract class BaseUrlProvider {
  String get apiBaseUrl;
}

class StaticBaseUrlProvider implements BaseUrlProvider {
  final String _baseUrl;

  const StaticBaseUrlProvider(this._baseUrl);

  @override
  String get apiBaseUrl => _baseUrl;
}


