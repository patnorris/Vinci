import 'package:client_flutter/helpers/helpers.dart';
import 'package:client_flutter/widgets/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:client_flutter/model/model.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

final editUserTopicsQuery = gql("""
  mutation editUserTopics(\$userId: ID!, \$topics: [String]!) {
    editUserTopics(
      userId: \$userId
      topics: \$topics
    ) {
        id
      }        
  }
""");

/* class Animal {
  final int id;
  final String name;

  Animal({
    this.id,
    this.name,
  });
} */

class EditUserTopicsMutationScreen extends StatefulWidget {
  EditUserTopicsMutationScreen({Key key, @required this.user})
      : super(key: key);
  final User user;

  @override
  _EditUserTopicsMutationState createState() =>
      _EditUserTopicsMutationState(user: user);
}

class _EditUserTopicsMutationState extends State<EditUserTopicsMutationScreen> {
  User user;

  _EditUserTopicsMutationState({
    @required this.user,
  });

  /* static List<Animal> _animals = [
    Animal(id: 1, name: "Lion"),
    Animal(id: 2, name: "Flamingo"),
  ]; */
  static List<String> availableTopics = getAvailableTopics();
  final _items = availableTopics
      .map((topic) => MultiSelectItem<String>(topic, topic))
      .toList();
  List<String> selectedTopics = [];
  final _multiSelectKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    selectedTopics = user.selectedTopics;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Mutation(
        options: MutationOptions(
          /// Insert mutation here
          documentNode: editUserTopicsQuery,

          /// Tell the GraphQL client to fetch the data from
          /// the network only and don't cache it
          fetchPolicy: FetchPolicy.noCache,

          /// Whenever the [Form] closes, this tells the previous [route]
          /// whether it needs to rebuild itself or not
          // onCompleted: (data) => Navigator.pop(context, data != null),
          onCompleted: (data) =>
              Navigator.pushReplacementNamed(context, '/topics'),
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          return Scaffold(
            backgroundColor: Colors.indigo[100],
            appBar: AppBar(
              title: Text("Select Topics to Learn About"),
            ),
            body: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    MultiSelectBottomSheetField<String>(
                      key: _multiSelectKey,
                      initialChildSize: 0.7,
                      maxChildSize: 0.95,
                      title: Text("Which Topics are You Curious about?"),
                      buttonText: Text("Topics I'm Interested In"),
                      initialValue: selectedTopics,
                      items: _items,
                      searchable: true,
                      validator: (values) {
                        if (values == null || values.isEmpty) {
                          return """If you don't select any specific topics, Vinci will 
provide you a mix of everything worth learning""";
                        }
                        //List<String> names = values.map((e) => e.name).toList();
                        List<String> topics = values.toList();
                        if (topics.contains("Random")) {
                          return "Random: a portion of Your Nuggets will be a random mix";
                        }
                        return null;
                      },
                      onConfirm: (values) {
                        setState(() {
                          selectedTopics = values;
                        });
                        _multiSelectKey.currentState.validate();
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        chipColor: Colors.indigo[200],
                        textStyle: TextStyle(
                          fontSize: 12.0,
                          color: Colors.deepPurple[900],
                          fontWeight: FontWeight.bold,
                        ),
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
                        // run mutation to update User topics in DB
                        runMutation({
                          'userId': user.id,
                          'topics': selectedTopics,
                        });
                      },
                      child: Text('Save Updates'),
                    ),
                    Text(
                      'Note: Nuggets from the Topics You Select here will be added to Your Stream',
                      style: TextStyle(
                        fontSize: 12.0,
                        height: 1.3,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
