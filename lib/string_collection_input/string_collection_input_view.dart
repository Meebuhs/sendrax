import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/navigation_helper.dart';
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

class _StringCollectionInputScreenState
    extends State<StringCollectionInputScreen> {
  final List<String> itemList;
  final BuildContext upperContext;
  final Function(List<String>, BuildContext context) submitInput;

  _StringCollectionInputScreenState(
      this.itemList, this.upperContext, this.submitInput);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StringCollectionInputBloc>(
      create: (context) =>
          StringCollectionInputBloc(itemList, upperContext, submitInput),
      child: StringCollectionInputWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class StringCollectionInputWidget extends StatelessWidget {
  const StringCollectionInputWidget(
      {Key key, @required this.widget, @required this.widgetState})
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
                minHeight: 270.0,
                maxHeight: 270.0,
                minWidth: 300.0,
                maxWidth: 300.0,
              ),
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: UIConstants.STANDARD_PADDING),
                  child: Column(children: <Widget>[
                    _showItemList(state, context),
                    Row(children: <Widget>[
                      Expanded(
                        child: _showAddItemInput(state, context),
                      ),
                      _showAddItemButton(state, context),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _showCancelButton(state, context),
                        _showSubmitButton(state, context),
                      ],
                    )
                  ])));
        });
  }

  Widget _showItemList(StringCollectionInputState state, BuildContext context) {
    List<Widget> itemChips = [];
    state.items.forEach((item) {
      itemChips.add(_buildItemChip(state, context, item));
    });

    return Expanded(
        child: Padding(
            padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.all(
                        Radius.circular(UIConstants.FIELD_BORDER_RADIUS))),
                child: ListView(children: <Widget>[
                  Wrap(
                      alignment: WrapAlignment.center,
                      spacing: UIConstants.SMALLER_PADDING,
                      runSpacing: 0.0,
                      children: itemChips)
                ]))));
  }

  Widget _buildItemChip(
      StringCollectionInputState state, BuildContext context, String item) {
    return Container(
      child: InputChip(
        label: Text(item),
        backgroundColor: Theme.of(context).accentColor,
        labelStyle: Theme.of(context).primaryTextTheme.subtitle2,
        deleteIcon: Icon(
          Icons.cancel,
          color: Colors.black,
        ),
        onDeleted: () => BlocProvider.of<StringCollectionInputBloc>(context)
            .removeItem(item),
      ),
    );
  }

  Widget _showAddItemInput(
      StringCollectionInputState state, BuildContext context) {
    return TextFormField(
      key: state.itemInputKey,
      maxLines: 1,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      autofocus: true,
      style: Theme.of(context).accentTextTheme.subtitle2,
      decoration: InputDecoration(
          isDense: true,
          labelText: 'Section',
          filled: true,
          fillColor: Theme.of(context).dialogBackgroundColor,
          prefixIcon: Icon(
            Icons.add,
            color: Colors.grey,
          )),
    );
  }

  Widget _showAddItemButton(
      StringCollectionInputState state, BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: UIConstants.SMALLER_PADDING),
        child: Container(
          child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
              backgroundColor: Theme.of(context).accentColor,
            ),
            child:
                Text('ADD', style: Theme.of(context).primaryTextTheme.button),
            onPressed: () => BlocProvider.of<StringCollectionInputBloc>(context)
                .addItem(state.itemInputKey.currentState.value.trim()),
          ),
        ));
  }

  Widget _showCancelButton(
      StringCollectionInputState state, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: TextButton(
        onPressed: () => NavigationHelper.navigateBackOne(context),
        child: Text('CANCEL', style: Theme.of(context).accentTextTheme.button),
      ),
    );
  }

  Widget _showSubmitButton(
      StringCollectionInputState state, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: TextButton(
        onPressed: () => BlocProvider.of<StringCollectionInputBloc>(context)
            .submitItems(context),
        child:
            Text('FINISHED', style: Theme.of(context).accentTextTheme.button),
      ),
    );
  }
}
