import 'package:client_flutter/widgets/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/widgets/menu_drawer.dart';

import 'nugget_detail_screen.dart';

/* final getSavedNuggetsForUserQuery = gql("""
  query getSavedNuggetsForUser(\$userId: ID) {
    user(id: \$userId) {
      id
      username
      savedNuggets {
        id
        nuggetType
        createdBy {
          username
        }
      }
    }  
  }
"""); */

final getSavedNuggetsForUserQuery = gql("""
  query getSavedNuggetsForUser(\$loginId: String) {
    userByLoginId(loginId: \$loginId) {
      id
      username
      savedNuggets {
        id
        nuggetType
        content
      }
    }  
  }
""");

class UserSavedNuggetsScreen extends StatelessWidget {
  final String loginId;
  final logoutAction;

  const UserSavedNuggetsScreen(
      {Key key, @required this.loginId, @required this.logoutAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Saved Nuggets'),
      ),
      drawer: MenuDrawer(logoutAction: logoutAction),
      body: Query(
        options: QueryOptions(
          documentNode: getSavedNuggetsForUserQuery,
          variables: {
            'loginId': loginId,
          },
        ),
        builder: (
          QueryResult result, {
          Future<QueryResult> Function() refetch,
          FetchMore fetchMore,
        }) {
          if (result.hasException) {
            return AlertBox(
              type: AlertType.error,
              text: result.exception.toString(),
              onRetry: () => refetch(),
            );
          }

          if (result.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          //print(result.data);
          final User user = User.fromJson(result.data['userByLoginId']);

          if (user.savedNuggets.length == 0) {
            return AlertBox(
              type: AlertType.info,
              text:
                  'No nuggets saved yet. Why not go to your stream right now and save the first one that interests you? You can save a nugget by swiping it down.',
              onRetry: refetch,
            );
          }
          return RefreshIndicator(
            onRefresh: () => refetch(),
            child: Material(
              color: Colors.indigo[100],
              child: ListView.builder(
                itemBuilder: (_, index) {
                  var content = user.savedNuggets[index].content != null
                      ? user.savedNuggets[index].content
                      : '';
                  return ListTile(
                    //tileColor: Colors.indigo[100],
                    //hoverColor: Colors.indigo[100],
                    //selectedTileColor: Colors.indigo[100],
                    leading: CircleAvatar(
                      //backgroundColor: Theme.of(context).primaryColorLight,
                      backgroundColor: Colors.indigo[200],
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    title: Text(user.savedNuggets[index].nuggetType),
                    trailing: Text(content.length <= 36
                        ? content
                        : content.substring(0, 30)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NuggetDetailScreen(
                              nuggetId: user.savedNuggets[index].id,
                              userId: user.id),
                        ),
                      );
                    },
                  );
                },
                itemCount: user.savedNuggets.length,
              ),
            ),
          );
        },
      ),
    );
  }
}
