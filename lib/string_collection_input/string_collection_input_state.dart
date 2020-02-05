import 'package:flutter/widgets.dart';

class StringCollectionInputState {
  List<String> items;
  final GlobalKey<FormFieldState> itemInputKey;

  // @formatter:off
  StringCollectionInputState._internal(this.items, this.itemInputKey);

  factory StringCollectionInputState.initial(List<String> sections) =>
      StringCollectionInputState._internal(sections, GlobalKey<FormFieldState>());

  factory StringCollectionInputState.addItem(String item, StringCollectionInputState state) =>
      StringCollectionInputState._internal(state.items..add(item), state.itemInputKey);

  factory StringCollectionInputState.removeItem(String item, StringCollectionInputState state) =>
      StringCollectionInputState._internal(state.items..remove(item), state.itemInputKey);
  }
// @formatter:on
