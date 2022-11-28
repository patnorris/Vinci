// import 'package:client_flutter/helpers/helpers.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/widgets/alert_box.dart';
import 'package:client_flutter/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// import 'edit_user_profile_mutation_screen.dart';
import 'edit_user_topics_mutation_screen.dart';

/* final userTopicsByIdQuery = gql("""
  query userTopicsById(\$id: ID) {
    user(id: \$id) {
      id
      username
      selectedTopics
    }
  }
"""); */

final userTopicsByIdQuery = gql("""
  query userTopicsById(\$id: String) {
    userByLoginId(loginId: \$id) {
      id
      username
      selectedTopics
    }
  }
""");

class UserSelectedTopicsScreen extends StatelessWidget {
  final String loginId;
  final logoutAction;

  const UserSelectedTopicsScreen(
      {Key key, @required this.loginId, @required this.logoutAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user;
    return Query(
      options: QueryOptions(
        documentNode: userTopicsByIdQuery,
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
          user = User.fromJson(result.data['userByLoginId']);
          username = user.username;

          body = TabBarView(
            children: [
              UserTopicsView(
                user: user,
              ),
            ],
          );
        }

        return DefaultTabController(
          length: 1,
          child: Scaffold(
            appBar: AppBar(
              title: Text("My Vinci Topics"),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                      return EditUserTopicsMutationScreen(user: user);
                    }))).then((value) => this.build(context));
                  },
                  child: Text("Edit"),
                  shape:
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
              ],
            ),
            drawer: MenuDrawer(logoutAction: logoutAction),
            body: body,
          ),
        );
      },
    );
  }
}

class UserTopicsView extends StatelessWidget {
  final User user;

  const UserTopicsView({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic userTopics = user.selectedTopics.isEmpty
        ? 'You have not selected topics yet...'
        : user.selectedTopics;
    return Container(
      color: Colors.indigo[100],
      alignment: Alignment.topLeft,
      child: userTopics != 'You have not selected topics yet...'
          ? Material(
              color: Colors.indigo[100],
              child: ListView.builder(
                itemBuilder: (_, index) {
                  return ListTile(
                    /* leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        index.toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ), */
                    tileColor: Colors.indigo[100],
                    title: Text(
                      user.selectedTopics[index],
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    //trailing: Text("Nugget created by: ${username}"),
                  );
                },
                itemCount: user.selectedTopics.length,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(userTopics),
            ),
    );
  }
}
