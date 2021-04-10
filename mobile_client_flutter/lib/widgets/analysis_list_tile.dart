import 'package:client_flutter/screens/investment_analysis_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/helpers/helpers.dart';
//import 'package:client_flutter/screens/business_detail_screen.dart';
//import 'rating_display.dart';

class AnalysisListTile extends StatelessWidget {
  const AnalysisListTile({
    Key key,
    @required this.analysis,
  }) : super(key: key);

  final InvestmentAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Analysis by ${analysis.analysts.map((analyst) => analyst.userName).toList().join(', ')}"),
      subtitle: Text("Status: ${prettifyEnumString(enumToString(analysis.status))}"),
      trailing: Text("Tab to view Analysis details"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvestmentAnalysisDetailScreen(investmentAnalysisId: analysis.investmentAnalysisId),
          ),
        );
      },
    );
  }
}
