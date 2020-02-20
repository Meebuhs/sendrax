import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key key, @required this.attempts}) : super(key: key);

  final List<Attempt> attempts;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildTabBar(context),
        Expanded(
          child: _buildTabBarView(),
        )
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return SizedBox(
        height: 50.0,
        width: double.infinity,
        child: Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: TabBar(
                isScrollable: true,
                unselectedLabelColor: Theme.of(context).disabledColor,
                indicatorColor: Theme.of(context).accentColor,
                labelColor: Theme.of(context).accentColor,
                labelStyle: Theme.of(context).accentTextTheme.subtitle2,
                tabs: [
                  Tab(child: Text('Chart 1')),
                  Tab(child: Text('Chart 2')),
                ])));
  }

  Widget _buildTabBarView() {
    return TabBarView(
      children: [
        Text('Chart 1'),
        Text('Chart 2'),
      ],
    );
  }
}
