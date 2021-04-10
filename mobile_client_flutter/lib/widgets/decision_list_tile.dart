import 'package:client_flutter/screens/investment_decision_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/helpers/helpers.dart';
//import 'package:client_flutter/screens/business_detail_screen.dart';
//import 'rating_display.dart';

class DecisionListTile extends StatelessWidget {
  const DecisionListTile({
    Key key,
    @required this.decision,
  }) : super(key: key);

  final InvestmentDecision decision;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Decision by ${decision.decider.userName}"),
      subtitle: Text("Investment Decision: ${prettifyEnumString(enumToString(decision.decision))}"),
      trailing: Text("Tab to view Decision details"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvestmentDecisionDetailScreen(investmentDecisionId: decision.investmentDecisionId),
          ),
        );
      },
    );
  }
}
