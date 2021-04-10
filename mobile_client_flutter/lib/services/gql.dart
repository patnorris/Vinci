import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

final String host = kIsWeb
    ? 'localhost'
    : Platform.isAndroid
        ? '10.0.2.2'
        : 'localhost';

/* String getCurrentAccessToken() {
  var accessToken = await secureStorage.read(key: 'access_token');
  return accessToken;
}

var accessToken = await secureStorage.read(key: 'access_token'); */

Future<String> getCurrentAccessToken() async {
  var accessToken = await secureStorage.read(key: 'access_token');
  return accessToken;
  /* return {
    'Authorization': 'Bearer $accessToken',
  }; */
}

final AuthLink authLink = AuthLink(
  getToken: () async =>
      'Bearer ${await secureStorage.read(key: 'access_token')}',
);

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: InMemoryCache(),
    link: authLink.concat(HttpLink(
      uri: 'http://$host:4001/graphql',
      /* headers: <String, String>{
        'Authorization': 'Bearer ${}',
      }, */
    )),
  ),
);
