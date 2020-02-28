import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/attempt_repo.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/climb_repo.dart';
import 'package:sendrax/models/storage_repo.dart';
import 'package:sendrax/models/user_repo.dart';

import 'create_climb_event.dart';
import 'create_climb_state.dart';
import 'create_climb_view.dart';

class CreateClimbBloc extends Bloc<CreateClimbEvent, CreateClimbState> {
  CreateClimbBloc(this.climb, this.grades);

  final Climb climb;
  final List<String> grades;

  @override
  CreateClimbState get initialState {
    return CreateClimbState.initial(climb, grades);
  }

  void validateAndSubmit(
      bool isEdit, CreateClimbState state, BuildContext context, CreateClimbWidget view) async {
    FocusScope.of(context).unfocus();
    state.loading = true;

    if (_validateAndSave(state)) {
      if (state.deleteImage) {
        StorageRepo.getInstance().deleteFileByUri(state.imageUri);
        state.imageUri = "";
        state.imageUrl = "";
      } else if (state.imageFile != null) {
        if (state.imageUri != "") {
          StorageRepo.getInstance().deleteFileByUri(state.imageUri);
        }
        state.imageUri = await StorageRepo.getInstance().uploadFile(state.imageFile);
        state.imageUrl = await StorageRepo.getInstance().decodeUri(state.imageUri);
      }

      Climb climb = Climb(
          this.climb.id,
          state.displayName,
          state.imageUrl,
          state.imageUri,
          this.climb.locationId,
          state.grade,
          state.gradeSet,
          state.section,
          false,
          state.selectedCategories, <Attempt>[]);
      try {
        ClimbRepo.getInstance().setClimb(climb);
        if (isEdit) {
          final user = await UserRepo.getInstance().getCurrentUser();
          List<Attempt> attempts =
              await ClimbRepo.getInstance().getAttemptsByClimbId(climb.id, user).first;
          for (Attempt attempt in attempts) {
            Attempt updatedAttempt = Attempt(
                attempt.id,
                attempt.climbId,
                state.displayName,
                state.grade,
                state.gradeSet,
                state.selectedCategories,
                attempt.locationId,
                attempt.timestamp,
                attempt.sendType,
                attempt.downclimbed,
                attempt.notes);
            AttemptRepo.getInstance().setAttempt(updatedAttempt);
          }
        }
        state.loading = false;
      } catch (e) {
        state.formKey.currentState.reset();
        state.loading = false;
        add(CreateClimbErrorEvent());
      }
      view.navigateToClimb(state);
    }
    state.loading = false;
  }

  bool _validateAndSave(CreateClimbState state) {
    final form = state.formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void selectGrade(String grade) {
    add(GradeSelectedEvent(grade));
  }

  void selectSection(String section) {
    add(SectionSelectedEvent(section));
  }

  void toggleCategory(bool selected, String category) {
    List<String> selectedCategories = state.selectedCategories;
    if (selected) {
      selectedCategories.add(category);
    } else {
      selectedCategories.remove(category);
    }
    add(CategoriesUpdatedEvent(selectedCategories));
  }

  void setImageFile(File image) {
    add(ImageFileUpdatedEvent(false, image));
  }

  void deleteImage() {
    add(ImageFileUpdatedEvent(true, null));
  }

  @override
  Stream<CreateClimbState> mapEventToState(CreateClimbEvent event) async* {
    if (event is GradeSelectedEvent) {
      yield CreateClimbState.selectGrade(event.grade, state);
    } else if (event is SectionSelectedEvent) {
      yield CreateClimbState.selectSection(event.section, state);
    } else if (event is CategoriesUpdatedEvent) {
      yield CreateClimbState.updateCategories(event.selectedCategories, state);
    } else if (event is ImageFileUpdatedEvent) {
      yield CreateClimbState.updateImageFile(event.deleteImage, event.imageFile, state);
    } else if (event is CreateClimbErrorEvent) {
      yield CreateClimbState.loading(false, state);
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
