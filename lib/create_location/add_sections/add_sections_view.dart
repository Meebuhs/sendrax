import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/util/constants.dart';

import 'add_sections_bloc.dart';
import 'add_sections_state.dart';

class AddSections extends StatefulWidget {
  AddSections({Key key, @required this.sections, @required this.sectionsStream}) : super(key: key);

  final List<String> sections;
  final StreamController<List<String>> sectionsStream;

  @override
  _AddSectionsState createState() => _AddSectionsState(sections, sectionsStream);
}

class _AddSectionsState extends State<AddSections> {
  final List<String> itemList;
  final StreamController<List<String>> sectionsStream;

  _AddSectionsState(this.itemList, this.sectionsStream);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddSectionsBloc>(
      create: (context) => AddSectionsBloc(itemList, sectionsStream),
      child: AddSectionsWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class AddSectionsWidget extends StatelessWidget {
  const AddSectionsWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final AddSections widget;
  final _AddSectionsState widgetState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<AddSectionsBloc>(context),
        builder: (context, AddSectionsState state) {
          return Container(
              constraints: BoxConstraints(
                minHeight: 250.0,
                maxHeight: 250.0,
                minWidth: 300.0,
                maxWidth: 300.0,
              ),
              child: Column(children: <Widget>[
                _showItemList(state, context),
                Row(children: <Widget>[
                  Expanded(
                    child: _showAddItemInput(state),
                  ),
                  Expanded(
                    child: _showAddItemButton(state, context),
                  ),
                ]),
                _showSubmitButton(state, context),
              ]));
        });
  }

  Widget _showItemList(AddSectionsState state, BuildContext context) {
    List<Widget> itemChips = List<Widget>();
    state.sections.forEach((item) {
      itemChips.add(_buildItemChip(state, context, item));
    });

    return Container(
        constraints: BoxConstraints(
          minHeight: 140.0,
          maxHeight: 140.0,
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

  Widget _buildItemChip(AddSectionsState state, BuildContext context, String item) {
    return Container(
      child: InputChip(
        label: Text(item),
        deleteIcon: new Icon(
          Icons.cancel,
          color: Colors.grey,
        ),
        onDeleted: () => BlocProvider.of<AddSectionsBloc>(context).removeSection(item),
      ),
    );
  }

  Widget _showAddItemInput(AddSectionsState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 10.0),
      child: new TextFormField(
        key: state.itemInputKey,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: true,
        decoration: new InputDecoration(
            hintText: "Section",
            icon: new Icon(
              Icons.add,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget _showAddItemButton(AddSectionsState state, BuildContext context) {
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
            onPressed: () => BlocProvider.of<AddSectionsBloc>(context)
                .addSection(state.itemInputKey.currentState.value.trim()),
          ),
        ));
  }

  Widget _showSubmitButton(AddSectionsState state, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: FlatButton(
        onPressed: () => BlocProvider.of<AddSectionsBloc>(context).addSections(context),
        child: Text('Finished'),
      ),
    );
  }
}
