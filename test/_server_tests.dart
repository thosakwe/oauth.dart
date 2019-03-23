library oauth.test.common;

import 'dart:async';
import 'dart:io';
import 'package:oauth_forked/oauth.dart' as oauth;
import 'package:test/test.dart';

Future<bool> simpleNonceQuery(
    String consumerToken, String userToken, String nonce, DateTime expiry) {
  return new Future.value(true);
}

Future<oauth.Tokens> simpleTokenFinder(
    String type, String consumer, String user) async {
  assert(type == "HMAC-SHA1");

  var consumerSecret = consumer.toUpperCase();
  var userSecret = null;
  if (user != null) userSecret = user.toUpperCase();

  return new oauth.Tokens(
      consumerId: consumer,
      consumerKey: consumerSecret,
      userId: user,
      userKey: userSecret);
}

runAllServerTests(HttpServer Function() serverFn) {
  runAllTests(() {
    var server = serverFn();
    var uri =
        Uri(scheme: 'http', host: server.address.address, port: server.port);
    return uri.authority;
  });
}

runAllTests(String Function() authorityFn) {
  standardTests(oauth.Client goodClient) => () {
        test("Simple GET", () async {
          var response = await goodClient
              .get(new Uri.http(authorityFn(), "/test/path", {"foo": "bar"}));
          expect(response.statusCode, 200);
        });

        test("Simple POST", () async {
          var response = await goodClient.post(
              new Uri.http(authorityFn(), "/test/path"),
              body: "Hello, World!");
          expect(response.statusCode, 200);
        });

        test("Form Data POST", () async {
          var response = await goodClient.post(
              new Uri.http(authorityFn(), "/test/path", {"c": "4"}),
              body: "a=1&b=2&c=3",
              headers: {"Content-Type": "application/x-www-form-urlencoded"});
          expect(response.statusCode, 200);
        });
      };

  group(
      "Consumer credentials only",
      standardTests(new oauth.Client(
          new oauth.Tokens(consumerId: "Hello", consumerKey: "HELLO"))));

  group(
      "With user credentials",
      standardTests(new oauth.Client(new oauth.Tokens(
          consumerId: "Hello",
          consumerKey: "HELLO",
          userId: "World",
          userKey: "WORLD"))));

  test("Bad GET", () async {
    var client = new oauth.Client(
        new oauth.Tokens(consumerId: "bad", consumerKey: "very very bad"));
    var response = await client.get(new Uri.http(authorityFn(), "/"));
    expect(response.statusCode, 403);
  });
}
