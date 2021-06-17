import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/widgets/alert_box.dart';
import 'package:client_flutter/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:client_flutter/services/flutter_tindercard.dart';
import 'package:graphql/client.dart';

/* final userByIdQuery = gql("""
  query userByIdQuery(\$id: ID) {
    user(id: \$id) {
      id
      username
      createdAt
      modifiedAt
      stream {
        id
        nuggets {
          id
          nuggetType
          content
          metaInfo
        }
      }
    }
  }
"""); */

final userByLoginIdQuery = gql("""
  query userByLoginId(\$id: String) {
    userByLoginId(loginId: \$id) {
      id
      username
      createdAt
      modifiedAt
      stream {
        id
        nuggets {
          id
          nuggetType
          content
          metaInfo
        }
      }
    }
  }
""");

final saveNuggetForUserQuery = gql("""
  mutation saveNuggetForUser(\$userId: ID!, \$nuggetId: ID!) {
    saveNuggetForUser(
      userId: \$userId
      nuggetId: \$nuggetId
    ) {
        id
      }        
  }
""");

final markNuggetSeenForUserQuery = gql("""
  mutation markNuggetSeenForUser(\$userId: ID!, \$nuggetId: ID!) {
    markNuggetSeenForUser(
      userId: \$userId
      nuggetId: \$nuggetId
    ) {
        id
      }        
  }
""");

final likeNuggetForUserQuery = gql("""
  mutation likeNuggetForUser(\$userId: ID!, \$nuggetId: ID!) {
    likeNuggetForUser(
      userId: \$userId
      nuggetId: \$nuggetId
    ) {
        id
      }        
  }
""");

class UserStreamScreen extends StatelessWidget {
  final String loginId;
  final logoutAction;

  const UserStreamScreen(
      {Key key, @required this.loginId, @required this.logoutAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user;
    return Query(
      options: QueryOptions(
        //fetchPolicy: FetchPolicy.noCache,
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
        String username = '';

        FetchMoreOptions opts = FetchMoreOptions(
          //variables: {'cursor': fetchMoreCursor},
          updateQuery: (previousResultData, fetchMoreResultData) {
            // this is where you combine your previous data and response
            // in this case, we want to display previous repos plus next repos
            // so, we combine data in both into a single list of repos
            final List<dynamic> nuggets = [
              ...previousResultData['userByLoginId']['stream']['nuggets']
                  as List<dynamic>,
              ...fetchMoreResultData['userByLoginId']['stream']['nuggets']
                  as List<dynamic>
            ];

            // to avoid alot of work, lets just update the list of repos in returned
            // data with new data, this also ensure we have the endCursor already set
            // correctlty
            fetchMoreResultData['userByLoginId']['stream']['nuggets'] = nuggets;

            return fetchMoreResultData;
          },
        );
        print('UserStreamScreen');
        if (result.hasException) {
          body = AlertBox(
            type: AlertType.error,
            text: result.exception.toString(),
            onRetry: () => refetch(),
          );
        } else if (result.loading) {
          body = const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          print('UserStreamScreen result.data');
          print(result.data);
          user = User.fromJson(result.data['userByLoginId']);
          //final Map pageInfo = result.data['pageInfo'];
          //print(result.data);
          //print(result.data['user']['stream']['nuggets'].length);
          username = user.username;

          body = TabBarView(
            children: [
              UserStreamView(
                  user: user, fetchMore: fetchMore, fetchMoreOptions: opts),
            ],
          );
        }

        return DefaultTabController(
          length: 1,
          child: Scaffold(
            appBar: AppBar(
              title: Text("My Vinci Stream"),
              /* actions: <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                      return EditUserProfileMutationScreen(
                          user: user);
                    }))).then((value) => this.build(context));
                  },
                  child: Text("Edit Your Profile"),
                  shape:
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
              ], */
            ),
            drawer: MenuDrawer(logoutAction: logoutAction),
            body: body,
          ),
        );
      },
    );
  }
}

class UserStreamView extends StatefulWidget {
  final User user;
  final FetchMore fetchMore;
  final FetchMoreOptions fetchMoreOptions;

  const UserStreamView({
    Key key,
    @required this.user,
    @required this.fetchMore,
    @required this.fetchMoreOptions,
  }) : super(key: key);

  @override
  _UserStreamViewState createState() => _UserStreamViewState(
      user: user, fetchMore: fetchMore, fetchMoreOptions: fetchMoreOptions);
}

int streamIndex = 0;

class _UserStreamViewState extends State<UserStreamView>
    with TickerProviderStateMixin {
  User user;
  FetchMore fetchMore;
  FetchMoreOptions fetchMoreOptions;
  StreamController<List<Nugget>> _streamController;
  //int streamIndex;

  _UserStreamViewState(
      {@required this.user,
      @required this.fetchMore,
      @required this.fetchMoreOptions});

  @override
  initState() {
    super.initState();
    _streamController = StreamController<List<Nugget>>();
    //streamIndex = 0;
    //_streamController = StreamController<List<Nugget>>.broadcast();
  }

  @override
  Widget build(BuildContext context) {
    List<String> welcomeImages = [
      "assets/images/foxhood.png",
      "assets/images/grandstack.png",
      "assets/images/vinci.png",
    ];
    CardController controller; //Use this to trigger swap.
    //String mutationToRun = '';
    //int streamIndex = 0;
    if (streamIndex > user.stream.nuggets.length) {
      //print('if streamIndex ${streamIndex}');
      //print('if length ${user.stream.nuggets.length}');
      streamIndex = 0;
    }

    return new Scaffold(
        //backgroundColor: Colors.black.withOpacity(0.15),
        backgroundColor: Colors.indigo[100],
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            //width: MediaQuery.of(context).size.width * 0.9,
            child: StreamBuilder<List<Nugget>>(
              stream: _streamController.stream,
              initialData: user.stream.nuggets.sublist(streamIndex),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Nugget>> snapshot) {
                //print('snapshot.data.length: ${snapshot.data.length}');
                //print('StreamBuilder nuggets length ${user.stream.nuggets.length}');
                //print(snapshot.data);
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  /* print('ConnectionState.none');
                          return Text('No nuggets in stream'); */
                  case ConnectionState.waiting:
                  /*  print('ConnectionState.waiting');
                          return Text('Waiting'); */
                  case ConnectionState.active:
                    //print('ConnectionState.active');
                    return new TinderSwapCard(
                      swipeUp: true,
                      swipeDown: true,
                      orientation: AmassOrientation.bottom,
                      //totalNum: user.stream.nuggets.length,
                      //stackNum: user.stream.nuggets.length,
                      totalNum: snapshot.data.length,
                      stackNum: snapshot.data.length,
                      swipeEdge: 3.0,
                      maxWidth: MediaQuery.of(context).size.width * 0.95,
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                      minWidth: MediaQuery.of(context).size.width * 0.85,
                      minHeight: MediaQuery.of(context).size.height * 0.8,
                      cardBuilder: (context, index) {
                        //print('cardBuilder index ${index}');
                        return GestureDetector(
                          onDoubleTap: () {
                            //print('Double Tap');
                            //print(snapshot.data[index].metaInfo);
                            launch(snapshot.data[index].metaInfo);
                            /* if (canLaunch(snapshot.data[index].metaInfo != false)) {
                                launch(snapshot.data[index].metaInfo);
                              } else {
                                print('Could open source');
                              } */
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                                child: SingleChildScrollView(
                                    child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                snapshot.data[index].nuggetType.contains("TEXT")
                                    ? Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text(
                                          snapshot.data[index].content,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                            height: 1.3,
                                          ),
                                        ))
                                    : snapshot.data[index].nuggetType
                                            .contains("IMAGE")
                                        //? Image.memory(BASE64.decode(user.stream.nuggets[index].content))
                                        ? Expanded(
                                            child: Image.asset(
                                                '${welcomeImages[0]}'),
                                          ) //TODO
                                        : snapshot.data[index].nuggetType
                                                .contains("VIDEO")
                                            ? Expanded(
                                                child: Image.asset(
                                                    '${welcomeImages[0]}'),
                                              ) //TODO
                                            : Text(
                                                'So little we know, so eager to learn'),
                              ],
                            ))),
                          ),
                        );
                      },
                      cardController: controller = CardController(),
                      swipeUpdateCallback:
                          (DragUpdateDetails details, Alignment align) {
                        /// Get swiping card's alignment
                        /// potentially show icons (save on bottom, share on top, like on right, next on left)
                        if (align.x < 0) {
                          //print("Card is LEFT swiping");
                        } else if (align.x > 0) {
                          //print("Card is RIGHT swiping");
                        }
                      },
                      swipeCompleteCallback:
                          (CardSwipeOrientation orientation, int index) {
                        //print(orientation.toString());
                        if (orientation == CardSwipeOrientation.left) {
                          //print("LEFT swipe: next");
                          Timer _timer;
                          // save to User's Seen Nuggets
                          showDialog(
                              //barrierColor: Colors.white.withOpacity(0),
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext builderContext) {
                                _timer = Timer(Duration(seconds: 0), () {
                                  Navigator.of(context).pop();
                                });
                                return Opacity(
                                  child: AlertDialog(
                                    backgroundColor: Colors.white,
                                    //title: Text('Nugget Saved!'),
                                    content: NextNuggetMutation(
                                      userId: user.id,
                                      nuggetId: snapshot.data[index].id,
                                      userLikedNugget: false,
                                    ),
                                  ),
                                  opacity: 0,
                                );
                              }).then((val) {
                            if (_timer.isActive) {
                              _timer.cancel();
                            }
                            streamIndex++;
                            //print('streamIndex ${streamIndex}');
                            if (snapshot.data.length - index < 6) {
                              //print('index ${index}');
                              fetchMore(fetchMoreOptions);
                            }
                          });
                          /* user.stream.nuggets.removeAt(index);
                      _streamController.add(user.stream.nuggets); */
                        } else if (orientation == CardSwipeOrientation.right) {
                          //print("RIGHT swipe: like (and next)");
                          Timer _timer;
                          // save to User's Seen Nuggets and Liked Nuggets
                          showDialog(
                              //barrierColor: Colors.white.withOpacity(0),
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext builderContext) {
                                _timer = Timer(Duration(seconds: 0), () {
                                  Navigator.of(context).pop();
                                });
                                return Opacity(
                                  child: AlertDialog(
                                    backgroundColor: Colors.white,
                                    //title: Text('Nugget Saved!'),
                                    content: NextNuggetMutation(
                                      userId: user.id,
                                      nuggetId: snapshot.data[index].id,
                                      userLikedNugget: true,
                                    ),
                                  ),
                                  opacity: 0,
                                );
                              }).then((val) {
                            if (_timer.isActive) {
                              _timer.cancel();
                            }
                            streamIndex++;
                            if (snapshot.data.length - index < 6) {
                              //print('index ${index}');
                              fetchMore(fetchMoreOptions);
                            }
                          });
                          /* user.stream.nuggets.removeAt(index);
                      _streamController.add(user.stream.nuggets); */
                        } else if (orientation == CardSwipeOrientation.down) {
                          //print("DOWN swipe: save");
                          Timer _timer;
                          // save to User's Saved Nuggets
                          showDialog(
                              //barrierColor: Colors.white.withOpacity(0),
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext builderContext) {
                                _timer = Timer(Duration(seconds: 1), () {
                                  Navigator.of(context).pop();
                                });
                                return Opacity(
                                  child: AlertDialog(
                                    backgroundColor: Colors.white,
                                    //title: Text('Nugget Saved!'),
                                    content: SaveNuggetMutation(
                                        userId: user.id,
                                        nuggetId: snapshot.data[index].id),
                                  ),
                                  opacity: 0.8,
                                );
                              }).then((val) {
                            if (_timer.isActive) {
                              _timer.cancel();
                            }
                            streamIndex++;
                            if (snapshot.data.length - index < 6) {
                              //print('index ${index}');
                              fetchMore(fetchMoreOptions);
                            }
                          });
                          /* user.stream.nuggets.removeAt(index);
                      _streamController.add(user.stream.nuggets); */
                        } else if (orientation == CardSwipeOrientation.up) {
                          //print("UP swipe: share");
                          streamIndex++;
                          if (snapshot.data.length - index < 6) {
                            //print('index ${index}');
                            fetchMore(fetchMoreOptions);
                          }
                          /* user.stream.nuggets.removeAt(0);
                      _streamController.add(user.stream.nuggets); */
                        } else if (orientation ==
                            CardSwipeOrientation.recover) {
                          //print("RECOVER: not fully swiped into one direction");
                          //print('index ${index}');
                        }
                      },
                    );
                  case ConnectionState.done:
                    print('ConnectionState.done');
                    return Text('\$${snapshot.data} (closed)');
                }
                return null;
              },
            ),
          ),
        ));
  }
}

class SaveNuggetMutation extends StatelessWidget {
  final String userId;
  final String nuggetId;

  SaveNuggetMutation({Key key, @required this.userId, @required this.nuggetId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.1,
      child: _buildForm(context),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  Widget _buildForm(context) {
    return Mutation(
        options: MutationOptions(
          /// Insert mutation here
          documentNode: saveNuggetForUserQuery,

          /// Tell the GraphQL client to fetch the data from
          /// the network only and don't cache it
          fetchPolicy: FetchPolicy.noCache,

          /// Whenever the [Form] closes, this tells the previous [route]
          /// whether it needs to rebuild itself or not
          //onCompleted: (data) => Navigator.pop(context, data != null),
          /* onCompleted: (dynamic resultData) {
            //print('onCompleted');
            //print(resultData);
            return resultData;
          }, */
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          runMutation({
            'userId': userId,
            'nuggetId': nuggetId,
          });
          return Text('Nugget Saved!');
        });
  }
}

class NextNuggetMutation extends StatelessWidget {
  final String userId;
  final String nuggetId;
  final bool
      userLikedNugget; //true corresponds to right swipe, false to left swipe

  NextNuggetMutation(
      {Key key,
      @required this.userId,
      @required this.nuggetId,
      @required this.userLikedNugget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.1,
      child: _buildForm(context),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  Widget _buildForm(context) {
    return Mutation(
        options: MutationOptions(
          /// Insert mutation here
          documentNode: userLikedNugget
              ? likeNuggetForUserQuery
              : markNuggetSeenForUserQuery,

          /// Tell the GraphQL client to fetch the data from
          /// the network only and don't cache it
          fetchPolicy: FetchPolicy.noCache,

          /// Whenever the [Form] closes, this tells the previous [route]
          /// whether it needs to rebuild itself or not
          //onCompleted: (data) => Navigator.pop(context, data != null),
          /* onCompleted: (dynamic resultData) {
            //print('onCompleted');
            //print(resultData);
            return resultData;
          }, */
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          runMutation({
            'userId': userId,
            'nuggetId': nuggetId,
          });
          return Text('Nugget Processed');
        });
  }
}
