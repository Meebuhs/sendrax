import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'create_gradeset/create_gradeset_view.dart';
import 'create_location_bloc.dart';
import 'create_location_state.dart';

class CreateLocationScreen extends StatefulWidget {
  CreateLocationScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateLocationBloc>(
      create: (context) => CreateLocationBloc(),
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
        title: Text("Create a location"),
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
              _showSectionCreator(state),
              _showSubmitButton(state, context)
            ],
          ),
        ));
  }

  Widget _showDisplayNameInput(CreateLocationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 50.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Location name',
            icon: new Icon(
              Icons.text_fields,
              color: Colors.grey,
            )),
        validator: (String value) {
          if (value
              .trim()
              .isEmpty) {
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
        padding: const EdgeInsets.fromLTRB(
            UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 0.0),
        child: new StreamBuilder(
          stream: BlocProvider
              .of<CreateLocationBloc>(context)
              .gradeIdStream
              .stream,
          builder: (BuildContext context, snapshot) {
            return new DropdownButton<String>(
              items: _createDropdownItems(state),
              value: snapshot.data,
              hint: Text("Grades"),
              isExpanded: true,
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
        padding: EdgeInsets.fromLTRB(
            UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: new Text('Create a grade set',
                style: new TextStyle(fontSize: 14.0, color: Colors.white)),
            onPressed: () => _showDialog(context),
          ),
        ));
  }

  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return SimpleDialog(title: Text("Create a grade set"), children: <Widget>[
            CreateGradeSet(),
          ]);
        });
  }

  Widget _showSectionCreator(CreateLocationState state) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: new Text('Create sections',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () => null,
          ),
        ));
  }

  Widget _showSubmitButton(CreateLocationState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: new Text('Submit', style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () =>
                BlocProvider.of<CreateLocationBloc>(context)
                    .validateAndSubmit(state, context, this),
          ),
        ));
  }

  void navigateToMain() {
    NavigationHelper.navigateBackOne(widgetState.context);
  }
}
