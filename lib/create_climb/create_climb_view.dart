import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'create_climb_bloc.dart';
import 'create_climb_state.dart';

class CreateClimbScreen extends StatefulWidget {
  CreateClimbScreen({Key key, @required this.climb, @required this.availableSections, @required this.isEdit}) : super(key: key);

  final Climb climb;
  final List<String> availableSections;
  final bool isEdit;

  @override
  State<StatefulWidget> createState() => _CreateClimbState(climb, availableSections, isEdit);
}

class _CreateClimbState extends State<CreateClimbScreen> {
  final Climb climb;
  final List<String> availableSections;
  final bool isEdit;

  _CreateClimbState(this.climb, this.availableSections, this.isEdit);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateClimbBloc>(
      create: (context) => CreateClimbBloc(climb, availableSections, isEdit),
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
    return Scaffold(
      appBar: AppBar(
        title: Text((widgetState.isEdit)
            ? "Edit ${widgetState.climb.displayName}"
            : "Create a climb"),
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
            hintText: 'Climb name',
            icon: new Icon(
              Icons.text_fields,
              color: Colors.grey,
            )),
        validator: (String value) {
          if (value.trim().isEmpty) {
            return 'Climb must have a name';
          }
          return null;
        },
        onSaved: (value) => state.displayName = value.trim(),
      ),
    );
  }

  Widget _showGradeDropdown(CreateClimbState state, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
        child: new StreamBuilder(
          stream: BlocProvider.of<CreateClimbBloc>(context).gradeStream.stream,
          initialData: state.grade,
          builder: (BuildContext context, snapshot) {
            return new DropdownButton<String>(
              items: _createDropdownItems(state.availableGrades),
              value: snapshot.data,
              hint: Text("Grade"),
              isExpanded: true,
              onChanged: (value) => BlocProvider.of<CreateClimbBloc>(context).selectGrade(value),
            );
          },
        ));
  }

  Widget _showSectionDropdown(CreateClimbState state, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(UIConstants.STANDARD_PADDING, 0.0,
            UIConstants.STANDARD_PADDING, UIConstants.BIGGER_PADDING),
        child: new StreamBuilder(
          stream: BlocProvider.of<CreateClimbBloc>(context).sectionStream.stream,
          initialData: state.section,
          builder: (BuildContext context, snapshot) {
            return new DropdownButton<String>(
              items: _createDropdownItems(state.availableSections),
              value: snapshot.data,
              hint: Text("Section"),
              isExpanded: true,
              onChanged: (value) => BlocProvider.of<CreateClimbBloc>(context).selectSection(value),
            );
          },
        ));
  }

  List<DropdownMenuItem> _createDropdownItems(List<String> items) {
    return items.map((String value) {
      return new DropdownMenuItem<String>(
        value: value,
        child: new Text(value),
      );
    }).toList();
  }

  Widget _showCategorySelection(CreateClimbState state, BuildContext context) {
    return Container(
      height: 0,
    );
  }

  Widget _showSubmitButton(CreateClimbState state, BuildContext context) {
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
            onPressed: () => BlocProvider.of<CreateClimbBloc>(context)
                .validateAndSubmit(state, context, this),
          ),
        ));
  }

  void navigateToLocation() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }
}
