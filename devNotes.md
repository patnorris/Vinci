run on Android emulator: https://flutter.dev/docs/get-started/install/windows


https://stackoverflow.com/questions/61104843/how-to-create-tinder-like-stacked-cards-in-flutter
https://github.com/ShaunRain/flutter_tindercard/tree/master/example/example

https://github.com/ShaunRain/flutter_tindercard/blob/master/example/async_data/lib/main.dart

run mutation from a popup that closes itself automatically after 1 sec (e.g. Nugget Saved!):
https://stackoverflow.com/questions/61307264/autoclose-dialog-in-flutter

Wikipedia random article:
https://github.com/jimkang/get-random-article/blob/master/get-random-article.js

Fetch more/Pagination:
https://pub.dev/packages/graphql_flutter
https://github.com/mainawycliffe/graphql-flutter/blob/fetchmore/packages/graphql_flutter/example/lib/fetchmore/main.dart
https://github.com/mainawycliffe/graphql-flutter/blob/fetchmore/packages/graphql_flutter/example/lib/graphql_operation/queries/readRepositories.dart
https://sayasuhendra.github.io/graphql-js/11-pagination/
https://javascript.plainenglish.io/graphql-pagination-using-edges-vs-nodes-in-connections-f2ddb8edffa0
https://buddy.works/tutorials/how-to-implement-pagination-and-mutation-in-graphql

Topic selection (also has search functionality):
https://pub.dev/packages/multi_select_flutter
https://github.com/CHB61/multi_select_flutter/blob/master/example/lib/main.dart

https://en.wikipedia.org/wiki/Wikipedia:Contents/Categories
start with "Category:"
https://en.wikipedia.org/wiki/Category:Investment --> stopped at 273
https://en.wikipedia.org/wiki/Category:Personal_development --> stopped at 99
https://en.wikipedia.org/wiki/Category:Life_extension --> stopped at 48
https://en.wikipedia.org/wiki/Category:Design --> stopped at 235

Authentication (Android, iOS): https://auth0.com/blog/get-started-with-flutter-authentication/
web callback: https://github.com/dart-lang/oauth2/issues/88
https://robinjanke1.medium.com/oauth2-with-flutter-web-e7a2b0dac7f3
https://github.com/RasmusSlothJensen/oauth_sample
https://pub.dev/packages/flutter_web_auth
Secure API: https://auth0.com/blog/build-and-secure-a-graphql-server-with-node-js/
https://github.com/auth0/express-openid-connect/blob/master/examples/userinfo.js
https://flutter.dev/docs/cookbook/networking/authenticated-requests
/userinfo: https://auth0.com/docs/api/authentication?_ga=2.250872963.402995406.1617590564-2052420166.1617590564#change-password
Requesting and passing JWT to the GraphQL Server: https://auth0.com/blog/build-and-secure-a-graphql-server-with-node-js/
context in ApolloServer: https://www.apollographql.com/docs/apollo-server/data/resolvers/#the-context-argument
get request nodejs: https://www.twilio.com/blog/5-ways-to-make-http-requests-in-node-js-using-async-await
pass authorization header in flutter: https://github.com/zino-app/graphql-flutter/issues/47


secure storage: https://pub.dev/documentation/flutter_secure_storage/latest/
use for current stream index (and nuggets if needed)

Welcome Nugget Ids:
"6068ee5ea2fb59441c185003"
"6068f120a2fb59441c185004"

deploy node: https://www.heroku.com/pricing
https://www.ibm.com/cloud/free
https://www.netlify.com/pricing/?_ga=2.208757906.140979262.1564051008-762061351.1564051008
https://devcenter.heroku.com/articles/deploying-nodejs
https://devcenter.heroku.com/articles/getting-started-with-nodejs
https://github.com/heroku/node-js-getting-started
https://devcenter.heroku.com/categories/nodejs-support
https://devcenter.heroku.com/articles/preparing-a-codebase-for-heroku-deployment
make folder a git repo: https://devcenter.heroku.com/articles/git
remove env var file from git: https://stackoverflow.com/questions/43762338/how-to-remove-file-from-git-history
local node env var: https://www.twilio.com/blog/working-with-environment-variables-in-node-js-html
heroku env var: https://devcenter.heroku.com/articles/config-vars
heroku app needs to use auto-set PORT env var: https://devcenter.heroku.com/articles/dynos#local-environment-variables

load to phone: https://stackoverflow.com/questions/54444538/how-do-i-run-test-my-flutter-app-on-a-real-device
https://flutter-examples.com/run-test-flutter-apps-directly-on-real-android-device/
release build: https://flutter.dev/docs/deployment/android
run release mode: https://stackoverflow.com/questions/56179353/app-running-on-debug-mode-only-for-flutter

Sometimes nugget scrolls down automatically:
scrollview keeps the scroll value from previous nugget, e.g. on nugget 1 user scrolled til the bottom, then swipes away, nugget 2 will start at the same offset
--> reset scroll value for each new nugget, i.e. after swipe
https://www.codegrepper.com/code-examples/dart/how+to+stop+auto+scroll+listview+flutter: physics: NeverScrollableScrollPhysics()
https://github.com/flutter/flutter/issues/50713: showCursor: false, allowImplicitScrolling: false
https://github.com/flutter/flutter/issues/27887: use _scrollController.jumpTo(_scrollController.position.minScrollExtent);
https://www.google.com/search?q=flutter+access+primary+scrollcontroller&ei=CiXqYN-kGIHEsAX27LvIDA&oq=flutter+access+primary+scrollcontroller&gs_lcp=Cgdnd3Mtd2l6EAM6BwgAEEcQsAM6BwgAELADEEM6BAgAEA06BAghEAo6BQgAEM0CSgQIQRgAUJm2UVihylFg98tRaANwAngAgAGIAogBmxKSAQYzLjEwLjOYAQCgAQGqAQdnd3Mtd2l6yAEKwAEB&sclient=gws-wiz&ved=0ahUKEwjf0cedzNnxAhUBIqwKHXb2DskQ4dUDCA4&uact=5

example for class in flutter:
class Animal {
  final int id;
  final String name;

  Animal({
    this.id,
    this.name,
  });
}
static List<Animal> _animals = [
    Animal(id: 1, name: "Lion"),
    Animal(id: 2, name: "Flamingo"),
  ];

upgrading flutter (attempted on 2022-11-28):
requires changing deprecated elements (e.g. FlatButton)
requires platform dependency
requires updating Android
probably (potentially many) more changes required as many files had many red highlights
