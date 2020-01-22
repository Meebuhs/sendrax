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
  LocationScreen({Key key, @required this.location})
      : super(key: key);

  final SelectedLocation location;

  @override
  State<StatefulWidget> createState() => _LocationState(location);
}

class _LocationState extends State<LocationScreen> {
  final SelectedLocation location;

  _LocationState(this.location);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>(
      create: (context) => LocationBloc(location),
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
            onPressed: () => _editLocation(widget.location.id, widget.location.displayName, widget.location.gradesId),
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
              content = ListView.builder(
                padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                itemBuilder: (context, index) {
                  return _buildSection(context, state, index);
                },
                itemCount: state.sections.length,
              );
            }
            return _wrapContentWithFab(state, context, content);
          }),
    );
  }

  Widget _buildSection(BuildContext context, LocationState state, int index) {
    List<Climb> climbsToInclude =
        List.from(state.climbs.where((climb) => climb.section == state.sections[index]));
    if (climbsToInclude.isNotEmpty) {
      return Column(children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.pinkAccent,
              padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
              child: Text(state.sections[index],
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
                      BlocProvider.of<LocationBloc>(context)
                          .retrieveClimb(state.climbs[index], this);
                    }))
                .toList())
      ]);
    } else {
      return Column();
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

  ClimbItem _buildItem(Climb climb) {
    return ClimbItem(climb: climb);
  }

  void _createClimb(LocationState state) {
    var uuid = new Uuid();
    // the null values for grade and section here are required as they are used as the initial
    // values for the dropdowns
    Climb climb = new Climb("climb-${uuid.v1()}", "", state.locationId, null, state.gradesId, null, false,
        <String>[]);
    NavigationHelper.navigateToCreateClimb(widgetState.context, climb, state.sections, false,
        addToBackStack: true);
  }

  void _editLocation(String locationId, String displayName, String gradesId) {
    Location location = new Location(locationId, displayName, gradesId);
    NavigationHelper.navigateToCreateLocation(widgetState.context, location, true,
        addToBackStack: true);
  }

  void navigateToClimb(SelectedClimb climb) {
    NavigationHelper.navigateToClimb(widgetState.context, climb.displayName, climb.id,
        addToBackStack: true);
  }
}
