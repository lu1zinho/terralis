import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> readJson() async {
  final String response = await rootBundle.loadString('env.json');
  final data = await json.decode(response);
  return data;
}

Future<String> getGoogleCredentials() async {

  Map<String, dynamic> json = await readJson();

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
  "type": "${type != '' ? type : json['TYPE']}",
  "project_id": "${projectId != '' ? projectId : json['PROJECT_ID']}",
  "private_key_id": "${privateKeyId != '' ? privateKeyId : json['PRIVATE_KEY_ID']}",
  "private_key": "${privateKey != '' ? privateKey : json['PRIVATE_KEY']}",
  "client_email": "${clientEmail != '' ? clientEmail : json['CLIENT_EMAIL']}",
  "client_id": "${clientId != '' ? clientId : json['CLIENT_ID']}",
  "auth_uri": "${authUri != '' ? authUri : json['AUTH_URI']}",
  "token_uri": "${tokenUri != '' ? tokenUri : json['TOKEN_URI']}",
  "auth_provider_x509_cert_url": "${authProviderX509CertUrl != '' ? authProviderX509CertUrl : json['AUTH_PROVIDER_X509_CERT_URL']}",
  "client_x509_cert_url": "${clientX509CertUrl != '' ? clientX509CertUrl : json['CLIENT_X509_CERT_URL']}",
  "universe_domain": "${universeDomain != '' ? universeDomain : json['UNIVERSE_DOMAIN']}"
}
''';

  return googleCredentials;
}
