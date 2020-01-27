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
      create: (context) => ClimbBloc(widget.climb.id),
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
      body: BlocBuilder(
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
          }),
    );
  }

  Widget _showListView(ClimbState state) {
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _showImage();
        } else if (index == 1) {
          return _showClimbInformation();
        } else if (state.attempts.isEmpty) {
          return Container(
            child: Center(
              child: Text(
                "This climb doesn't have any attempts.\nLet's create one right now!",
                textAlign: TextAlign.center,
              ),
            ),
            padding: EdgeInsets.fromLTRB(0.0, UIConstants.STANDARD_PADDING, 0.0, 0.0),
          );
        } else {
          return _buildAttempt(state.attempts[index - 2], widget.climb.id);
        }
      },
      itemCount: state.attempts.isEmpty ? 3 : state.attempts.length + 2,
    );
  }

  Widget _showImage() {
    return SizedBox(
      height: 200.0,
      child: Center(
        child: Text(
          "Image placeholder",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _showClimbInformation() {
    List<Widget> rowComponents = [];
    String firstComponentText = (widget.climb.section == null)
        ? "${widget.climb.grade}"
        : "${widget.climb.grade} - ${widget.climb.section}";
    rowComponents.add(Expanded(child: Center(child: Text(firstComponentText))));
    rowComponents.add(Expanded(child: Text("${widget.climb.categories.join(', ')}"), flex: 2));

    return Column(children: <Widget>[Container(child: Row(children: rowComponents)), Divider()]);
  }

  AttemptItem _buildAttempt(Attempt attempt, String climbId) {
    return AttemptItem(attempt: attempt, climbId: climbId);
  }

  Widget _showForm(ClimbState state, BuildContext context) {
    return Container(
        padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
        alignment: Alignment.bottomCenter,
        child: new Form(
          key: state.formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                  flex: 2,
                  child: _showSendTypeDropdown(state, context),
                ),
                Expanded(
                  child: _showWarmupCheckbox(state, context),
                ),
                Expanded(
                  child: _showDownclimbedCheckbox(state, context),
                )
              ]),
              _showNotesInput(state, context),
              _showSubmitButton(state, context)
            ],
          ),
        ));
  }

  Widget _showSendTypeDropdown(ClimbState state, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
        child: DropdownButtonFormField<String>(
          items: _createDropdownItems(SendTypes.SEND_TYPES),
          value: state.sendType,
          hint: Text("Send"),
          isExpanded: true,
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
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList();
    } else {
      // null disables the dropdown
      return null;
    }
  }

  Widget _showWarmupCheckbox(ClimbState state, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Warmup"),
        Checkbox(
            value: state.warmup,
            onChanged: (value) => BlocProvider.of<ClimbBloc>(context).toggleWarmupCheckbox(value)),
      ],
    );
  }

  Widget _showDownclimbedCheckbox(ClimbState state, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Downclimbed"),
        Checkbox(
            value: state.downclimbed,
            onChanged: (value) =>
                BlocProvider.of<ClimbBloc>(context).toggleDownclimbedCheckbox(value)),
      ],
    );
  }

  Widget _showNotesInput(ClimbState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
          UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
      child: new TextFormField(
        controller: state.notesInputController,
        maxLines: 3,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Attempt notes',
            suffixIcon: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () => BlocProvider.of<ClimbBloc>(context).resetNotesInput())),
      ),
    );
  }

  Widget _showSubmitButton(ClimbState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(
            UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: new Text('Submit', style: new TextStyle(fontSize: 20.0, color: Colors.white)),
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
