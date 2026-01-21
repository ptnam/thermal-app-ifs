abstract class Endpoints {
  String get baseUrl;

  String path(String relativePath) {
    if (relativePath.startsWith('/')) {
      return '$baseUrl$relativePath';
    }
    return '$baseUrl/$relativePath';
  }
}


