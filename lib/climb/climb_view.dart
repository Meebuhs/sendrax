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
  ClimbScreen(
      {Key key,
      @required this.climb,
      @required this.location,
      @required this.categories})
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
  const ClimbWidget(
      {Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

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
              icon: Icon(Icons.archive),
              onPressed: () => _showArchiveClimbDialog(context, this)),
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
              children: <Widget>[
                Expanded(child: _showListView(state)),
                _showForm(state, context)
              ],
            );
          }
          return content;
        });
  }

  Widget _showListView(ClimbState state) {
    List<DateTime> datesToBuild = _generateDates(state);

    int itemCount = 1;
    if (widget.climb.imageURL != "") {
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
        if (widget.climb.imageURL != "") {
          if (index == 0) {
            return _showImage(context);
          } else if (index == 1) {
            return _showClimbInformation(context, state);
          } else if (state.attempts.isEmpty) {
            return _showEmptyAttemptList(context);
          } else {
            return _buildDateCard(context, state, datesToBuild, index - 2);
          }
        } else {
          if (index == 0) {
            return _showClimbInformation(context, state);
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
      DateTime startOfDay =
          DateTime(attemptDate.year, attemptDate.month, attemptDate.day);
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

  Widget _showImage(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(UIConstants.SMALLER_PADDING,
          UIConstants.SMALLER_PADDING, UIConstants.SMALLER_PADDING, 0),
      height: 200,
      child: CachedNetworkImage(
        imageUrl: widget.climb.imageURL,
        imageBuilder: (context, imageProvider) => InkWell(
          child: Material(
            borderRadius: BorderRadius.all(
                Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
            child: Hero(
                tag: "climbImageHero",
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )))),
          ),
          onTap: () => navigateToImageView(imageProvider),
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

  Widget _showClimbInformation(BuildContext context, ClimbState state) {
    String gradeAndSectionText = (widget.climb.section == null)
        ? "${widget.climb.grade}"
        : "${widget.climb.grade} - ${widget.climb.section}";

    String categoriesText = (widget.climb.categories.isNotEmpty)
        ? " - ${widget.climb.categories.join(', ')}"
        : "";

    String attemptsText = " A: ${state.attempts.length}";

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              child: Padding(
                  padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text("$gradeAndSectionText$categoriesText",
                              style:
                                  Theme.of(context).accentTextTheme.subtitle2)),
                      _createStatusIcon(context),
                      Text("$attemptsText",
                          style: Theme.of(context).accentTextTheme.subtitle2)
                    ],
                  ))),
          Divider(
            color: Theme.of(context).accentColor,
            thickness: 1.0,
            height: 0.0,
          ),
          Container(
            height: 0,
            margin: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
          ),
        ]);
  }

  Widget _createStatusIcon(BuildContext context) {
    IconData statusIcon;

    if (widget.climb.repeated) {
      statusIcon = Icons.rotate_right;
    } else if (widget.climb.sent) {
      statusIcon = Icons.check;
    }

    return Icon(
      statusIcon,
      color: Theme.of(context).accentColor,
      size: Theme.of(context).accentTextTheme.subtitle2.fontSize,
    );
  }

  Widget _buildDateCard(
      BuildContext context, ClimbState state, List<DateTime> dates, int index) {
    List<Attempt> attemptsOnDate = List.from(state.attempts.where((attempt) =>
        (attempt.timestamp.toDate().difference(dates[index]) > Duration() &&
            attempt.timestamp.toDate().difference(dates[index]) <
                Duration(days: 1))));
    List<Widget> attemptItems = <Widget>[];
    attemptItems.add(
      Padding(
        padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
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
      attemptItems.add(_buildAttempt(attempt, widget.climb));
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
        child: Column(
          children: attemptItems,
        ));
  }

  AttemptItem _buildAttempt(Attempt attempt, Climb climb) {
    return AttemptItem(attempt: attempt, climb: climb);
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(child: _showNotesInput(state, context)),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: UIConstants.STANDARD_PADDING),
                      child: SizedBox(
                        width: 95,
                        child: _showDownclimbedCheckbox(state, context),
                      )),
                ]),
                _showSubmitButtons(state, context)
              ],
            ),
          ))
    ]);
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
              onPressed: () =>
                  BlocProvider.of<ClimbBloc>(context).resetNotesInput())),
    );
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
            onChanged: (value) => BlocProvider.of<ClimbBloc>(context)
                .toggleDownclimbedCheckbox(value)),
      ],
    );
  }

  Widget _showSubmitButtons(ClimbState state, BuildContext context) {
    // this is a little cryptic but basically we only allow onsight, flash and
    // send only when the climb has not yet been sent, repeat only when it has
    // and attempt is always allowed.
    bool hasSent = state.attempts
        .any((attempt) => SendTypes.SENDS.contains(attempt.sendType));
    // Onsight, Flash, Send, Repeat, Attempt
    List<bool> isSendAllowed = [!hasSent, !hasSent, !hasSent, hasSent, true];

    List<Widget> buttons = [];
    SendTypes.SEND_TYPES.asMap().forEach((index, sendType) {
      buttons.add(Padding(
          padding: EdgeInsets.only(
              right: index == 4 ? 0 : UIConstants.SMALLER_PADDING),
          child: TextButton(
            child: Text(sendType),
            style: TextButton.styleFrom(
              backgroundColor: isSendAllowed[index]
                  ? SeriesConstants.COLOURS[index]
                  : darken(SeriesConstants.COLOURS[index]),
              primary: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
            ),
            onPressed: isSendAllowed[index]
                ? () => BlocProvider.of<ClimbBloc>(context)
                    .validateAndSubmit(state, context, sendType)
                : null,
          )));
    });

    return Padding(
      padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons,
        ),
      ),
    );
  }

  Color darken(Color color, [double amount = .6]) {
    final hsl = HSLColor.fromColor(color);
    final darkenedHsl = hsl.withAlpha((hsl.alpha - amount).clamp(0.0, 1.0));

    return darkenedHsl.toColor();
  }

  void _editClimb() {
    NavigationHelper.navigateToCreateClimb(widgetState.context, widget.climb,
        widget.location, widget.categories, true,
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
                TextButton(
                  child: Text("CANCEL",
                      style: Theme.of(context).accentTextTheme.button),
                  onPressed: navigateToLocation,
                ),
                TextButton(
                  child: Text("ARCHIVE",
                      style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => BlocProvider.of<ClimbBloc>(upperContext)
                      .archiveClimb(upperContext, view, widget.location,
                          widget.categories),
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
                TextButton(
                  child: Text("CANCEL",
                      style: Theme.of(context).accentTextTheme.button),
                  onPressed: navigateToLocation,
                ),
                TextButton(
                  child: Text("DELETE",
                      style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => BlocProvider.of<ClimbBloc>(upperContext)
                      .deleteClimb(upperContext, view, widget.location,
                          widget.categories),
                )
              ]);
        });
  }

  void navigateToLocation() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }

  void navigateToImageView(ImageProvider image) {
    NavigationHelper.navigateToImageView(
        widgetState.context, image, "climbImageHero",
        addToBackStack: true);
  }
}
