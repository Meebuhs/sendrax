import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/location/location_climb_item.dart';
import 'package:sendrax/models/climb.dart';
import 'package:sendrax/util/constants.dart';

import 'location_bloc.dart';
import 'location_state.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen(
      {Key key, @required this.displayName, @required this.locationId})
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
      child: LocationWidget(widget: widget),
    );
  }
}

class LocationWidget extends StatelessWidget {
  const LocationWidget({Key key, @required this.widget}) : super(key: key);

  final LocationScreen widget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.displayName)),
      body: BlocBuilder(
          bloc: BlocProvider.of<LocationBloc>(context),
          builder: (context, LocationState state) {
            Widget content;
            if (state.isLoading) {
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
                  return InkWell(child: _buildItem(state.climbs[index]));
                },
                itemCount: state.climbs.length,
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

  ClimbItem _buildItem(Climb climb) {
    return ClimbItem(climb: climb);
  }
}
