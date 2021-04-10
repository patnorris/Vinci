import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/widgets/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:client_flutter/helpers/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

final nuggetByIdQuery = gql("""
  query nuggetById(\$id: ID) {
    nugget(id: \$id) {
      id
      createdBy {
        username
      }
      nuggetType
      content
      metaInfo
      createdAt
      modifiedAt
      topics
    }
  }
""");

final removeSavedNuggetQuery = gql("""
  mutation removeSavedNugget(\$userId: ID!, \$nuggetId: ID!) {
    removeSavedNugget(
      userId: \$userId
      nuggetId: \$nuggetId
    ) {
        id
      }        
  }
""");

class NuggetDetailScreen extends StatelessWidget {
  final String nuggetId;
  final String userId;

  const NuggetDetailScreen(
      {Key key, @required this.nuggetId, @required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Nugget nugget;
    return Mutation(
        options: MutationOptions(
          /// Insert mutation here
          documentNode: removeSavedNuggetQuery,

          /// Tell the GraphQL client to fetch the data from
          /// the network only and don't cache it
          fetchPolicy: FetchPolicy.noCache,

          /// Whenever the [Form] closes, this tells the previous [route]
          /// whether it needs to rebuild itself or not
          // onCompleted: (data) => Navigator.pop(context, data != null),
          onCompleted: (data) =>
              Navigator.pushReplacementNamed(context, '/saved'),
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          return Query(
            options: QueryOptions(
              documentNode: nuggetByIdQuery,
              variables: {
                'id': nuggetId,
              },
            ),
            builder: (
              QueryResult result, {
              Future<QueryResult> Function() refetch,
              FetchMore fetchMore,
            }) {
              Widget body;

              if (result.hasException) {
                print('exception in NuggetDetailScreen');
                print(result.exception.toString());
              } else if (result.loading) {
                body = const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                nugget = Nugget.fromJson(result.data['nugget']);

                body = SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NuggetDetailView(
                      nugget: nugget,
                    ),
                  ],
                ));
              }

              return DefaultTabController(
                length: 1,
                child: Scaffold(
                  backgroundColor: Colors.indigo[100],
                  appBar: AppBar(
                    title: Text("Nugget Details"),
                    actions: <Widget>[
                      // only creator can delete
                      //if (userId == '604d9b2ddefde04478d94e7a') //TODO: replace '604d9b2ddefde04478d94e7a' with viewerId
                      FlatButton(
                        textColor: Colors.white,
                        onPressed: () {
                          runMutation({
                            'userId': userId,
                            'nuggetId': nuggetId,
                          });
                        },
                        child: Text("Remove This Nugget from My Saved Nuggets"),
                        shape: CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ],
                  ),
                  body: body,
                ),
              );
            },
          );
        });
  }
}

class NuggetDetailView extends StatelessWidget {
  final Nugget nugget;

  const NuggetDetailView({
    Key key,
    @required this.nugget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var username =
        nugget.createdBy != null ? nugget.createdBy.username : 'Algo';
    String nuggetTopics = nugget.topics.isEmpty
        ? 'This nugget is not categorized by topic yet...'
        : nugget.topics.join(', ');
    return Padding(
      padding: EdgeInsets.all(14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nugget Type: ${nugget.nuggetType}",
            style: TextStyle(
              fontSize: 15.0,
              height: 1.5,
            ),
          ),
          Text(
            "Created by ${username} on ${timestampToDate(nugget.createdAt)}",
            style: TextStyle(
              fontSize: 15.0,
              height: 1.5,
              //fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            "Topics: ${nuggetTopics}",
            style: TextStyle(
              fontSize: 13.0,
              height: 1.3,
            ),
          ),
          TextButton(
            onPressed: () {
              launch(nugget.metaInfo);
            },
            child: Text("Info: ${nugget.metaInfo}"),
          ),
          Center(
              child: Container(
                  //height: MediaQuery.of(context).size.height * 0.9,
                  //width: MediaQuery.of(context).size.width * 0.9,
                  child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                nugget.nuggetType.contains("TEXT")
                    ? Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text(
                          nugget.content,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            height: 1.3,
                          ),
                        ))
                    : nugget.nuggetType.contains("IMAGE")
                        //? Image.memory(BASE64.decode(user.stream.nuggets[index].content))
                        ? Expanded(
                            child: Image.asset("assets/images/vinci.png"),
                          ) //TODO
                        : nugget.nuggetType.contains("VIDEO")
                            ? Expanded(
                                child: Image.asset("assets/images/vinci.png"),
                              ) //TODO
                            : Text('So little we know, so eager to learn'),
              ],
            ),
          )))
        ],
      ),
    );
  }
}
