import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sendrax/create_location/create_location_event.dart';
import 'package:sendrax/create_location/create_location_state.dart';
import 'package:sendrax/create_location/create_location_view.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/grade_repo.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/models/location_repo.dart';
import 'package:sendrax/models/storage_repo.dart';
import 'package:sendrax/models/user_repo.dart';
import 'package:sendrax/navigation_helper.dart';

class CreateLocationBloc extends Bloc<CreateLocationEvent, CreateLocationState> {
  CreateLocationBloc(this.location, this.categories, this.isEdit);

  final Location location;
  final List<String> categories;
  final bool isEdit;

  StreamController sectionsStream = StreamController<List<String>>.broadcast();
  StreamSubscription<List<String>> gradesSubscription;
  StreamSubscription<Location> locationSubscription;

  @override
  CreateLocationState get initialState {
    _retrieveGradeSets();
    return CreateLocationState.initial(location, isEdit);
  }

  void _retrieveGradeSets() async {
    add(GradesClearedEvent());
    final user = await UserRepo.getInstance().getCurrentUser();
    if (user != null) {
      gradesSubscription = GradeRepo.getInstance().getGradeIds(user).listen((grades) {
        add(GradeSetsUpdatedEvent(grades));
      });
    } else {
      add(CreateLocationErrorEvent());
    }
  }

  void validateAndSubmit(
      CreateLocationState state, BuildContext context, CreateLocationWidget view) async {
    FocusScope.of(context).unfocus();
    state.loading = true;

    if (_validateAndSave()) {
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
      final user = await UserRepo.getInstance().getCurrentUser();
      List<String> grades =
          await GradeRepo.getInstance().getGradesForId(user, state.gradeSet).first;
      Location location = Location(
          this.location.id,
          state.displayName,
          state.imageUrl,
          state.imageUri, state.gradeSet, grades, state.sections, <Climb>[]);
      try {
        LocationRepo.getInstance().setLocation(location);
        state.loading = false;
      } catch (e) {
        state.formKey.currentState.reset();
        state.loading = false;
        add(CreateLocationErrorEvent());
      }
      _navigateToLocationAfterEdit(state, context);
    }
    state.loading = false;
  }

  bool _validateAndSave() {
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

  void setSectionsList(List<String> sections) {
    sectionsStream.stream.listen((sections) {
      state.sections = sections;
    });
  }

  void setImageFile(File image) {
    add(ImageFileUpdatedEvent(false, image));
  }

  void deleteImage() {
    add(ImageFileUpdatedEvent(true, null));
  }

  void deleteLocation(BuildContext context, CreateLocationWidget view) {
    LocationRepo.getInstance().deleteLocation(location.id, location.imageURI);
    NavigationHelper.resetToMain(context);
  }

  void _navigateToLocationAfterEdit(CreateLocationState state, BuildContext context) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    List<String> grades = await GradeRepo.getInstance().getGradesForId(user, state.gradeSet).first;
    Location location = Location(
        this.location.id,
        state.displayName,
        state.imageUrl,
        state.imageUri, state.gradeSet, grades, state.sections, <Climb>[]);
    NavigationHelper.resetToLocation(context, location, this.categories);
  }

  @override
  Stream<CreateLocationState> mapEventToState(CreateLocationEvent event) async* {
    if (event is GradesClearedEvent) {
      yield CreateLocationState.updateGradeSets(true, <String>[], state);
    } else if (event is LocationClearedEvent) {
      yield CreateLocationState.updateLocation(
          true,
          Location(this.location.id, state.displayName, state.imageUrl, state.imageUri,
              state.gradeSet, <String>[]),
          state);
    } else if (event is GradeSetsUpdatedEvent) {
      yield CreateLocationState.updateGradeSets(false, event.gradeSets, state);
    } else if (event is LocationUpdatedEvent) {
      yield CreateLocationState.updateLocation(false, event.location, state);
    } else if (event is CreateLocationErrorEvent) {
      yield CreateLocationState.loading(false, state);
    } else if (event is GradeSelectedEvent) {
      yield CreateLocationState.selectGradeSet(event.gradeSet, state);
    } else if (event is ImageFileUpdatedEvent) {
      yield CreateLocationState.updateImageFile(event.deleteImage, event.imageFile, state);
    }
  }

  @override
  Future<void> close() {
    sectionsStream.close();
    if (gradesSubscription != null) {
      gradesSubscription.cancel();
    }
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    return super.close();
  }
}
