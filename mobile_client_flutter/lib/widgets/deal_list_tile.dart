import 'package:client_flutter/screens/investment_deal_overview_screen.dart';
import 'package:client_flutter/screens/investment_decision_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/helpers/helpers.dart';

class DealListTile extends StatelessWidget {
  const DealListTile({
    Key key,
    @required this.deal,
  }) : super(key: key);

  final InvestmentDeal deal;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Deal by ${deal.investor.userName}"),
      subtitle: Text("Status: ${prettifyEnumString(enumToString(deal.status))}"),
      trailing: Text("Tab to view Deal details"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvestmentDealOverviewScreen(investmentDealId: deal.investmentDealId),
          ),
        );
      },
    );
  }
}
