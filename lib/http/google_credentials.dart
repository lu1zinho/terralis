
String getGoogleCredentials() {
  
  String googleCredentials = '''
{
  "type": "${const String.fromEnvironment('TYPE')}",
  "project_id": "${const String.fromEnvironment('PROJECT_ID')}",
  "private_key_id": "${const String.fromEnvironment('PRIVATE_KEY_ID')}",
  "private_key": "${const String.fromEnvironment('PRIVATE_KEY')}",
  "client_email": "${const String.fromEnvironment('CLIENT_EMAIL')}",
  "client_id": "${const String.fromEnvironment('CLIENT_ID')}",
  "auth_uri": "${const String.fromEnvironment('AUTH_URI')}",
  "token_uri": "${const String.fromEnvironment('TOKEN_URI')}",
  "auth_provider_x509_cert_url": "${const String.fromEnvironment('AUTH_PROVIDER_X509_CERT_URL')}",
  "client_x509_cert_url": "${const String.fromEnvironment('CLIENT_X509_CERT_URL')}",
  "universe_domain": "${const String.fromEnvironment('UNIVERSE_DOMAIN')}"
}
''';

  return googleCredentials;
}
