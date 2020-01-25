import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/location/location_climb_item.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';
import 'package:uuid/uuid.dart';

import 'location_bloc.dart';
import 'location_state.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({Key key, @required this.location, @required this.categories}) : super(key: key);

  final SelectedLocation location;
  final List<String> categories;

  @override
  State<StatefulWidget> createState() => _LocationState(location, categories);
}

class _LocationState extends State<LocationScreen> {
  final SelectedLocation location;
  final List<String> categories;

  _LocationState(this.location, this.categories);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>(
      create: (context) => LocationBloc(location, categories),
      child: LocationWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class LocationWidget extends StatelessWidget {
  const LocationWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final LocationScreen widget;
  final _LocationState widgetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.displayName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editLocation(
                widget.location.id, widget.location.displayName, widget.location.gradesId),
          )
        ],
      ),
      body: BlocBuilder(
          bloc: BlocProvider.of<LocationBloc>(context),
          builder: (context, LocationState state) {
            Widget content;
            if (state.loading) {
              content = Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4.0,
                ),
              );
            } else if (state.climbs.isEmpty) {
              content = Center(
                child: Text(
                  "This location doesn't have any climbs.\nLet's create one right now!",
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              content = _buildFilteredList(state, context);
            }
            return _wrapContentWithFab(state, context, content);
          }),
    );
  }

  Widget _buildFilteredList(LocationState state, BuildContext context) {
    return StreamBuilder(
        stream: BlocProvider.of<LocationBloc>(context).filterGradeStream.stream,
        initialData: state.filterGrade,
        builder: (BuildContext context, gradeSnapshot) {
          return StreamBuilder(
              stream: BlocProvider.of<LocationBloc>(context).filterSectionStream.stream,
              initialData: state.filterSection,
              builder: (BuildContext context, sectionSnapshot) {
                if (List.from(state.climbs.where((climb) =>
                    (sectionSnapshot.data == null || climb.section == sectionSnapshot.data) &&
                    (gradeSnapshot.data == null || climb.grade == gradeSnapshot.data))).isEmpty) {
                  return _showEmptyFilteredList(state, context);
                }
                if (state.sections.isNotEmpty) {
                  return _buildContentWithSections(
                      state, context, sectionSnapshot.data, gradeSnapshot.data);
                } else {
                  return _buildContentWithoutSections(state, context, gradeSnapshot.data);
                }
              });
        });
  }

  Widget _showEmptyFilteredList(LocationState state, BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _showFilterDropdownRow(state, context);
        } else {
          return Center(
              child: Text(
            "There are no climbs matching these filter parameters.",
            textAlign: TextAlign.center,
          ));
        }
      },
      itemCount: 2,
    );
  }

  Widget _buildContentWithSections(
      LocationState state, BuildContext context, String sectionSnapshot, String gradeSnapshot) {
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _showFilterDropdownRow(state, context);
        } else {
          if (sectionSnapshot != null) {
            return _buildSection(context, state, gradeSnapshot, sectionSnapshot);
          } else {
            return _buildSection(context, state, gradeSnapshot, state.sections[index - 1]);
          }
        }
      },
      itemCount: (state.filterSection != null) ? 2 : state.sections.length + 1,
    );
  }

  Widget _buildSection(
      BuildContext context, LocationState state, String filterGrade, String section) {
    List<Climb> climbsToInclude = List.from(state.climbs.where((climb) =>
        climb.section == section && (filterGrade == null || climb.grade == filterGrade)));
    if (climbsToInclude.isNotEmpty) {
      return Column(children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.pinkAccent,
              padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
              child: Text(section,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: UIConstants.BIGGER_FONT_SIZE, color: Colors.white)),
            ),
          ),
        ]),
        Column(
            children: climbsToInclude
                .map((climb) => new InkWell(
                    child: _buildItem(climb),
                    onTap: () {
                      navigateToClimb(climb, state);
                    }))
                .toList())
      ]);
    } else {
      return Column();
    }
  }

  Widget _buildContentWithoutSections(
      LocationState state, BuildContext context, String gradeSnapshot) {
    List<Climb> climbsToInclude =
        List.from(state.climbs.where((climb) => climb.grade == gradeSnapshot));
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _showFilterDropdownRow(state, context);
        } else {
          return _buildClimb(context, state, climbsToInclude, index - 1);
        }
      },
      itemCount: climbsToInclude.length + 1,
    );
  }

  Widget _buildClimb(BuildContext context, LocationState state, List<Climb> climbs, int index) {
    if (climbs.isNotEmpty) {
      return Column(children: [
        new InkWell(
            child: _buildItem(climbs[index]),
            onTap: () {
              navigateToClimb(climbs[index], state);
            })
      ]);
    } else {
      return Column();
    }
  }

  ClimbItem _buildItem(Climb climb) {
    return ClimbItem(climb: climb);
  }

  Widget _showFilterDropdownRow(LocationState state, BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        child: _showGradeDropdown(state, context),
      ),
      Expanded(
        child: _showSectionDropdown(state, context),
      )
    ]);
  }

  Widget _showGradeDropdown(LocationState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UIConstants.SMALLER_PADDING, 0.0,
          UIConstants.SMALLER_PADDING, UIConstants.BIGGER_PADDING),
      child: new StreamBuilder(
          stream: BlocProvider.of<LocationBloc>(context).filterGradeStream.stream,
          initialData: state.filterGrade,
          builder: (BuildContext context, snapshot) {
            return new Row(children: <Widget>[
              Expanded(
                  child: DropdownButton<String>(
                items: _createDropdownItems(state.grades),
                value: snapshot.data,
                hint: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                  Icon(Icons.filter_list, color: Colors.grey),
                  Text("Grade"),
                ]),
                isExpanded: true,
                onChanged: (value) => BlocProvider.of<LocationBloc>(context).selectGrade(value),
              )),
              IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () => BlocProvider.of<LocationBloc>(context).selectGrade(null))
            ]);
          }),
    );
  }

  Widget _showSectionDropdown(LocationState state, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(UIConstants.SMALLER_PADDING, 0.0,
            UIConstants.SMALLER_PADDING, UIConstants.BIGGER_PADDING),
        child: new StreamBuilder(
          stream: BlocProvider.of<LocationBloc>(context).filterSectionStream.stream,
          initialData: state.filterSection,
          builder: (BuildContext context, snapshot) {
            return new Row(children: <Widget>[
              Expanded(
                child: DropdownButton<String>(
                  disabledHint: Text("No sections"),
                  iconDisabledColor: Colors.grey,
                  items: _createDropdownItems(state.sections),
                  value: snapshot.data,
                  hint: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                    Icon(Icons.filter_list, color: Colors.grey),
                    Text("Section"),
                  ]),
                  isExpanded: true,
                  onChanged: (value) => BlocProvider.of<LocationBloc>(context).selectSection(value),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.cancel,
                      color: (state.sections.isEmpty) ? Colors.grey : Colors.black),
                  onPressed: () => BlocProvider.of<LocationBloc>(context).selectSection(null))
            ]);
          },
        ));
  }

  List<DropdownMenuItem> _createDropdownItems(List<String> items) {
    if (items.isNotEmpty) {
      return items.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList();
    } else {
      // null disables the dropdown
      return null;
    }
  }

  Widget _wrapContentWithFab(LocationState state, BuildContext context, Widget content) {
    return Stack(
      children: <Widget>[
        content,
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
          child: FloatingActionButton(
              onPressed: () => _createClimb(state),
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.pinkAccent,
              elevation: UIConstants.STANDARD_ELEVATION),
        )
      ],
    );
  }

  void _createClimb(LocationState state) {
    var uuid = new Uuid();
    // the null values for grade and section here are required as they are used as the initial
    // values for the dropdowns
    Climb climb = new Climb(
        "climb-${uuid.v1()}", "", state.locationId, null, state.gradesId, null, false, <String>[]);
    NavigationHelper.navigateToCreateClimb(
        widgetState.context,
        climb,
        SelectedLocation(state.locationId, widget.location.displayName, state.gradesId),
        state.sections,
        state.categories,
        false,
        addToBackStack: true);
  }

  void _editLocation(String locationId, String displayName, String gradesId) {
    Location location = new Location(locationId, displayName, gradesId, <String>[]);
    NavigationHelper.navigateToCreateLocation(widgetState.context, location, true,
        addToBackStack: true);
  }

  void navigateToClimb(Climb climb, LocationState state) {
    NavigationHelper.navigateToClimb(
        widgetState.context,
        climb,
        SelectedLocation(state.locationId, widget.location.displayName, state.gradesId),
        state.sections,
        state.categories,
        addToBackStack: true);
  }
}
