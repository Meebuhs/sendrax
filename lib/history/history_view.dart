import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/history/history_attempt_item.dart';
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
                child: _buildAttempts(state, context),
              )
            ]);
          }
        });
  }

  Widget _buildAttempts(HistoryState state, BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        return _buildAttempt(context, state, index);
      },
      itemCount: state.attempts.length,
    );
  }

  Widget _buildAttempt(BuildContext context, HistoryState state, int index) {
    return AttemptItem(attempt: state.attempts[index]);
  }
}
