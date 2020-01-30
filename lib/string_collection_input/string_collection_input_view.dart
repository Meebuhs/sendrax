import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/util/constants.dart';

import 'string_collection_input_bloc.dart';
import 'string_collection_input_state.dart';

class StringCollectionInputScreen extends StatefulWidget {
  StringCollectionInputScreen(
      {Key key,
      @required this.items,
      @required this.itemName,
      @required this.upperContext,
      @required this.submitInput})
      : super(key: key);

  final List<String> items;
  final String itemName;
  final BuildContext upperContext;
  final Function(List<String>, BuildContext context) submitInput;

  @override
  _StringCollectionInputScreenState createState() =>
      _StringCollectionInputScreenState(items, upperContext, submitInput);
}

class _StringCollectionInputScreenState extends State<StringCollectionInputScreen> {
  final List<String> itemList;
  final BuildContext upperContext;
  final Function(List<String>, BuildContext context) submitInput;

  _StringCollectionInputScreenState(this.itemList, this.upperContext, this.submitInput);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StringCollectionInputBloc>(
      create: (context) => StringCollectionInputBloc(itemList, upperContext, submitInput),
      child: StringCollectionInputWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class StringCollectionInputWidget extends StatelessWidget {
  const StringCollectionInputWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final StringCollectionInputScreen widget;
  final _StringCollectionInputScreenState widgetState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<StringCollectionInputBloc>(context),
        builder: (context, StringCollectionInputState state) {
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

  Widget _showItemList(StringCollectionInputState state, BuildContext context) {
    List<Widget> itemChips = List<Widget>();
    state.items.forEach((item) {
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

  Widget _buildItemChip(StringCollectionInputState state, BuildContext context, String item) {
    return Container(
      child: InputChip(
        label: Text(item),
        deleteIcon: new Icon(
          Icons.cancel,
          color: Colors.grey,
        ),
        onDeleted: () => BlocProvider.of<StringCollectionInputBloc>(context).removeItem(item),
      ),
    );
  }

  Widget _showAddItemInput(StringCollectionInputState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          UIConstants.STANDARD_PADDING, 0.0, UIConstants.STANDARD_PADDING, 10.0),
      child: new TextFormField(
        key: state.itemInputKey,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: true,
        decoration: new InputDecoration(
            hintText: widget.itemName,
            icon: new Icon(
              Icons.add,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget _showAddItemButton(StringCollectionInputState state, BuildContext context) {
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
            onPressed: () => BlocProvider.of<StringCollectionInputBloc>(context)
                .addItem(state.itemInputKey.currentState.value.trim()),
          ),
        ));
  }

  Widget _showSubmitButton(StringCollectionInputState state, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: FlatButton(
        onPressed: () => BlocProvider.of<StringCollectionInputBloc>(context).submitItems(context),
        child: Text('Finished'),
      ),
    );
  }
}
