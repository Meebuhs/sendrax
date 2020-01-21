import 'package:flutter/widgets.dart';

class AddSectionsState {
  List<String> itemList;
  final GlobalKey<FormFieldState> itemInputKey;

  // @formatter:off
  AddSectionsState._internal(this.itemList, this.itemInputKey);

  factory AddSectionsState.initial(List<String> itemList) => AddSectionsState._internal(itemList, new GlobalKey<FormFieldState>());

  factory AddSectionsState.itemList(List<String> itemList, AddSectionsState state) =>
      AddSectionsState._internal(itemList, state.itemInputKey);
  }
// @formatter:on
