import 'package:client_flutter/screens/investment_deal_overview_screen.dart';
import 'package:client_flutter/screens/investment_decision_detail_screen.dart';
import 'package:client_flutter/screens/investment_selling_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:client_flutter/model/model.dart';
import 'package:client_flutter/helpers/helpers.dart';

class SellingListTile extends StatelessWidget {
  const SellingListTile({
    Key key,
    @required this.selling,
  }) : super(key: key);

  final InvestmentSelling selling;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Sold by ${selling.seller.userName}"),
      subtitle: Text("Sold ${selling.sellingQuantity.value} ${selling.sellingQuantity.unit} at ${selling.sellingPrice.value} ${selling.sellingPrice.unit}"),
      trailing: Text("Tab to view Selling details"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvestmentSellingDetailScreen(investmentSellingId: selling.investmentSellingId),
          ),
        );
      },
    );
  }
}
