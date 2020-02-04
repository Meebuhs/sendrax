import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/util/constants.dart';

class AttemptItem extends StatelessWidget {
  AttemptItem({Key key, @required this.attempt, @required this.climbId}) : super(key: key);

  final Attempt attempt;
  final String climbId;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: Key(attempt.id),
        direction: DismissDirection.endToStart,
        background: Container(
            color: Theme.of(context).errorColor,
            child: (Container(
              child: Padding(
                padding: EdgeInsets.only(right: UIConstants.SMALLER_PADDING),
                child: Icon(Icons.delete_forever, color: Colors.black),
              ),
              alignment: Alignment.centerRight,
            ))),
        onDismissed: (direction) => ClimbRepo.getInstance().deleteAttempt(attempt.id, climbId),
        child: _buildAttempt(context));
  }

  Widget _buildAttempt(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
        child: Container(
            padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
              color: Theme.of(context).cardColor,
            ),
            child: Row(children: <Widget>[
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(
                  "${formatDate(attempt.timestamp.toDate())} - ${attempt.sendType}",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).accentTextTheme.subtitle2,
                ),
                Text(
                  attempt.notes,
                  style: Theme.of(context).accentTextTheme.caption,
                )
              ])),
              Container(
                  padding: EdgeInsets.only(left: UIConstants.STANDARD_PADDING),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[_showWarmupTick(context), _showDownclimbedTick(context)],
                  )),
            ])));
  }

  Widget _showWarmupTick(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Text("W: ", style: Theme.of(context).accentTextTheme.bodyText2),
      (attempt.warmup)
          ? Icon(
              Icons.check,
              color: Theme.of(context).accentColor,
              size: Theme.of(context).accentTextTheme.bodyText2.fontSize,
            )
          : Icon(
              Icons.close,
              color: Theme.of(context).accentColor,
              size: Theme.of(context).accentTextTheme.bodyText2.fontSize,
            )
    ]);
  }

  Widget _showDownclimbedTick(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Text(
        "D: ",
        style: Theme.of(context).accentTextTheme.bodyText2,
      ),
      (attempt.downclimbed)
          ? Icon(
              Icons.check,
              color: Theme.of(context).accentColor,
              size: Theme.of(context).accentTextTheme.bodyText2.fontSize,
            )
          : Icon(
              Icons.close,
              color: Theme.of(context).accentColor,
              size: Theme.of(context).accentTextTheme.bodyText2.fontSize,
            )
    ]);
  }

  String formatDate(DateTime time) {
    String ampm = (time.hour < 12) ? "AM" : "PM";
    int hour =
        (time.hour <= 12) ? (time.hour == 0 || time.hour == 12) ? 12 : time.hour : time.hour % 12;
    return "${time.day}/${time.month} $hour:${time.minute.toString().padLeft(2, '0')} $ampm";
  }
}
