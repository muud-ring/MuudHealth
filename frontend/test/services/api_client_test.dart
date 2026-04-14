import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_client.dart';

void main() {
  group('ApiClient.handleResponse', () {
    test('200 response returns parsed body as Map', () {
      final response = http.Response(
        '{"user": "john", "id": 1}',
        200,
      );

      final result = ApiClient.handleResponse(response);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['user'], 'john');
      expect(result['id'], 1);
    });

    test('201 response returns parsed body', () {
      final response = http.Response(
        '{"created": true}',
        201,
      );

      final result = ApiClient.handleResponse(response);

      expect(result['created'], true);
    });

    test('200 response with non-map body wraps in data key', () {
      final response = http.Response(
        '[1, 2, 3]',
        200,
      );

      final result = ApiClient.handleResponse(response);

      expect(result.containsKey('data'), true);
      expect(result['data'], [1, 2, 3]);
    });

    test('400 response throws exception with message from body', () {
      final response = http.Response(
        '{"message": "Validation failed"}',
        400,
      );

      expect(
        () => ApiClient.handleResponse(response),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Validation failed'),
        )),
      );
    });

    test('400 response without message field throws with status code', () {
      final response = http.Response(
        '{"error": "bad request"}',
        400,
      );

      expect(
        () => ApiClient.handleResponse(response),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('400'),
        )),
      );
    });

    test('500 response throws exception with status code', () {
      final response = http.Response(
        '{"error": "Internal server error"}',
        500,
      );

      expect(
        () => ApiClient.handleResponse(response),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('500'),
        )),
      );
    });

    test('empty body response with 200 returns empty map', () {
      final response = http.Response('', 200);

      final result = ApiClient.handleResponse(response);

      expect(result, isA<Map<String, dynamic>>());
      expect(result, isEmpty);
    });

    test('empty body response with error status throws', () {
      final response = http.Response('', 401);

      expect(
        () => ApiClient.handleResponse(response),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('401'),
        )),
      );
    });
  });
}
