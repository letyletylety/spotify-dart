part of spotify;


class SpotifyApiMock extends SpotifyApiBase{
  SpotifyApiMock(SpotifyApiCredentials credentials) : super.fromClient(MockClient());

  MockHttpError _mockHttpError;

  MockHttpError get mockHttpError => _mockHttpError;

  set mockHttpError(MockHttpError value) => _mockHttpError = value;
}

class MockClient implements http.BaseClient {
  MockClient([MockHttpError mockHttpError]) : _mockHttpError = mockHttpError;

  MockHttpError _mockHttpError;

  String _readPath(String url) {
    var regexString = url.contains('api.spotify.com')
        ? r'api.spotify.com\/([A-Za-z0-9/]+)\??'
        : r'api/([A-Za-z0-9/]+)\??';

    var regex = new RegExp(regexString);
    var partialPath = regex.firstMatch(url).group(1);
    var file = new File('test/data/$partialPath.json');

    return file.readAsStringSync();
  }

  @override
  void close() {
    throw "Not implemented";
  }

  @override
  Future<http.Response> delete(url, {Map<String, String> headers}) {
    throw "Not implemented";
  }

  @override
  Future<http.Response> get(url, {Map<String, String> headers}) async {
    if (_mockHttpError != null) {
      return createErrorResponse(_mockHttpError);
    }
    return createSuccessResponse(_readPath(url));
  }

  @override
  Future<http.Response> head(url, {Map<String, String> headers}) {
    throw "Not implemented";
  }

  @override
  Future<http.Response> patch(url,
      {Map<String, String> headers, body, Encoding encoding}) {
    throw "Not implemented";
  }

  @override
  Future<http.Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    if (_mockHttpError != null) {
      return createErrorResponse(_mockHttpError);
    }
    return createSuccessResponse(_readPath(url));
  }

  @override
  Future<http.Response> put(url,
      {Map<String, String> headers, body, Encoding encoding}) {
    throw "Not implemented";
  }

  @override
  Future<String> read(url, {Map<String, String> headers}) {
    throw "Not implemented";
  }

  @override
  Future<Uint8List> readBytes(url, {Map<String, String> headers}) {
    throw "Not implemented";
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw "Not implemented";
  }

  http.Response createSuccessResponse(String body) {
    /// necessary due to using Latin-1 encoding per default.
    /// https://stackoverflow.com/questions/52990816/dart-json-encodedata-can-not-accept-other-language
    return new http.Response(body, 200,
        headers: {'Content-Type': 'application/json; charset=utf-8'});
  }

  http.Response createErrorResponse(MockHttpError error) {
    return new http.Response(
        _wrapMessageToJson(error.statusCode, error.message), error.statusCode,
        headers: {'Content-Type': 'application/json; charset=utf-8'});
  }

  String _wrapMessageToJson(int statusCode, String message) =>
      "{ \"error\": {\"status\":$statusCode,\"message\": \"$message\"}}";
}

class MockHttpError {
  int statusCode;
  String message;

  MockHttpError({this.statusCode, this.message});
}
