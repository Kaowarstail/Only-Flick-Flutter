class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
  
  // API endpoints
  static const String authEndpoint = '/api/v1/auth';
  static const String contentEndpoint = '/api/v1/content';
  static const String userEndpoint = '/api/v1/users';
  static const String subscriptionEndpoint = '/api/v1/subscriptions';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
