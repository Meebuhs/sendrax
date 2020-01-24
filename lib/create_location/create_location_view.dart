import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/create_location/add_sections/add_sections_view.dart';
import 'package:sendrax/create_location/create_gradeset/create_gradeset_view.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'create_location_bloc.dart';
import 'create_location_state.dart';

class CreateLocationScreen extends StatefulWidget {
  CreateLocationScreen({Key key, @required this.location, @required this.isEdit}) : super(key: key);

  final Location location;
  final bool isEdit;

  @override
  State<StatefulWidget> createState() => _CreateLocationState(location, isEdit);
}

class _CreateLocationState extends State<CreateLocationScreen> {
  final Location location;
  final bool isEdit;

  _CreateLocationState(this.location, this.isEdit);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateLocationBloc>(
      create: (context) => CreateLocationBloc(location, isEdit),
      child: CreateLocationWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class CreateLocationWidget extends StatelessWidget {
  const CreateLocationWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final CreateLocationScreen widget;
  final _CreateLocationState widgetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widgetState.isEdit)
            ? "Edit ${widgetState.location.displayName}"
            : "Create a location"),
        actions: <Widget>[
          (widgetState.isEdit)
              ? IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () => _showDeleteLocationDialog(widget.location.id, context, this),
                )
              : Container()
        ],
      ),
      body: BlocBuilder(
          bloc: BlocProvider.of<CreateLocationBloc>(context),
          builder: (context, CreateLocationState state) {
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

  Widget _showForm(CreateLocationState state, BuildContext context) {
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
                  child: _showGradesDropdown(state, context),
                ),
                Expanded(
                  child: _showGradeCreationButton(state, context),
                )
              ]),
              Center(child: _showSectionsText(state, context)),
              _showSectionCreator(state, context),
              _showSubmitButton(state, context)
            ],
          ),
        ));
  }

  Widget _showDisplayNameInput(CreateLocationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
          UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        initialValue: state.displayName,
        decoration: new InputDecoration(
            hintText: 'Location name',
            icon: new Icon(
              Icons.text_fields,
              color: Colors.grey,
            )),
        validator: (String value) {
          if (value.trim().isEmpty) {
            return 'Location must have a name';
          }
          return null;
        },
        onSaved: (value) => state.displayName = value.trim(),
      ),
    );
  }

  Widget _showGradesDropdown(CreateLocationState state, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
        child: new StreamBuilder(
          stream: BlocProvider.of<CreateLocationBloc>(context).gradesIdStream.stream,
          initialData: state.gradesId,
          builder: (BuildContext context, snapshot) {
            return new DropdownButtonFormField<String>(
              items: _createDropdownItems(state),
              value: snapshot.data,
              hint: Text("Grades"),
              isExpanded: true,
              validator: (String value) {
                if (value == null) {
                  return 'A grade set must be selected';
                }
                return null;
              },
              onChanged: (value) => BlocProvider.of<CreateLocationBloc>(context).selectGrade(value),
            );
          },
        ));
  }

  List<DropdownMenuItem> _createDropdownItems(CreateLocationState state) {
    return state.gradeIds.map((String value) {
      return new DropdownMenuItem<String>(
        value: value,
        child: new Text(value),
      );
    }).toList();
  }

  Widget _showGradeCreationButton(CreateLocationState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: new Text('Create a grade set',
                style: new TextStyle(fontSize: 14.0, color: Colors.white)),
            onPressed: () => _showCreateGradeSetDialog(context),
          ),
        ));
  }

  _showCreateGradeSetDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text("Create a grade set"), children: <Widget>[
            CreateGradeSet(),
          ]);
        });
  }

  Widget _showSectionsText(CreateLocationState state, BuildContext context) {
    return StreamBuilder(
        stream: BlocProvider.of<CreateLocationBloc>(context).sectionsStream.stream,
        initialData: (state.sections == null) ? <String>[] : state.sections,
        builder: (BuildContext context, snapshot) {
          return Padding(
              padding: EdgeInsets.fromLTRB(
                  UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 0.0),
              child: Text(
                (snapshot.data.isEmpty) ? "No sections added" : snapshot.data.join(', '),
                style: TextStyle(
                    fontSize: 13.0, color: Colors.grey, height: 1.0, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ));
        });
  }

  Widget _showSectionCreator(CreateLocationState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, UIConstants.SMALLER_PADDING,
            UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: new Text('Create sections (optional)',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () => _showAddSectionsDialog(state, context),
          ),
        ));
  }

  void _showAddSectionsDialog(CreateLocationState state, BuildContext context) {
    StreamController<List<String>> stream =
        BlocProvider.of<CreateLocationBloc>(context).sectionsStream;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text("Edit this location's sections"), children: <Widget>[
            AddSections(itemList: state.sections, sectionsStream: stream),
          ]);
        });
  }

  Widget _showSubmitButton(CreateLocationState state, BuildContext context) {
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
            onPressed: () => BlocProvider.of<CreateLocationBloc>(context)
                .validateAndSubmit(state, context, this),
          ),
        ));
  }

  void _showDeleteLocationDialog(
      String locationId, BuildContext upperContext, CreateLocationWidget view) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Are you sure you want to delete this location?"),
              content: Text("There is no way to get it back"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: navigateBackOne,
                ),
                FlatButton(
                  child: Text("Delete"),
                  onPressed: () => BlocProvider.of<CreateLocationBloc>(upperContext)
                      .deleteLocation(locationId, upperContext, view),
                )
              ]);
        });
  }

  void navigateBackOne() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }
}
