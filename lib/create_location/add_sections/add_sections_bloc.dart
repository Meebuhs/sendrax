import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/navigation_helper.dart';

import 'add_sections_event.dart';
import 'add_sections_state.dart';

class AddSectionsBloc extends Bloc<AddSectionsEvent, AddSectionsState> {
  AddSectionsBloc(this.sections, this.sectionsStream);

  final List<String> sections;
  final StreamController<List<String>> sectionsStream;

  @override
  AddSectionsState get initialState {
    return AddSectionsState.initial(sections);
  }

  void addSection(String section) {
    if (section.trim().isNotEmpty) {
      add(SectionAddedEvent(section));
      state.itemInputKey.currentState.reset();
    }
  }

  void removeSection(String section) {
    add(SectionRemovedEvent(section));
  }

  void addSections(BuildContext context) async {
    sectionsStream.add(state.sections);
    NavigationHelper.navigateBackOne(context);
  }

  @override
  Stream<AddSectionsState> mapEventToState(AddSectionsEvent event) async* {
    if (event is SectionAddedEvent) {
      yield AddSectionsState.addSection(event.section, state);
    } else if (event is SectionRemovedEvent) {
      yield AddSectionsState.removeSection(event.section, state);
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
