import 'package:client_flutter/helpers/helpers.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/widgets/alert_box.dart';
import 'package:client_flutter/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'edit_user_profile_mutation_screen.dart';

/* final userByIdQuery = gql("""
  query userByIdQuery(\$id: ID) {
    user(id: \$id) {
      id
      username
      createdAt
      modifiedAt
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
    }
  }
""");

class UserProfileScreen extends StatelessWidget {
  final String loginId;
  final logoutAction;

  const UserProfileScreen(
      {Key key, @required this.loginId, @required this.logoutAction})
      : super(key: key);

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
              UserTextView(
                user: user,
              ),
            ],
          );
        }

        return DefaultTabController(
          length: 1,
          child: Scaffold(
            appBar: AppBar(
              title: Text("My Vinci Profile"),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                      return EditUserProfileMutationScreen(user: user);
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

class UserTextView extends StatelessWidget {
  final User user;

  const UserTextView({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.indigo[100],
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 20.0,
                    height: 1.3,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "Vinci Student since ${timestampToDate(user.createdAt)}",
                  style: TextStyle(
                    fontSize: 15.0,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
