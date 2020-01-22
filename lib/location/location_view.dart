import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/location/location_climb_item.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'location_bloc.dart';
import 'location_state.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({Key key, @required this.displayName, @required this.locationId})
      : super(key: key);

  final String displayName;
  final String locationId;

  @override
  State<StatefulWidget> createState() => _LocationState(locationId);
}

class _LocationState extends State<LocationScreen> {
  final String locationId;

  _LocationState(this.locationId);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>(
      create: (context) => LocationBloc(locationId),
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
        title: Text(widget.displayName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editLocation(widget.locationId, widget.displayName),
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
            return _wrapContentWithFab(context, content);
          }),
    );
  }

  Widget _wrapContentWithFab(BuildContext context, Widget content) {
    return Stack(
      children: <Widget>[
        content,
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
          child: FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.pinkAccent,
              elevation: UIConstants.STANDARD_ELEVATION),
        )
      ],
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

  ClimbItem _buildItem(Climb climb) {
    return ClimbItem(climb: climb);
  }

  void _editLocation(String locationId, String displayName) {
    Location location = new Location(locationId, displayName);
    NavigationHelper.navigateToCreateLocation(widgetState.context, location, true,
        addToBackStack: true);
  }

  void navigateToClimb(SelectedClimb climb) {
    NavigationHelper.navigateToClimb(widgetState.context, climb.displayName, climb.id,
        addToBackStack: true);
  }
}
