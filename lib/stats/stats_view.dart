import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'stats_bloc.dart';
import 'stats_state.dart';

class StatsScreen extends StatefulWidget {
  StatsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StatsState();
}

class _StatsState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatsBloc>(
      create: (context) => StatsBloc(),
      child: StatsWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class StatsWidget extends StatelessWidget {
  const StatsWidget({Key key, @required this.widget, @required this.widgetState}) : super(key: key);

  final StatsScreen widget;
  final _StatsState widgetState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<StatsBloc>(context),
        builder: (context, StatsState state) {
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            );
          } else {
            return Center(
                child: Text(
              'You have logged ${state.count} attempts',
              style: Theme.of(context).accentTextTheme.subtitle2,
            ));
          }
        });
  }
}
