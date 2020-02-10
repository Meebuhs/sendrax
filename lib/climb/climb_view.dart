import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      @required this.selectedLocation,
      @required this.sections,
      @required this.grades,
      @required this.categories})
      : super(key: key);

  final Climb climb;
  final SelectedLocation selectedLocation;
  final List<String> sections;
  final List<String> grades;
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
            onPressed: () => _editClimb(widget.climb, widget.sections, widget.grades,
                widget.categories, widget.selectedLocation),
          )
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
    int itemCount = 1;
    if (widget.climb.imagePath != "") {
      itemCount++;
    }
    if (state.attempts.isEmpty) {
      itemCount++;
    } else {
      itemCount += state.attempts.length;
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
            return _buildAttempt(state.attempts[index - 2], widget.climb.id);
          }
        } else {
          if (index == 0) {
            return _showClimbInformation(context);
          } else if (state.attempts.isEmpty) {
            return _showEmptyAttemptList(context);
          } else {
            return _buildAttempt(state.attempts[index - 1], widget.climb.id);
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
        (widget.climb.categories.isNotEmpty) ? "- ${widget.climb.categories.join(', ')}" : "";

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Container(
          child: Padding(
              padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
              child: Text("$firstComponentText$secondComponentText",
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
      hint: Text("Send"),
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

  void _editClimb(Climb climb, List<String> sections, List<String> grades, List<String> categories,
      SelectedLocation selectedLocation) {
    NavigationHelper.navigateToCreateClimb(
        widgetState.context, climb, selectedLocation, sections, grades, categories, true,
        addToBackStack: true);
  }

  void navigateToLocation() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }
}
