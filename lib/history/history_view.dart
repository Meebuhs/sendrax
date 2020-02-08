import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/history/history_attempt_item.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'history_bloc.dart';
import 'history_state.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryBloc>(
      create: (context) => HistoryBloc(),
      child: HistoryWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final HistoryScreen widget;
  final _HistoryState widgetState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<HistoryBloc>(context),
        builder: (context, HistoryState state) {
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            );
          } else if (state.attempts.isEmpty) {
            return Column(children: <Widget>[
              Expanded(
                  child: Center(
                child: Text(
                  "You have not yet logged any attempts.",
                  style: Theme.of(context).accentTextTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
              ))
            ]);
          } else {
            return Column(children: <Widget>[
              Expanded(
                child: _buildGroupedList(state, context),
              )
            ]);
          }
        });
  }

  Widget _buildGroupedList(HistoryState state, BuildContext context) {
    List<DateTime> datesToBuild = _generateDates(state);
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        return _buildDateCard(context, state, datesToBuild, index);
      },
      itemCount: datesToBuild.length,
    );
  }

  List<DateTime> _generateDates(HistoryState state) {
    List<DateTime> dates = <DateTime>[];
    DateTime startDate = state.attempts.last.timestamp.toDate();
    DateTime endDate = state.attempts.first.timestamp.toDate();
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    while (currentDate.isBefore(endDate)) {
      dates.insert(0, currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }
    return dates;
  }

  Widget _buildDateCard(BuildContext context, HistoryState state, List<DateTime> dates, int index) {
    List<Attempt> attemptsOnDate = List.from(state.attempts.where((attempt) =>
        (attempt.timestamp.toDate().difference(dates[index]) > Duration() &&
            attempt.timestamp.toDate().difference(dates[index]) < Duration(days: 1))));
    if (attemptsOnDate.isNotEmpty) {
      return Card(
          child: Column(children: <Widget>[
        Row(children: <Widget>[
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
                color: Theme.of(context).accentColor,
              ),
              padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
              child: Text(DateFormat('EEEE d/M').format(dates[index]),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).primaryTextTheme.subtitle2),
            ),
          )),
        ]),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                attemptsOnDate.map((attempt) => _buildAttempt(context, state, attempt)).toList())
      ]));
    } else {
      return Column();
    }
  }

  Widget _buildAttempt(BuildContext context, HistoryState state, Attempt attempt) {
    return AttemptItem(attempt: attempt);
  }
}
