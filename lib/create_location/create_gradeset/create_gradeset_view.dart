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
                minHeight: 270.0,
                maxHeight: 270.0,
                minWidth: 300.0,
                maxWidth: 300.0,
              ),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: UIConstants.STANDARD_PADDING),
                  child: Column(children: <Widget>[
                    _showNameInput(state, context),
                    _showItemList(state, context),
                    Row(children: <Widget>[
                      Expanded(
                        child: _showAddItemInput(state, context),
                      ),
                      _showAddItemButton(state, context),
                    ]),
                    Row(children: <Widget>[
                      Expanded(
                        child: _showErrorMessage(state, context),
                      ),
                      _showCancelButton(state, context),
                      _showSubmitButton(state, context),
                    ]),
                  ])));
        });
  }

  Widget _showNameInput(CreateGradeSetState state, BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
        child: Form(
          key: state.formKey,
          child: TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            autofocus: false,
            style: Theme.of(context).accentTextTheme.subtitle2,
            decoration: InputDecoration(
                isDense: true,
                labelText: 'Name',
                filled: true,
                fillColor: Theme.of(context).dialogBackgroundColor,
                prefixIcon: Icon(
                  Icons.text_fields,
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
    return Expanded(
        child: Padding(
            padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.FIELD_BORDER_RADIUS))),
                child: ListView(children: <Widget>[
                  Wrap(
                      alignment: WrapAlignment.center,
                      spacing: UIConstants.SMALLER_PADDING,
                      runSpacing: 0.0,
                      children: itemChips)
                ]))));
  }

  Widget _buildItemChip(CreateGradeSetState state, BuildContext context, String item) {
    return Container(
      child: InputChip(
        label: Text(item),
        backgroundColor: Theme.of(context).accentColor,
        labelStyle: Theme.of(context).primaryTextTheme.subtitle2,
        deleteIcon: Icon(
          Icons.cancel,
          color: Colors.black,
        ),
        onDeleted: () => BlocProvider.of<CreateGradeSetBloc>(context).removeGrade(item),
      ),
    );
  }

  Widget _showAddItemInput(CreateGradeSetState state, BuildContext context) {
    return TextFormField(
      key: state.itemInputKey,
      maxLines: 1,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      autofocus: true,
      style: Theme.of(context).accentTextTheme.subtitle2,
      decoration: InputDecoration(
          isDense: true,
          labelText: 'Grade',
          filled: true,
          fillColor: Theme.of(context).dialogBackgroundColor,
          prefixIcon: Icon(
            Icons.add,
            color: Colors.grey,
          )),
    );
  }

  Widget _showAddItemButton(CreateGradeSetState state, BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: UIConstants.SMALLER_PADDING),
        child: Container(
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
            color: Theme.of(context).accentColor,
            child: Text('ADD', style: Theme.of(context).primaryTextTheme.button),
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
      return Container(
        height: 0.0,
      );
    }
  }

  Widget _showCancelButton(CreateGradeSetState state, BuildContext context) {
    return Align(
        alignment: Alignment.bottomRight,
        child: FlatButton(
            onPressed: () => NavigationHelper.navigateBackOne(context),
            child: Text('CANCEL', style: Theme.of(context).accentTextTheme.button)));
  }

  Widget _showSubmitButton(CreateGradeSetState state, BuildContext context) {
    return Align(
        alignment: Alignment.bottomRight,
        child: FlatButton(
            onPressed: () => BlocProvider.of<CreateGradeSetBloc>(context).createGradeSet(context),
            child: Text('CREATE', style: Theme.of(context).accentTextTheme.button)));
  }
}
