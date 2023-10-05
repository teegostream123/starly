import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/utils/colors.dart';

class PaywallWidget extends StatefulWidget {
  final String title;
  final String? description;
  final List<Package> packages;
  final ValueChanged<Package> onClickedPackege;

  const PaywallWidget(
      {super.key,
      required this.title,
      this.description,
      required this.onClickedPackege,
      required this.packages});

  @override
  State<PaywallWidget> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends State<PaywallWidget> {
  @override
  Widget build(BuildContext context) {
    final textColor =
        QuickHelp.isDarkMode(context) ? Colors.white : Colors.grey;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              widget.description ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 16,
            ),
            buildPackages(),
          ],
        ),
      ),
    );
  }

  Widget buildPackages() => ListView.builder(
      shrinkWrap: true,
      primary: false,
      // itemCount: 3,
      itemCount: widget.packages.length,
      itemBuilder: (context, index) {
        final package = widget.packages[index];

        return buildPackage(context, package);
      });
  Widget buildPackage(BuildContext context, Package package) {
    final product = package.storeProduct;
    final textColor = QuickHelp.isDarkMode(context)
        ? kPrimaryColor
        : Colors.white.withOpacity(.8);
    return Card(
      color: QuickHelp.isDarkMode(context)
          ? Colors.white
          : kPrimaryColor.withOpacity(.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
          data: ThemeData.light(),
          child: ListTile(
            contentPadding: EdgeInsets.all(8),
            title: Text(
              product.title,
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            subtitle: Text(
              product.description,
              style: TextStyle(color: textColor),
            ),
            trailing: Text(
              product.priceString,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            onTap: () => widget.onClickedPackege(package),
          )),
    );
  }
}
