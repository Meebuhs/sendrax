import 'dart:async';

import 'package:bloc/bloc.dart';

import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  @override
  HistoryState get initialState {
    return HistoryState.initial();
  }

  void setGradeFilter(String grade) {
    add(GradeFilteredEvent(grade));
  }

  void setLocationFilter(String location) {
    add(LocationFilteredEvent(location));
  }

  void setCategoryFilter(String category) {
    add(CategoryFilteredEvent(category));
  }

  void clearFilters() {
    add(FiltersClearedEvent());
  }

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event) async* {
    if (event is FiltersClearedEvent) {
      yield HistoryState.clearFilters(state);
    } else if (event is GradeFilteredEvent) {
      yield HistoryState.setFilterGrade(event.filterGrade, state);
    } else if (event is LocationFilteredEvent) {
      yield HistoryState.setFilterLocation(event.filterLocation, state);
    } else if (event is CategoryFilteredEvent) {
      yield HistoryState.setFilterCategory(event.filterCategory, state);
    } else if (event is HistoryErrorEvent) {
      yield HistoryState.loading(false, state);
    }
  }
}
