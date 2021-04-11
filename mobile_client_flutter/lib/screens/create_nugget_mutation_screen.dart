import 'package:client_flutter/helpers/helpers.dart';
import 'package:client_flutter/widgets/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/widgets/menu_drawer.dart';

final createNuggetQuery = gql("""
  mutation createNugget(\$creatorId: String!, \$nuggetType: NuggetTypeEnum!, \$content: String!, \$source: String!, \$topic: String!) {
    createNugget(
      creatorId: \$creatorId
      nuggetType: \$nuggetType
      content: \$content
      source: \$source
      topic: \$topic
    ) {
        id
      }        
  }
""");

class CreateNuggetScreen extends StatelessWidget {
  final String loginId;
  final logoutAction;

  CreateNuggetScreen(
      {Key key, @required this.loginId, @required this.logoutAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.indigo[100],
        resizeToAvoidBottomInset: false,
        appBar:
            AppBar(title: Text('Create a New Nugget to Share Your Learnings')),
        drawer: MenuDrawer(logoutAction: logoutAction),
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
          documentNode: createNuggetQuery,

          /// Tell the GraphQL client to fetch the data from
          /// the network only and don't cache it
          fetchPolicy: FetchPolicy.noCache,

          /// Whenever the [Form] closes, this tells the previous [route]
          /// whether it needs to rebuild itself or not
          // onCompleted: (data) => Navigator.pop(context, data != null),
          onCompleted: (data) =>
              Navigator.pushReplacementNamed(context, '/create'),
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          return Form(
              key: _formKey,
              child: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      DropdownButtonFormField<NuggetTypeEnum>(
                        decoration: InputDecoration(
                            labelText: 'Select the Nugget Type',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1.0))),
                        value: formData['nuggetType'],
                        isDense: true,
                        validator: (value) {
                          if (!NuggetTypeEnum.values.contains(value)) {
                            return 'If in doubt, it\'s TEXT';
                          }
                        },
                        onChanged: (NuggetTypeEnum newValue) {
                          formData['nuggetType'] = newValue;
                        },
                        items: NuggetTypeEnum.values.map((NuggetTypeEnum type) {
                          return DropdownMenuItem<NuggetTypeEnum>(
                            value: type,
                            child: Text(prettifyEnumString(enumToString(type))),
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Enter the Nugget\'s Insight'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Looking for some Insight here.';
                          }
                        },
                        onSaved: (String value) {
                          formData['content'] = value;
                        },
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Enter the Source'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Who can be credited with this Knowledge?';
                          }
                        },
                        onSaved: (String value) {
                          formData['source'] = value;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            labelText: 'Select the Topic',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1.0))),
                        value: formData['topic'],
                        isDense: true,
                        validator: (value) {
                          if (!getAvailableTopics().contains(value)) {
                            return 'If in doubt, it\'s Random';
                          }
                        },
                        onChanged: (String newValue) {
                          formData['topic'] = newValue;
                        },
                        items: getAvailableTopics().map((String topic) {
                          return DropdownMenuItem<String>(
                            value: topic,
                            child: Text(topic),
                          );
                        }).toList(),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            // run mutation to create Nugget in DB
                            runMutation({
                              'creatorId': loginId,
                              'nuggetType':
                                  enumToString(formData['nuggetType']),
                              'content': formData['content'],
                              'source': formData['source'],
                              'topic': formData['topic'],
                            });
                          }
                        },
                        child: Text('Create Nugget Now'),
                      ),
                    ],
                  )));
        });
  }
}
