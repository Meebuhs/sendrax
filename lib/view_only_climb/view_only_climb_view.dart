import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'view_only_climb_attempt_item.dart';
import 'view_only_climb_bloc.dart';
import 'view_only_climb_state.dart';

class ViewOnlyClimbScreen extends StatefulWidget {
  ViewOnlyClimbScreen({Key key, @required this.climbId, @required this.climbName})
      : super(key: key);

  final String climbId;
  final String climbName;

  @override
  State<StatefulWidget> createState() => _ViewOnlyClimbState();
}

class _ViewOnlyClimbState extends State<ViewOnlyClimbScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ViewOnlyClimbBloc>(
      create: (context) => ViewOnlyClimbBloc(widget.climbId),
      child: ViewOnlyClimbWidget(widget: widget, widgetState: this),
    );
  }
}

class ViewOnlyClimbWidget extends StatelessWidget {
  const ViewOnlyClimbWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final ViewOnlyClimbScreen widget;
  final _ViewOnlyClimbState widgetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.climbName),
        actions: _buildActions(context),
      ),
      body: _buildBody(context),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      IconButton(icon: Icon(Icons.unarchive), onPressed: () => _showUnarchiveClimbDialog(context)),
      IconButton(icon: Icon(Icons.delete_forever), onPressed: () => _showDeleteClimbDialog(context))
    ];
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<ViewOnlyClimbBloc>(context),
        builder: (context, ViewOnlyClimbState state) {
          Widget content;
          if (state.loading) {
            content = Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            );
          } else {
            content = Column(
              children: <Widget>[Expanded(child: _showListView(state))],
            );
          }
          return content;
        });
  }

  Widget _showListView(ViewOnlyClimbState state) {
    int itemCount = 1;
    if (state.climb.imagePath != "") {
      itemCount++;
    }
    if (state.climb.attempts.isEmpty) {
      itemCount++;
    } else {
      itemCount += state.climb.attempts.length;
    }
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (state.climb.imagePath != "") {
          if (index == 0) {
            return _showImage(state);
          } else if (index == 1) {
            return _showClimbInformation(state, context);
          } else if (state.climb.attempts.isEmpty) {
            return _showEmptyAttemptList(context);
          } else {
            return _buildAttempt(state.climb.attempts[index - 2], state.climb.id);
          }
        } else {
          if (index == 0) {
            return _showClimbInformation(state, context);
          } else if (state.climb.attempts.isEmpty) {
            return _showEmptyAttemptList(context);
          } else {
            return _buildAttempt(state.climb.attempts[index - 1], state.climb.id);
          }
        }
      },
      itemCount: itemCount,
    );
  }

  Widget _showEmptyAttemptList(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "This climb didn't have any attempts.",
          textAlign: TextAlign.center,
          style: Theme.of(context).accentTextTheme.subtitle2,
        ),
      ),
      padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
    );
  }

  Widget _showImage(ViewOnlyClimbState state) {
    return Container(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      height: 200,
      child: CachedNetworkImage(
        imageUrl: state.climb.imagePath,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          )),
        ),
        placeholder: (context, url) => SizedBox(
            width: 60,
            height: 60,
            child: Center(
                child: CircularProgressIndicator(
              strokeWidth: 4.0,
            ))),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  Widget _showClimbInformation(ViewOnlyClimbState state, BuildContext context) {
    String firstComponentText = (state.climb.section == null)
        ? "${state.climb.grade}"
        : "${state.climb.grade} - ${state.climb.section}";

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Container(
          child: Padding(
              padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
              child: Text("$firstComponentText - ${state.climb.categories.join(', ')}",
                  style: Theme.of(context).accentTextTheme.subtitle2))),
      Padding(
          padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
          child: Divider(
            color: Theme.of(context).accentColor,
            thickness: 1.0,
            height: 0.0,
          ))
    ]);
  }

  AttemptItem _buildAttempt(Attempt attempt, String climbId) {
    return AttemptItem(attempt: attempt, climbId: climbId);
  }

  void _showDeleteClimbDialog(BuildContext upperContext) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text("Are you sure you want to delete this climb?",
                  style: Theme.of(context).accentTextTheme.headline5),
              content: Text("There is no way to get it back",
                  style: Theme.of(context).accentTextTheme.bodyText2),
              actions: <Widget>[
                FlatButton(
                  child: Text("CANCEL", style: Theme.of(context).accentTextTheme.button),
                  onPressed: navigateBackOne,
                ),
                FlatButton(
                  child: Text("DELETE", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () =>
                      BlocProvider.of<ViewOnlyClimbBloc>(upperContext).deleteClimb(upperContext),
                )
              ]);
        });
  }

  void _showUnarchiveClimbDialog(BuildContext upperContext) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text("Are you sure you want to revive this climb?",
                  style: Theme.of(context).accentTextTheme.headline5),
              content: Text(
                  "It will still appear in the log but will also reappear in its original location.",
                  style: Theme.of(context).accentTextTheme.bodyText2),
              actions: <Widget>[
                FlatButton(
                  child: Text("CANCEL", style: Theme.of(context).accentTextTheme.button),
                  onPressed: navigateBackOne,
                ),
                FlatButton(
                  child: Text("REVIVE", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () =>
                      BlocProvider.of<ViewOnlyClimbBloc>(upperContext).unarchiveClimb(upperContext),
                )
              ]);
        });
  }

  void navigateBackOne() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }
}
