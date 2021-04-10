import 'package:flutter/material.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/helpers/helpers.dart';

class NoteListTile extends StatelessWidget {
  const NoteListTile({
    Key key,
    @required this.note,
  }) : super(key: key);

  final Note note;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("By ${note.writer.userName}"),
      subtitle: Text(note.text),
      //isThreeLine: true,
      /* trailing: Text("Tab to view Analysis details"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvestmentAnalysisDetailScreen(investmentAnalysisId: analysis.investmentAnalysisId),
          ),
        );
      }, */
    );
  }
}
