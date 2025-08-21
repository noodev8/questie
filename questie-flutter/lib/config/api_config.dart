// API Configuration - Simple base URL configuration
// Change the active baseUrl by commenting/uncommenting the lines below

class ApiConfig {
  // Base URL options - uncomment the one you want to use
  //static const String baseUrl = 'http://192.168.0.15:3014'; // welshpool - REAL PHONE
  static const String baseUrl = 'http://192.168.1.187:3014'; // work
  //static const String baseUrl = 'http://192.168.1.173:3014'; // shrewsbury
  //static const String baseUrl = 'http://localhost:3014'; // localhost
  //static const String baseUrl = 'http://10.0.2.2:3014'; // Android emulator
  
  // Derived URLs
  static const String apiBaseUrl = '$baseUrl/api';
  static const String authApiUrl = '$apiBaseUrl/auth';
  static const String healthUrl = '$baseUrl/health';
}
