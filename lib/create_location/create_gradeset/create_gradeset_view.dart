import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'create_gradeset_bloc.dart';
import 'create_gradeset_state.dart';

class CreateGradeSet extends StatefulWidget {
  CreateGradeSet({Key key}) : super(key: key);

  @override
  _CreateGradeSetState createState() => _CreateGradeSetState();
}

class _CreateGradeSetState extends State<CreateGradeSet> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateGradeSetBloc>(
      create: (context) => CreateGradeSetBloc(),
      child: CreateGradeSetWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class CreateGradeSetWidget extends StatelessWidget {
  const CreateGradeSetWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final CreateGradeSet widget;
  final _CreateGradeSetState widgetState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<CreateGradeSetBloc>(context),
        builder: (context, CreateGradeSetState state) {
          return Container(
              constraints: BoxConstraints(
                minHeight: 250.0,
                maxHeight: 250.0,
                minWidth: 300.0,
                maxWidth: 300.0,
              ),
              child: Column(children: <Widget>[
                _showNameInput(state),
                _showItemList(state, context),
                Row(children: <Widget>[
                  Expanded(
                    child: _showAddItemInput(state),
                  ),
                  Expanded(
                    child: _showAddItemButton(state, context),
                  ),
                ]),
                Row(children: <Widget>[
                  Expanded(
                    child: _showErrorMessage(state, context),
                  ),
                  _showCancelButton(state, context),
                  _showSubmitButton(state, context),
                ]),
              ]));
        });
  }

  Widget _showNameInput(CreateGradeSetState state) {
    return Form(
        key: state.formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 10.0),
          child: new TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.text,
            autofocus: true,
            decoration: new InputDecoration(
                hintText: "Grade set name",
                icon: new Icon(
                  Icons.text_fields,
                  color: Colors.grey,
                )),
            onSaved: (value) => state.name = value.trim(),
          ),
        ));
  }

  Widget _showItemList(CreateGradeSetState state, BuildContext context) {
    List<Widget> itemChips = List<Widget>();
    state.grades.forEach((item) {
      itemChips.add(_buildItemChip(state, context, item));
    });
    return Container(
        constraints: BoxConstraints(
          minHeight: 85.0,
          maxHeight: 85.0,
          maxWidth: 300.0,
          minWidth: 300.0,
        ),
        child: SingleChildScrollView(
            child: Wrap(
                alignment: WrapAlignment.center,
                spacing: UIConstants.SMALLER_PADDING,
                runSpacing: 0.0,
                children: itemChips)));
  }

  Widget _buildItemChip(CreateGradeSetState state, BuildContext context, String item) {
    return Container(
      child: InputChip(
        label: Text(item),
        deleteIcon: new Icon(
          Icons.cancel,
          color: Colors.grey,
        ),
        onDeleted: () => BlocProvider.of<CreateGradeSetBloc>(context).removeGrade(item),
      ),
    );
  }

  Widget _showAddItemInput(CreateGradeSetState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 10.0),
      child: new TextFormField(
        key: state.itemInputKey,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: true,
        decoration: new InputDecoration(
            hintText: "Grade",
            icon: new Icon(
              Icons.add,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget _showAddItemButton(CreateGradeSetState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(
            UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 10.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: new Text('Add', style: new TextStyle(fontSize: 14.0, color: Colors.white)),
            onPressed: () => BlocProvider.of<CreateGradeSetBloc>(context)
                .addGrade(state.itemInputKey.currentState.value.trim()),
          ),
        ));
  }

  Widget _showErrorMessage(CreateGradeSetState state, BuildContext context) {
    if (state.errorMessage.length > 0) {
      return Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
              padding: EdgeInsets.fromLTRB(
                  UIConstants.STANDARD_PADDING, 2.0, UIConstants.STANDARD_PADDING, 0.0),
              child: Text(
                state.errorMessage,
                style: TextStyle(
                    fontSize: 13.0, color: Colors.red, height: 1.0, fontWeight: FontWeight.w400),
              )));
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showCancelButton(CreateGradeSetState state, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: FlatButton(
        onPressed: () => NavigationHelper.navigateBackOne(context),
        child: Text('Cancel'),
      ),
    );
  }

  Widget _showSubmitButton(CreateGradeSetState state, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: FlatButton(
        onPressed: () => BlocProvider.of<CreateGradeSetBloc>(context).createGradeSet(context),
        child: Text('Create'),
      ),
    );
  }
}
