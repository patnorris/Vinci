// import 'package:client_flutter/helpers/helpers.dart';
// import 'package:client_flutter/widgets/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:client_flutter/model/model.dart';
// import 'package:client_flutter/widgets/menu_drawer.dart';

final editUserProfileQuery = gql("""
  mutation editUserProfile(\$userId: ID!, \$username: String!) {
    editUserProfile(
      userId: \$userId
      username: \$username
    ) {
        id
      }        
  }
""");

class EditUserProfileMutationScreen extends StatelessWidget {
  final User user;

  EditUserProfileMutationScreen({Key key, @required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.indigo[100],
        appBar: AppBar(title: Text('Edit Your Profile')),
        //drawer: MenuDrawer(),
        body: _buildForm(context),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  Widget _buildForm(context) {
    return Mutation(
        options: MutationOptions(
          /// Insert mutation here
          documentNode: editUserProfileQuery,

          /// Tell the GraphQL client to fetch the data from
          /// the network only and don't cache it
          fetchPolicy: FetchPolicy.noCache,

          /// Whenever the [Form] closes, this tells the previous [route]
          /// whether it needs to rebuild itself or not
          // onCompleted: (data) => Navigator.pop(context, data != null),
          onCompleted: (data) =>
              Navigator.pushReplacementNamed(context, '/profile'),
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          formData['username'] = user.username;
          return Form(
              key: _formKey,
              child: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        initialValue: formData['username'],
                        decoration: InputDecoration(
                            labelText: 'Enter Your New Username'),
                        style: TextStyle(
                          fontSize: 20.0,
                          height: 1.3,
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'No ghost students allowed.';
                          }
                        },
                        onSaved: (String value) {
                          formData['username'] = value;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            // run mutation to update User profile in DB
                            runMutation({
                              'userId': user.id,
                              'username': formData['username'],
                            });
                          }
                        },
                        child: Text('Save Updates'),
                      ),
                    ],
                  )));
        });
  }
}
