import '../config_url/config.dart';

class ApiEndpoints {
  static const String login = "${Config.apiBaseUrl}/Authenticate/login";
  static const String register = "${Config.apiBaseUrl}/Authenticate/register";
}