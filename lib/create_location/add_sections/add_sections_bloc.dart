import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:sendrax/navigation_helper.dart';

import 'add_sections_event.dart';
import 'add_sections_state.dart';

class AddSectionsBloc extends Bloc<AddSectionsEvent, AddSectionsState> {
  AddSectionsBloc(this.itemList, this.sectionsStream);

  final List<String> itemList;
  final StreamController<List<String>> sectionsStream;

  StreamController itemStream = StreamController<List<String>>();

  @override
  AddSectionsState get initialState {
    return AddSectionsState.initial(itemList);
  }

  void addItem(String item) {
    if (item.trim().isNotEmpty) {
      state.itemList.add(item);
      state.itemInputKey.currentState.reset();
      itemStream.add(state.itemList);
    }
  }

  void removeItem(String item) {
    state.itemList.remove(item);
    itemStream.add(state.itemList);
  }

  void addSections(BuildContext context) async {
    sectionsStream.add(state.itemList);
    NavigationHelper.navigateBackOne(context);
  }

  @override
  Stream<AddSectionsState> mapEventToState(AddSectionsEvent event) async* {}

  @override
  Future<void> close() {
    itemStream.close();
    return super.close();
  }
}
