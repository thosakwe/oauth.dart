import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:oauth_forked/oauth.dart' as oauth;
import 'package:oauth_forked/server_io.dart';
import '_server_tests.dart';

main() {
  HttpServer server;
  setUp(() {
    return HttpServer.bind(InternetAddress.loopbackIPv4, 0).then((server_) {
      server = server_;
      server.listen((HttpRequest request) {
        var reqAdapter = new HttpRequestAdapter(request);
        oauth
            .isAuthorized(reqAdapter, simpleTokenFinder, simpleNonceQuery)
            .then((bool authorized) {
          request.response.statusCode = authorized ? 200 : 403;
          request.response.write("Body");
          return request.response.close();
        });
      });
    });
  });
  tearDown(() {
    return server.close(force: false).then((_) {
      return new Future.delayed(new Duration(milliseconds: 100));
    });
  });

  runAllServerTests(() => server);
}
