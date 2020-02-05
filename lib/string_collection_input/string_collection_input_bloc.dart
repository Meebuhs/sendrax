import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/navigation_helper.dart';

import 'string_collection_input_event.dart';
import 'string_collection_input_state.dart';

class StringCollectionInputBloc
    extends Bloc<StringCollectionInputEvent, StringCollectionInputState> {
  StringCollectionInputBloc(this.items, this.upperContext, this.submitInput);

  final List<String> items;
  final BuildContext upperContext;
  final Function(List<String>, BuildContext context) submitInput;

  @override
  StringCollectionInputState get initialState {
    return StringCollectionInputState.initial(items);
  }

  void addItem(String item) {
    if (item.trim().isNotEmpty) {
      add(ItemAddedEvent(item));
      state.itemInputKey.currentState.reset();
    }
  }

  void removeItem(String item) {
    add(ItemRemovedEvent(item));
  }

  void submitItems(BuildContext context) async {
    this.submitInput(state.items, upperContext);
    NavigationHelper.navigateBackOne(context);
  }

  @override
  Stream<StringCollectionInputState> mapEventToState(StringCollectionInputEvent event) async* {
    if (event is ItemAddedEvent) {
      yield StringCollectionInputState.addItem(event.item, state);
    } else if (event is ItemRemovedEvent) {
      yield StringCollectionInputState.removeItem(event.item, state);
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
