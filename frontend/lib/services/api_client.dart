import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions/exceptions.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  // example:
  // flutter run --dart-define=JINTEREST_HOST=192.168.1.10
  static const String host = String.fromEnvironment(
    'JINTEREST_HOST',
    defaultValue: 'localhost',
  );
  static const int port = int.fromEnvironment(
    'JINTEREST_PORT',
    defaultValue: 8800,
  );

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration responseTimeout = Duration(seconds: 30);

  Future<Map<String, dynamic>> send({
    required String method,
    required String route,
    Map<String, dynamic>? payload,
  }) async {
    Socket? socket;

    try {
      socket = await Socket.connect(host, port, timeout: connectionTimeout);

      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('session_username');

      final request = <String, dynamic>{
        'method': method,
        'route': route,
        'username': username,
        'payload': payload ?? <String, dynamic>{},
      };

      socket.write('${jsonEncode(request)}\n');

      final responseLine = await socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .first
          .timeout(responseTimeout);

      final decoded = jsonDecode(responseLine);

      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          statusCode: 500,
          message: 'Server returned an invalid response',
        );
      }

      final statusCode = decoded['statusCode'];

      if (statusCode is! int) {
        throw ApiException(
          statusCode: 500,
          message: 'Server response has no valid status code',
        );
      }

      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException(
          statusCode: statusCode,
          message: decoded['message']?.toString() ?? 'Server request failed',
          payload: _mapOrEmpty(decoded['payload']),
        );
      }

      return decoded;
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Could not connect to the server: ${e.message}',
      );
    } on TimeoutException {
      throw ApiException(
        statusCode: 0,
        message: 'The server did not respond in time',
      );
    } on FormatException {
      throw ApiException(
        statusCode: 500,
        message: 'Server returned invalid JSON',
      );
    } finally {
      await socket?.close();
    }
  }

  Map<String, dynamic> _mapOrEmpty(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    return <String, dynamic>{};
  }
}
