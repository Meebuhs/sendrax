import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'edit_attempt_bloc.dart';
import 'edit_attempt_state.dart';

class EditAttemptScreen extends StatefulWidget {
  EditAttemptScreen({Key key, @required this.attempt}) : super(key: key);

  final Attempt attempt;

  @override
  _EditAttemptScreenState createState() => _EditAttemptScreenState();
}

class _EditAttemptScreenState extends State<EditAttemptScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditAttemptBloc>(
      create: (context) => EditAttemptBloc(widget.attempt),
      child: EditAttemptWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class EditAttemptWidget extends StatelessWidget {
  const EditAttemptWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final EditAttemptScreen widget;
  final _EditAttemptScreenState widgetState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<EditAttemptBloc>(context),
        builder: (context, EditAttemptState state) {
          return Container(
              constraints: BoxConstraints(
                minHeight: 220.0,
                maxHeight: 220.0,
                minWidth: 300.0,
                maxWidth: 300.0,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: UIConstants.STANDARD_PADDING),
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
                        child: Row(children: <Widget>[
                          Expanded(
                            child: _showSendTypeDropdown(state, context),
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
                              child: SizedBox(
                                width: 95,
                                child: _showDownclimbedCheckbox(state, context),
                              )),
                        ])),
                    Row(children: <Widget>[
                      Expanded(child: _showNotesInput(state, context)),
                    ]),
                    Padding(
                        padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            _showCancelButton(state, context),
                            _showSubmitButton(state, context)
                          ],
                        ))
                  ],
                ),
              ));
        });
  }

  Widget _showSendTypeDropdown(EditAttemptState state, BuildContext context) {
    return DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
      style: Theme.of(context).accentTextTheme.subtitle2,
      items: _createDropdownItems(SendTypes.SEND_TYPES),
      value: state.sendType,
      hint: Text("Send"),
      isExpanded: true,
      decoration: InputDecoration(filled: true, fillColor: Theme.of(context).dialogBackgroundColor),
      onChanged: (value) => BlocProvider.of<EditAttemptBloc>(context).selectSendType(value),
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

  Widget _showDownclimbedCheckbox(EditAttemptState state, BuildContext context) {
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
                BlocProvider.of<EditAttemptBloc>(context).toggleDownclimbedCheckbox(value)),
      ],
    );
  }

  Widget _showNotesInput(EditAttemptState state, BuildContext context) {
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
          fillColor: Theme.of(context).dialogBackgroundColor,
          suffixIcon: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () => BlocProvider.of<EditAttemptBloc>(context).resetNotesInput())),
    );
  }

  Widget _showCancelButton(EditAttemptState state, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: FlatButton(
        onPressed: () => NavigationHelper.navigateBackOne(context),
        child: Text('CANCEL', style: Theme.of(context).accentTextTheme.button),
      ),
    );
  }

  Widget _showSubmitButton(EditAttemptState state, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: FlatButton(
        onPressed: () {
          BlocProvider.of<EditAttemptBloc>(context).editAttempt();
          NavigationHelper.navigateBackOne(context);
        },
        child: Text('EDIT', style: Theme.of(context).accentTextTheme.button),
      ),
    );
  }
}
