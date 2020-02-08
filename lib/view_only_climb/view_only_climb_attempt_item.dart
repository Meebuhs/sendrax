import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

class AttemptItem extends StatelessWidget {
  AttemptItem({Key key, @required this.attempt, @required this.climbId}) : super(key: key);

  final Attempt attempt;
  final String climbId;

  @override
  Widget build(BuildContext context) {
    return _buildAttempt(context);
  }

  Widget _buildAttempt(BuildContext context) {
    List<Widget> columnTexts = [
      Padding(
          padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING / 2),
          child: Text(
            "${DateFormat('EEEE d/M h:mm a').format(attempt.timestamp.toDate())} - ${attempt.sendType}",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).accentTextTheme.subtitle2,
          ))
    ];
    if (attempt.notes != "") {
      columnTexts.add(Text(
        attempt.notes,
        style: Theme.of(context).accentTextTheme.caption,
      ));
    }

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
                  child:
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: columnTexts)),
              Container(
                padding: EdgeInsets.only(left: UIConstants.STANDARD_PADDING),
                child: _showDownclimbedTick(context),
              ),
            ])));
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
}
