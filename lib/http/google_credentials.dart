import 'package:universal_html/js.dart' as js;

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
  "type": "${type != '' ? type : js.context['TYPE']}",
  "project_id": "${projectId != '' ? projectId : js.context['PROJECT_ID']}",
  "private_key_id": "${privateKeyId != '' ? privateKeyId : js.context['PRIVATE_KEY_ID']}",
  "private_key": "${privateKey != '' ? privateKey : js.context['PRIVATE_KEY']}",
  "client_email": "${clientEmail != '' ? clientEmail : js.context['CLIENT_EMAIL']}",
  "client_id": "${clientId != '' ? clientId : js.context['CLIENT_ID']}",
  "auth_uri": "${authUri != '' ? authUri : js.context['AUTH_URI']}",
  "token_uri": "${tokenUri != '' ? tokenUri : js.context['TOKEN_URI']}",
  "auth_provider_x509_cert_url": "${authProviderX509CertUrl != '' ? authProviderX509CertUrl : js.context['AUTH_PROVIDER_X509_CERT_URL']}",
  "client_x509_cert_url": "${clientX509CertUrl != '' ? clientX509CertUrl : js.context['CLIENT_X509_CERT_URL']}",
  "universe_domain": "${universeDomain != '' ? universeDomain : js.context['UNIVERSE_DOMAIN']}"
}
''';

  return googleCredentials;
}
