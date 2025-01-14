
String getGoogleCredentials() {

  const type = String.fromEnvironment('TYPE');
  const projectId = String.fromEnvironment('PROJECT_ID');
  const privateKeyId = String.fromEnvironment('PRIVATE_KEY_ID');
  const privateKey = String.fromEnvironment('PRIVATE_KEY');
  const clientEmail = String.fromEnvironment('CLIENT_EMAIL');
  const clientId = String.fromEnvironment('CLIENT_ID');
  const authUri = String.fromEnvironment('AUTH_URI');
  const tokenUri = String.fromEnvironment('TOKEN_URI');
  const authProviderX509CertUrl = String.fromEnvironment('AUTH_PROVIDER_X509_CERT_URL');
  const clientX509CertUrl = String.fromEnvironment('CLIENT_X509_CERT_URL');
  const universeDomain = String.fromEnvironment('UNIVERSE_DOMAIN');
  
  String googleCredentials = '''
{
  "type": "$type",
  "project_id": "$projectId",
  "private_key_id": "$privateKeyId",
  "private_key": "$privateKey",
  "client_email": "$clientEmail",
  "client_id": "$clientId",
  "auth_uri": "$authUri",
  "token_uri": "$tokenUri",
  "auth_provider_x509_cert_url": "$authProviderX509CertUrl",
  "client_x509_cert_url": "$clientX509CertUrl",
  "universe_domain": "$universeDomain"
}
''';

  return googleCredentials;
}
