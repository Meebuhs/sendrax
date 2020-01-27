import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'create_climb_bloc.dart';
import 'create_climb_state.dart';

class CreateClimbScreen extends StatefulWidget {
  CreateClimbScreen(
      {Key key,
      @required this.climb,
      @required this.selectedLocation,
      @required this.availableSections,
      @required this.availableGrades,
      @required this.categories,
      @required this.isEdit})
      : super(key: key);

  final Climb climb;
  final SelectedLocation selectedLocation;
  final List<String> availableSections;
  final List<String> availableGrades;
  final List<String> categories;
  final bool isEdit;

  @override
  State<StatefulWidget> createState() => _CreateClimbState();
}

class _CreateClimbState extends State<CreateClimbScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateClimbBloc>(
      create: (context) => CreateClimbBloc(widget.climb, widget.availableGrades),
      child: CreateClimbWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class CreateClimbWidget extends StatelessWidget {
  const CreateClimbWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final CreateClimbScreen widget;
  final _CreateClimbState widgetState;

  @override
  Widget build(BuildContext context) {
    String editTitleText =
        (widget.climb.displayName == "") ? "Edit climb" : "Edit ${widget.climb.displayName}";
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.isEdit) ? editTitleText : "Create a climb"),
        actions: <Widget>[
          (widget.isEdit)
              ? IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () =>
                      _showDeleteClimbDialog(widget.climb.id, context, this, widget.categories),
                )
              : Container()
        ],
      ),
      body: BlocBuilder(
          bloc: BlocProvider.of<CreateClimbBloc>(context),
          builder: (context, CreateClimbState state) {
            if (state.loading) {
              return Center(child: CircularProgressIndicator(strokeWidth: 4.0));
            } else {
              return Center(
                child: ListView(
                  children: <Widget>[_showForm(state, context)],
                ),
              );
            }
          }),
    );
  }

  Widget _showForm(CreateClimbState state, BuildContext context) {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: state.formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showDisplayNameInput(state),
              Row(children: <Widget>[
                Expanded(
                  child: _showGradeDropdown(state, context),
                ),
                Expanded(
                  child: _showSectionDropdown(state, context),
                )
              ]),
              _showCategorySelection(state, context),
              _showSubmitButton(state, context)
            ],
          ),
        ));
  }

  Widget _showDisplayNameInput(CreateClimbState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
          UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        initialValue: state.displayName,
        decoration: new InputDecoration(
            hintText: 'Climb name (Optional)',
            icon: new Icon(
              Icons.text_fields,
              color: Colors.grey,
            )),
        onSaved: (value) => state.displayName = value.trim(),
      ),
    );
  }

  Widget _showGradeDropdown(CreateClimbState state, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
        child: DropdownButtonFormField<String>(
          items: _createDropdownItems(state.availableGrades),
          value: state.grade,
          hint: Text("Grade"),
          isExpanded: true,
          validator: (String value) {
            if (value == null) {
              return 'A grade must be selected';
            }
            return null;
          },
          onChanged: (value) => BlocProvider.of<CreateClimbBloc>(context).selectGrade(value),
        ));
  }

  Widget _showSectionDropdown(CreateClimbState state, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
        child: DropdownButtonFormField<String>(
          disabledHint: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
            Icon(Icons.cancel, color: Colors.grey),
            Text("No sections"),
          ]),
          iconDisabledColor: Colors.grey,
          items: _createDropdownItems(widget.availableSections),
          value: state.section,
          hint: Text("Section"),
          isExpanded: true,
          validator: (String value) {
            if (widget.availableSections.isNotEmpty) {
              if (value == null) {
                return 'A section must be selected';
              }
            }
            return null;
          },
          onChanged: (value) => BlocProvider.of<CreateClimbBloc>(context).selectSection(value),
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

  Widget _showCategorySelection(CreateClimbState state, BuildContext context) {
    List<Widget> itemChips = List<Widget>();
    widget.categories.forEach((item) {
      itemChips.add(_buildItemChip(state, context, item));
    });
    return Container(
        constraints: BoxConstraints(
          minHeight: 140.0,
          maxHeight: 140.0,
          maxWidth: 300.0,
          minWidth: 300.0,
        ),
        child: (itemChips.isNotEmpty)
            ? SingleChildScrollView(
                child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: UIConstants.SMALLER_PADDING,
                    runSpacing: 0.0,
                    children: itemChips))
            : Center(
                child: Container(
                    child: Text("You don't currently have any climb categories",
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))));
  }

  Widget _buildItemChip(CreateClimbState state, BuildContext context, String item) {
    return Container(
      child: InputChip(
        label: Text(item),
        selected: state.selectedCategories.contains(item),
        onSelected: (selected) =>
            BlocProvider.of<CreateClimbBloc>(context).toggleCategory(selected, item),
      ),
    );
  }

  Widget _showSubmitButton(CreateClimbState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, UIConstants.STANDARD_PADDING,
            UIConstants.STANDARD_PADDING, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: new Text('Submit', style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () =>
                BlocProvider.of<CreateClimbBloc>(context).validateAndSubmit(state, context, this),
          ),
        ));
  }

  void _showDeleteClimbDialog(
      String climbId, BuildContext upperContext, CreateClimbWidget view, List<String> categories) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Are you sure you want to delete this climb?"),
              content: Text("There is no way to get it back"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: navigateToLocation,
                ),
                FlatButton(
                  child: Text("Delete"),
                  onPressed: () => BlocProvider.of<CreateClimbBloc>(upperContext)
                      .deleteClimb(upperContext, view, widget.selectedLocation, categories),
                )
              ]);
        });
  }

  void navigateToLocation() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }
}
