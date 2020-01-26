import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/main/main_location_item.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';
import 'package:uuid/uuid.dart';

import 'main_bloc.dart';
import 'main_state.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainBloc>(
        create: (context) => MainBloc(), child: MainWidget(widget: widget, widgetState: this));
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key key, @required this.widget, @required this.widgetState}) : super(key: key);

  final MainScreen widget;
  final _MainState widgetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sendrax'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.lock_open),
            onPressed: () {
              BlocProvider.of<MainBloc>(context).logout(this);
            },
          )
        ],
      ),
      body: BlocBuilder(
          bloc: BlocProvider.of<MainBloc>(context),
          builder: (context, MainState state) {
            Widget content;
            if (state.loading) {
              content = Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4.0,
                ),
              );
            } else if (state.locations.isEmpty) {
              content = Center(
                child: Text(
                  "Looks like you don't have any locations\nLet's create one right now!",
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              content = GridView.builder(
                padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemBuilder: (context, index) {
                  return InkWell(
                    child: _buildItem(state.locations[index]),
                    onTap: () => _onLocationTap(state.locations[index], state.categories),
                  );
                },
                itemCount: state.locations.length,
              );
            }
            return _wrapContentWithFab(context, state, content);
          }),
    );
  }

  LocationItem _buildItem(Location location) {
    return LocationItem(location: location);
  }

  void _onLocationTap(Location location, List<String> categories) {
    SelectedLocation selectedLocation =
        SelectedLocation(location.id, location.displayName, location.gradesId);
    navigateToLocation(selectedLocation, categories);
  }

  Widget _wrapContentWithFab(BuildContext context, MainState state, Widget content) {
    return Stack(
      children: <Widget>[
        content,
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
          child: FloatingActionButton(
              onPressed: () => _createLocation(state),
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.pinkAccent,
              elevation: UIConstants.STANDARD_ELEVATION),
        )
      ],
    );
  }

  void _createLocation(MainState state) {
    var uuid = new Uuid();
    Location location =
        new Location("location-${uuid.v1()}", "", null, state.categories, <String>[], null);
    NavigationHelper.navigateToCreateLocation(widgetState.context, location, false,
        addToBackStack: true);
  }

  void navigateToLogin() {
    NavigationHelper.navigateToLogin(widgetState.context);
  }

  void navigateToLocation(SelectedLocation location, List<String> categories) {
    NavigationHelper.navigateToLocation(widgetState.context, location, categories,
        addToBackStack: true);
  }
}
