import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';
import 'package:oauth_forked/oauth.dart' as oauth;
import 'package:oauth_forked/server_shelf.dart';
import '_server_tests.dart';

main() {
  HttpServer server;
  setUp(() {
    return shelf_io.serve((shelf.Request req) {
      var reqAdapter = new ShelfRequestAdapter(req);
      return oauth
          .isAuthorized(reqAdapter, simpleTokenFinder, simpleNonceQuery)
          .then((bool authorized) {
        if (authorized) {
          return new shelf.Response.ok("OK");
        } else {
          return new shelf.Response.forbidden("Forbidden");
        }
      });
    }, InternetAddress.loopbackIPv4, 0).then((server_) {
      server = server_;
    });
  });
  tearDown(() {
    return server.close(force: false).then((_) {
      return new Future.delayed(new Duration(milliseconds: 100));
    });
  });

  runAllServerTests(() => server);
}
