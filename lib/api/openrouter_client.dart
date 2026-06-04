import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenRouterClient {
  String? apiKey;
  String? baseUrl;
  final Map<String, String> headers = {};

  OpenRouterClient({this.apiKey, this.baseUrl}) {
    _initialize();
  }

  void updateCredentials({required String apiKey, required String baseUrl}) {
    this.apiKey = apiKey;
    this.baseUrl = baseUrl;
    _initialize();
  }

  void _initialize() {
    headers.clear();
    if (apiKey != null) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    headers['Content-Type'] = 'application/json';
    headers['X-Title'] = 'AI Chat Flutter';
    if (kDebugMode) {
      print('OpenRouterClient initialized with baseUrl: $baseUrl');
    }
  }

  Future<List<Map<String, dynamic>>> getModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: headers,
      );
      if (kDebugMode) {
        print('Models response status: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final modelsData = json.decode(response.body);
        if (modelsData['data'] != null) {
          return (modelsData['data'] as List).map((model) => {
            'id': model['id'] as String,
            'name': (() {
              try {
                return utf8.decode((model['name'] as String).codeUnits);
              } catch (_) {
                final cleaned = (model['name'] as String).replaceAll(RegExp(r'[^\x00-\x7F]'), '');
                return utf8.decode(cleaned.codeUnits);
              }
            })(),
            'pricing': {
              'prompt': model['pricing']['prompt'] as String,
              'completion': model['pricing']['completion'] as String,
            },
            'context_length': (model['context_length'] ?? model['top_provider']?['context_length'] ?? 0).toString(),
          }).toList();
        }
        throw Exception('Invalid API response format');
      } else {
        return [
          {'id': 'deepseek-coder', 'name': 'DeepSeek'},
          {'id': 'claude-3-sonnet', 'name': 'Claude 3.5 Sonnet'},
          {'id': 'gpt-3.5-turbo', 'name': 'GPT-3.5 Turbo'},
        ];
      }
    } catch (e) {
      if (kDebugMode) print('Error getting models: $e');
      return [
        {'id': 'deepseek-coder', 'name': 'DeepSeek'},
        {'id': 'claude-3-sonnet', 'name': 'Claude 3.5 Sonnet'},
        {'id': 'gpt-3.5-turbo', 'name': 'GPT-3.5 Turbo'},
      ];
    }
  }

  Future<Map<String, dynamic>> sendMessage(String message, String model) async {
    try {
      final data = {
        'model': model,
        'messages': [{'role': 'user', 'content': message}],
        'max_tokens': 1000,
        'temperature': 0.7,
        'stream': false,
      };
      if (kDebugMode) print('Sending message to API: ${json.encode(data)}');
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: headers,
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        return {'error': errorData['error']?['message'] ?? 'Unknown error occurred'};
      }
    } catch (e) {
      if (kDebugMode) print('Error sending message: $e');
      return {'error': e.toString()};
    }
  }

  Future<String> getBalance() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl?.contains('vsegpt.ru') == true ? '$baseUrl/balance' : '$baseUrl/credits'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          if (baseUrl?.contains('vsegpt.ru') == true) {
            final credits = double.tryParse(data['data']['credits'].toString()) ?? 0.0;
            return '${credits.toStringAsFixed(2)}₽';
          } else {
            final credits = data['data']['total_credits'] ?? 0;
            final usage = data['data']['total_usage'] ?? 0;
            return '\$${(credits - usage).toStringAsFixed(2)}';
          }
        }
      }
      return baseUrl?.contains('vsegpt.ru') == true ? '0.00₽' : '\$0.00';
    } catch (e) {
      if (kDebugMode) print('Error getting balance: $e');
      return 'Error';
    }
  }

  String formatPricing(double pricing) {
    try {
      if (baseUrl?.contains('vsegpt.ru') == true) {
        return '${pricing.toStringAsFixed(3)}₽/K';
      } else {
        return '\$${(pricing * 1000000).toStringAsFixed(3)}/M';
      }
    } catch (e) {
      if (kDebugMode) print('Error formatting pricing: $e');
      return '0.00';
    }
  }
}