import 'package:flutter/widgets.dart';

class AddSectionsState {
  List<String> sections;
  final GlobalKey<FormFieldState> itemInputKey;

  // @formatter:off
  AddSectionsState._internal(this.sections, this.itemInputKey);

  factory AddSectionsState.initial(List<String> sections) =>
      AddSectionsState._internal(sections, new GlobalKey<FormFieldState>());

  factory AddSectionsState.addSection(String section, AddSectionsState state) =>
      AddSectionsState._internal(state.sections..add(section), state.itemInputKey);

  factory AddSectionsState.removeSection(String section, AddSectionsState state) =>
      AddSectionsState._internal(state.sections..remove(section), state.itemInputKey);
}
// @formatter:on
