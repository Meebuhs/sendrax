import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:sendrax/models/grade_repo.dart';
import 'package:sendrax/models/gradeset.dart';
import 'package:sendrax/navigation_helper.dart';

import 'create_gradeset_event.dart';
import 'create_gradeset_state.dart';

class CreateGradeSetBloc extends Bloc<CreateGradeSetEvent, CreateGradeSetState> {
  StreamController itemStream = StreamController<List<String>>();
  StreamController errorMessageStream = StreamController<String>();

  @override
  CreateGradeSetState get initialState {
    return CreateGradeSetState.initial();
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

  List<String> getItemList() {
    return state.itemList;
  }

  void createGradeSet(BuildContext context) async {
    if (_validateAndSave(state)) {
      GradeRepo.getInstance().setGradeSet(new GradeSet(state.name, state.itemList));
      NavigationHelper.navigateBackOne(context);
    }
  }

  bool _validateAndSave(CreateGradeSetState state) {
    final form = state.formKey.currentState;
    form.save();

    if (state.name.trim() == "") {
      state.errorMessage = "Name can't be empty";
      errorMessageStream.sink.add(state.errorMessage);
      return false;
    } else if (state.itemList.isEmpty) {
      state.errorMessage = "Grades can't be empty";
      errorMessageStream.sink.add(state.errorMessage);
      return false;
    }
    return true;
  }

  @override
  Stream<CreateGradeSetState> mapEventToState(CreateGradeSetEvent event) async* {}

  @override
  Future<void> close() {
    itemStream.close();
    errorMessageStream.close();
    return super.close();
  }
}
