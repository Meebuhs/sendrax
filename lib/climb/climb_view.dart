import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'climb_attempt_item.dart';
import 'climb_bloc.dart';
import 'climb_state.dart';

class ClimbScreen extends StatefulWidget {
  ClimbScreen({Key key, @required this.climb, @required this.location, @required this.categories})
      : super(key: key);

  final Climb climb;
  final Location location;
  final List<String> categories;

  @override
  State<StatefulWidget> createState() => _ClimbState();
}

class _ClimbState extends State<ClimbScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClimbBloc>(
      create: (context) => ClimbBloc(widget.climb),
      child: ClimbWidget(widget: widget, widgetState: this),
    );
  }
}

class ClimbWidget extends StatelessWidget {
  const ClimbWidget({Key key, @required this.widget, @required this.widgetState}) : super(key: key);

  final ClimbScreen widget;
  final _ClimbState widgetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.climb.displayName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editClimb(),
          ),
          IconButton(
              icon: Icon(Icons.archive), onPressed: () => _showArchiveClimbDialog(context, this)),
          IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () => _showDeleteClimbDialog(context, this)),
        ],
      ),
      body: _buildBody(context),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<ClimbBloc>(context),
        builder: (context, ClimbState state) {
          Widget content;
          if (state.loading) {
            content = Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            );
          } else {
            content = Column(
              children: <Widget>[Expanded(child: _showListView(state)), _showForm(state, context)],
            );
          }
          return content;
        });
  }

  Widget _showListView(ClimbState state) {
    List<DateTime> datesToBuild = _generateDates(state);

    int itemCount = 1;
    if (widget.climb.imagePath != "") {
      itemCount++;
    }
    if (state.attempts.isEmpty) {
      itemCount++;
    } else {
      itemCount += datesToBuild.length;
    }

    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (widget.climb.imagePath != "") {
          if (index == 0) {
            return _showImage();
          } else if (index == 1) {
            return _showClimbInformation(context);
          } else if (state.attempts.isEmpty) {
            return _showEmptyAttemptList(context);
          } else {
            return _buildDateCard(context, state, datesToBuild, index - 2);
          }
        } else {
          if (index == 0) {
            return _showClimbInformation(context);
          } else if (state.attempts.isEmpty) {
            return _showEmptyAttemptList(context);
          } else {
            return _buildDateCard(context, state, datesToBuild, index - 1);
          }
        }
      },
      itemCount: itemCount,
    );
  }

  List<DateTime> _generateDates(ClimbState state) {
    List<DateTime> dates = <DateTime>[];
    for (Attempt attempt in state.attempts) {
      DateTime attemptDate = attempt.timestamp.toDate();
      DateTime startOfDay = DateTime(attemptDate.year, attemptDate.month, attemptDate.day);
      if (!dates.contains(startOfDay)) {
        dates.add(startOfDay);
      }
    }
    return dates;
  }

  Widget _showEmptyAttemptList(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "This climb doesn't have any attempts.\nLet's create one right now!",
          textAlign: TextAlign.center,
          style: Theme.of(context).accentTextTheme.subtitle2,
        ),
      ),
      padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
    );
  }

  Widget _showImage() {
    return Container(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      height: 200,
      child: CachedNetworkImage(
        imageUrl: widget.climb.imagePath,
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

  Widget _showClimbInformation(BuildContext context) {
    String firstComponentText = (widget.climb.section == null)
        ? "${widget.climb.grade}"
        : "${widget.climb.grade} - ${widget.climb.section}";

    String secondComponentText =
        (widget.climb.categories.isNotEmpty) ? " - ${widget.climb.categories.join(', ')}" : "";

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Container(
          child: Padding(
              padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
              child: Text("$firstComponentText$secondComponentText",
                  style: Theme.of(context).accentTextTheme.subtitle2))),
      Divider(
        color: Theme.of(context).accentColor,
        thickness: 1.0,
        height: 0.0,
      )
    ]);
  }

  Widget _buildDateCard(BuildContext context, ClimbState state, List<DateTime> dates, int index) {
    List<Attempt> attemptsOnDate = List.from(state.attempts.where((attempt) =>
        (attempt.timestamp.toDate().difference(dates[index]) > Duration() &&
            attempt.timestamp.toDate().difference(dates[index]) < Duration(days: 1))));
    List<Widget> attemptItems = <Widget>[];
    attemptItems.add(
      Padding(
        padding:
            EdgeInsets.fromLTRB(UIConstants.SMALLER_PADDING, UIConstants.SMALLER_PADDING, 0, 0),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            DateFormat('EEEE d/M').format(dates[index]),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).accentTextTheme.subtitle2,
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
    for (Attempt attempt in attemptsOnDate) {
      attemptItems.add(_buildAttempt(attempt, widget.climb.id));
    }
    return Column(
      children: attemptItems,
    );
  }

  AttemptItem _buildAttempt(Attempt attempt, String climbId) {
    return AttemptItem(attempt: attempt, climbId: climbId);
  }

  Widget _showForm(ClimbState state, BuildContext context) {
    return Column(children: <Widget>[
      Divider(
        color: Theme.of(context).accentColor,
        thickness: 1.0,
        height: 0.0,
      ),
      Container(
          padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
          alignment: Alignment.bottomCenter,
          child: Form(
            key: state.formKey,
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
                    child: Row(children: <Widget>[
                      Expanded(
                        child: _showSendTypeDropdown(state, context),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: UIConstants.STANDARD_PADDING),
                          child: SizedBox(
                            width: 95,
                            child: _showDownclimbedCheckbox(state, context),
                          )),
                    ])),
                Row(children: <Widget>[
                  Expanded(child: _showNotesInput(state, context)),
                  _showSubmitButton(state, context)
                ])
              ],
            ),
          ))
    ]);
  }

  Widget _showSendTypeDropdown(ClimbState state, BuildContext context) {
    return DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
      style: Theme.of(context).accentTextTheme.subtitle2,
      items: _createDropdownItems(SendTypes.SEND_TYPES),
      value: state.sendType,
      hint: Text("Send type"),
      isExpanded: true,
      decoration: InputDecoration(filled: true, fillColor: Theme.of(context).cardColor),
      validator: (String value) {
        if (value == null) {
          return 'A send type must be selected';
        }
        return null;
      },
      onChanged: (value) => BlocProvider.of<ClimbBloc>(context).selectSendType(value),
    ));
  }

  List<DropdownMenuItem> _createDropdownItems(List<String> items) {
    if (items.isNotEmpty) {
      return items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    } else {
      // null disables the dropdown
      return null;
    }
  }

  Widget _showDownclimbedCheckbox(ClimbState state, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Downclimbed", style: Theme.of(context).accentTextTheme.subtitle2),
        Checkbox(
            checkColor: Colors.black,
            hoverColor: Theme.of(context).accentColor,
            activeColor: Theme.of(context).accentColor,
            focusColor: Theme.of(context).accentColor,
            value: state.downclimbed,
            onChanged: (value) =>
                BlocProvider.of<ClimbBloc>(context).toggleDownclimbedCheckbox(value)),
      ],
    );
  }

  Widget _showNotesInput(ClimbState state, BuildContext context) {
    return TextFormField(
      controller: state.notesInputController,
      maxLines: 3,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      autofocus: false,
      style: Theme.of(context).accentTextTheme.subtitle2,
      decoration: InputDecoration(
          labelText: 'Attempt notes',
          filled: true,
          fillColor: Theme.of(context).cardColor,
          suffixIcon: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () => BlocProvider.of<ClimbBloc>(context).resetNotesInput())),
    );
  }

  Widget _showSubmitButton(ClimbState state, BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: UIConstants.STANDARD_PADDING),
        child: SizedBox(
          width: 95,
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
            color: Theme.of(context).accentColor,
            child: Text('SUBMIT', style: Theme.of(context).primaryTextTheme.button),
            onPressed: () => BlocProvider.of<ClimbBloc>(context).validateAndSubmit(state, context),
          ),
        ));
  }

  void _editClimb() {
    NavigationHelper.navigateToCreateClimb(
        widgetState.context, widget.climb, widget.location, widget.categories, true,
        addToBackStack: true);
  }

  void _showArchiveClimbDialog(BuildContext upperContext, ClimbWidget view) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text("Are you sure you want to archive this climb?",
                  style: Theme.of(context).accentTextTheme.headline5),
              content: Text(
                  "It will still appear in your log but will no longer appear for this location",
                  style: Theme.of(context).accentTextTheme.bodyText2),
              actions: <Widget>[
                FlatButton(
                  child: Text("CANCEL", style: Theme.of(context).accentTextTheme.button),
                  onPressed: navigateToLocation,
                ),
                FlatButton(
                  child: Text("ARCHIVE", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => BlocProvider.of<ClimbBloc>(upperContext)
                      .archiveClimb(upperContext, view, widget.location, widget.categories),
                )
              ]);
        });
  }

  void _showDeleteClimbDialog(BuildContext upperContext, ClimbWidget view) {
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
                  onPressed: navigateToLocation,
                ),
                FlatButton(
                  child: Text("DELETE", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => BlocProvider.of<ClimbBloc>(upperContext)
                      .deleteClimb(upperContext, view, widget.location, widget.categories),
                )
              ]);
        });
  }

  void navigateToLocation() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }
}
