import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

Future main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final cascade = Cascade().add(_router);

  final server = await shelf_io.serve(
    logRequests().addHandler(cascade.handler),
    InternetAddress.anyIPv4, // Allows external connections
    port,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

// Router instance to handler requests.
final _router = shelf_router.Router()
  ..get('/hello_world', _helloWorldHandler)
  ..get("/message", _messageHandler)
  ..post("/usr/refresh_token", _refreshTokenHandler);

Response _helloWorldHandler(Request request) => Response.ok('Hello, World!');

Response _messageHandler(Request request) {
  //fail
  if (request.url.queryParameters["extra"] == "requestFail") {
    return Response.ok(
      json.encode({
        "success": false,
        "error_message": "request failed.",
        "error_code": "403",
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  }

  //need refreshToken
  if (request.headers["Authorization"] == "expireToken") {
    return Response.ok(
      json.encode({
        "success": false,
        "error_message": "token expired.",
        "error_code": 401,
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  }

  return Response.ok(
    json.encode({
      "success": true,
      "data": {
        "message": "hello,world!",
      }
    }),
    headers: {
      'content-type': 'application/json',
    },
  );
}

_refreshTokenHandler(Request request) {
  return Response.ok(
    json.encode({
      "success": true,
      "data": {
        "access_token": "validToken",
        "refresh_token": "refreshToken",
      }
    }),
    headers: {
      'content-type': 'application/json',
    },
  );
}
