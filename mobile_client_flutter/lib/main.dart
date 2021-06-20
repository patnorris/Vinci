import 'dart:async';
import 'dart:io';

// import 'package:client_flutter/screens/create_nugget_mutation_screen.dart';
import 'package:client_flutter/screens/user_profile_screen.dart';
import 'package:client_flutter/screens/user_saved_nuggets_screen.dart';
import 'package:client_flutter/screens/user_selected_topics_screen.dart';
import 'package:client_flutter/screens/user_stream_screen.dart';
import 'package:client_flutter/widgets/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:client_flutter/services/gql.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import 'helpers/helpers.dart';
import 'model/model.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

const AUTH0_DOMAIN = 'dev-elgwq523.us.auth0.com';
const AUTH0_CLIENT_ID = 'yUnJGOe9i9dKW7CGSAq8Xkwp9J3u6Mm5';

const AUTH0_REDIRECT_URI = 'com.nuggetsofgold.vinci://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage;
  String loginId;
  String picture;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Vinci',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          accentColor: Colors.pinkAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        //initialRoute: isLoggedIn ? '/' : '/login',
        routes: {
          '/stream': (context) =>
              UserStreamScreen(loginId: loginId, logoutAction: logoutAction),
          '/login': (context) => Login(loginAction, errorMessage),
          '/profile': (context) =>
              UserProfileScreen(loginId: loginId, logoutAction: logoutAction),
          '/saved': (context) => UserSavedNuggetsScreen(
              loginId: loginId, logoutAction: logoutAction),
          /* '/create': (context) =>
              CreateNuggetScreen(loginId: loginId, logoutAction: logoutAction), */
          '/topics': (context) => UserSelectedTopicsScreen(
              loginId: loginId, logoutAction: logoutAction),
        },
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: isBusy
                ? CircularProgressIndicator()
                : isLoggedIn
                    ? WelcomePage(logoutAction, loginId, picture)
                    : Login(loginAction, errorMessage),
          ),
        ),
      ),
    );
  }

  Map<String, Object> parseIdToken(String idToken) {
    final List<String> parts = idToken.split('.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  Future<Map<String, Object>> getUserDetails(String accessToken) async {
    const String url = 'https://$AUTH0_DOMAIN/userinfo';
    final http.Response response = await http.get(
      url,
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: 'https://$AUTH0_DOMAIN',
          scopes: <String>['openid', 'profile', 'offline_access'],
          // promptValues: ['login']
        ),
      );

      final Map<String, Object> idToken = parseIdToken(result.idToken);
      /*  idToken for Google login:
        {given_name: Patrick, family_name: Friedrich, nickname: patrick.friedrich93, 
          name: Patrick Friedrich, picture: https://lh5.googleusercontent.com/-UAaBdHivQ9s/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucn9DCr_hwzpUskwDQgr_avbSTwHIA/s96-c/photo.jpg, 
          locale: en, updated_at: 2021-04-01T03:06:27.469Z, iss: https://dev-elgwq523.us.auth0.com/, 
          sub: google-oauth2|107057757613668811456, aud: yUnJGOe9i9dKW7CGSAq8Xkwp9J3u6Mm5, 
          iat: 1617322507, exp: 1617358507}
       */
      /*  idToken for auth0 login:
        {nickname: patrick.friedrich93+auth0, name: patrick.friedrich93+auth0@googlemail.com, 
          picture: https://s.gravatar.com/avatar/86146ac050f10fb6f4dfd54bace79065?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fpa.png, 
          updated_at: 2021-04-02T00:24:50.780Z, iss: https://dev-elgwq523.us.auth0.com/, sub: auth0|606664528119600070fe2cfe, 
          aud: yUnJGOe9i9dKW7CGSAq8Xkwp9J3u6Mm5, iat: 1617323091, exp: 1617359091}
       */

      final Map<String, Object> profile =
          await getUserDetails(result.accessToken);
      /* profile for Google login:
        {sub: google-oauth2|107057757613668811456, given_name: Patrick, family_name: Friedrich, 
        nickname: patrick.friedrich93, name: Patrick Friedrich, picture: https://lh5.googleusercontent.com/-UAaBdHivQ9s/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucn9DCr_hwzpUskwDQgr_avbSTwHIA/s96-c/photo.jpg, 
        locale: en, updated_at: 2021-04-01T03:06:27.469Z}
      */
      /* profile for auth0 login:
        {sub: auth0|606664528119600070fe2cfe, nickname: patrick.friedrich93+auth0, 
        name: patrick.friedrich93+auth0@googlemail.com, picture: https://s.gravatar.com/avatar/86146ac050f10fb6f4dfd54bace79065?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fpa.png, 
        updated_at: 2021-04-02T00:24:50.780Z}
      */

      await secureStorage.write(
          key: 'refresh_token', value: result.refreshToken);
      await secureStorage.write(key: 'access_token', value: result.accessToken);

      String currentLoginId = idToken['name'];
      print('loginAction currentLoginId');
      print(currentLoginId);
      if (idToken['sub'].toString().contains('google')) {
        print('loginAction if google');
        // is login via Google and loginId needs to be constructed
        currentLoginId = idToken['nickname'].toString() + '@gmail.com';
      }
      print(currentLoginId);
      setState(() {
        isBusy = false;
        isLoggedIn = true;
        loginId = currentLoginId;
        //picture = profile['picture'];
      });
    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> logoutAction() async {
    await secureStorage.delete(key: 'refresh_token');
    await secureStorage.delete(key: 'access_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  @override
  void initState() {
    initAction();
    super.initState();
  }

  Future<void> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        // print(result);
        return;
      } else {
        return showDialog(
            //barrierColor: Colors.white.withOpacity(0),
            barrierColor: Colors.transparent,
            context: context,
            builder: (BuildContext builderContext) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text('Vinci cannot connect'),
                content: Text(
                    "Please make sure you've got an active Internet connection"),
              );
            });
      }
    } on SocketException catch (_) {
      print('not connected');
      return showDialog(
          //barrierColor: Colors.white.withOpacity(0),
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext builderContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Vinci cannot connect'),
              content: Text(
                  "Please make sure you've got an active Internet connection"),
            );
          });
    }
  }

  Future<void> initAction() async {
    final String storedRefreshToken =
        await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) return;

    setState(() {
      isBusy = true;
    });

    try {
      final TokenResponse response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      final Map<String, Object> idToken = parseIdToken(response.idToken);
      final Map<String, Object> profile =
          await getUserDetails(response.accessToken);

      await secureStorage.write(
          key: 'refresh_token', value: response.refreshToken);
      await secureStorage.write(
          key: 'access_token', value: response.accessToken);

      String currentLoginId = idToken['name'];
      print('initAction currentLoginId');
      print(currentLoginId);
      if (idToken['sub'].toString().contains('google')) {
        print('initAction if google');
        // is login via Google and loginId needs to be constructed
        currentLoginId = idToken['nickname'].toString() + '@gmail.com';
      }
      print(currentLoginId);
      setState(() {
        isBusy = false;
        isLoggedIn = true;
        loginId = currentLoginId;
        //picture = profile['picture'];
      });
    } on Exception catch (e, s) {
      debugPrint('error on refresh token: $e - stack: $s');
      await logoutAction();
    }
  }
}

class Login extends StatelessWidget {
  final loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo[100],
        appBar: AppBar(
          centerTitle: true,
          title: Text('Welcome to Vinci'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50.0,
            ),
            Container(
              height: 200.0,
              child: Image(
                image: AssetImage('assets/images/Vinci_logo_version1.png'),
              ),
            ),
            Container(
              height: 75.0,
            ),
            ElevatedButton(
              onPressed: () {
                loginAction();
              },
              child: Text('Login'),
            ),
            Text(loginError ??
                "Please make sure you're connected to the Internet"),
          ],
        )));
  }
}

final userByLoginIdQuery = gql("""
  query userByLoginId(\$id: String) {
    userByLoginId(loginId: \$id) {
      id
      username
      createdAt
    }
  }
""");

class WelcomePage extends StatefulWidget {
  final logoutAction;
  final String loginId;
  final String picture;

  WelcomePage(this.logoutAction, this.loginId, this.picture);

  @override
  WelcomePageState createState() =>
      WelcomePageState(logoutAction: logoutAction, loginId: loginId);
}

int streamIndex = 0;

class WelcomePageState extends State<WelcomePage> {
  final logoutAction;
  final String loginId;

  WelcomePageState({
    @required this.logoutAction,
    @required this.loginId,
  });

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user;
    return Query(
        options: QueryOptions(
          documentNode: userByLoginIdQuery,
          variables: {
            'id': loginId,
          },
        ),
        builder: (
          QueryResult result, {
          Future<QueryResult> Function() refetch,
          FetchMore fetchMore,
        }) {
          Widget body;
          if (result.hasException) {
            return AlertBox(
              type: AlertType.error,
              text: result.exception.toString(),
              onRetry: () => refetch(),
            );
          } else if (result.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            print('WelcomePageState result.data');
            print(result.data);
            if (result.data['userByLoginId'] != null) {
              user = User.fromJson(result.data['userByLoginId']);
              if (user != null) {
                return UserStreamScreen(
                    loginId: loginId, logoutAction: logoutAction);
              }
            } else {
              print('WelcomePageState new user');
              // new user; initiate sign up flow
              body = CreateUserProfileMutationScreen(loginId: loginId);

              return Scaffold(
                backgroundColor: Colors.indigo[100],
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: Text("Welcome to Vinci"),
                ),
                body: body,
              );
            }
          }
        });
  }
}

final createUserProfileQuery = gql("""
  mutation createUserProfile(\$loginId: String!, \$username: String!, \$topics: [String]) {
    addUser(
      loginId: \$loginId
      username: \$username
      topics: \$topics
    ) {
        id
      }        
  }
""");

class CreateUserProfileMutationScreen extends StatelessWidget {
  final String loginId;

  CreateUserProfileMutationScreen({Key key, @required this.loginId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final Map<String, dynamic> formData = {};
    return Mutation(
        options: MutationOptions(
          /// Insert mutation here
          documentNode: createUserProfileQuery,

          /// Tell the GraphQL client to fetch the data from
          /// the network only and don't cache it
          fetchPolicy: FetchPolicy.noCache,

          /// Whenever the [Form] closes, this tells the previous [route]
          /// whether it needs to rebuild itself or not
          // onCompleted: (data) => Navigator.pop(context, data != null),
          onCompleted: (data) =>
              Navigator.pushReplacementNamed(context, '/stream'),
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          print('CreateUserProfileMutationScreen');
          List<String> availableTopics = getAvailableTopics();
          final _items = availableTopics
              .map((topic) => MultiSelectItem<String>(topic, topic))
              .toList();
          List<String> selectedTopics = [];
          final _multiSelectKey = GlobalKey<FormFieldState>();
          return Form(
              key: _formKey,
              child: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Let\'s Create Your Vinci Account!'),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Enter Your Username'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'No ghost students allowed.';
                          }
                        },
                        onSaved: (String value) {
                          formData['username'] = value;
                        },
                      ),
                      MultiSelectBottomSheetField<String>(
                        key: _multiSelectKey,
                        initialChildSize: 0.7,
                        maxChildSize: 0.95,
                        title: Text("Topics"),
                        buttonText: Text("Topics I'm Interested In"),
                        initialValue: selectedTopics,
                        items: _items,
                        searchable: true,
                        validator: (values) {
                          /* if (values == null || values.isEmpty) {
                            return """If you don't select any specific topics, Vinci will 
provide you a mix of everything worth learning""";
                          } */
                          List<String> topics = values.toList();
                          if (topics.contains("Random")) {
                            return "Random: a portion of Your Nuggets will be a random mix";
                          }
                          return null;
                        },
                        onConfirm: (values) {
                          /* setState(() {
                          selectedTopics = values;
                        }); */
                          selectedTopics = values;
                          _multiSelectKey.currentState.validate();
                        },
                        chipDisplay: MultiSelectChipDisplay(
                            /* onTap: (item) { //does not work properly with initialValue
                          setState(() {
                            selectedTopics.remove(item);
                          });
                          _multiSelectKey.currentState.validate();
                        }, */
                            ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            // run mutation to create User profile in DB
                            print('before creating user loginId');
                            print(loginId);
                            print(formData['username']);
                            print(selectedTopics);
                            runMutation({
                              'loginId': loginId,
                              'username': formData['username'],
                              'topics': selectedTopics,
                            });
                          }
                        },
                        child: Text('Get Started'),
                      ),
                    ],
                  )));
        });
  }
}
