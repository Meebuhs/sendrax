import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/main/main_location_item.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/string_collection_input/string_collection_input_view.dart';
import 'package:sendrax/util/constants.dart';
import 'package:uuid/uuid.dart';

import 'main_bloc.dart';
import 'main_state.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<MainScreen> with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

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
    SelectedLocation selectedLocation = SelectedLocation(location.id, location.displayName,
        location.imagePath, location.imageUri, location.gradeSet);
    navigateToLocation(selectedLocation, categories);
  }

  Widget _wrapContentWithFab(BuildContext context, MainState state, Widget content) {
    return Stack(
      children: <Widget>[
        content,
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
          child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _buildMiniFab("Edit categories", Icon(Icons.mode_edit, color: Colors.pink),
                    _showEditCategoriesDialog, state, context),
                _buildMiniFab("Add location", Icon(Icons.add, color: Colors.pink), _createLocation,
                    state, context),
                _showMainFab(),
              ]),
        )
      ],
    );
  }

  Widget _buildMiniFab(String labelText, Icon icon, Function(MainState, BuildContext) onPressed,
      MainState state, BuildContext context) {
    double totalWidth = 160;
    double fabContainerSize = 56;
    double xProportionToFabCenter = 1 - (fabContainerSize / 2 / totalWidth);
    return Container(
        height: 60.0,
        width: totalWidth,
        alignment: FractionalOffset.center,
        child: ScaleTransition(
          alignment: FractionalOffset(xProportionToFabCenter, 0.5),
          scale: CurvedAnimation(
            parent: widgetState._animationController,
            curve: Interval(0.0, 1.0, curve: Curves.easeOutQuad),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(labelText),
              Container(
                  height: fabContainerSize,
                  width: fabContainerSize,
                  alignment: FractionalOffset.center,
                  child: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.white,
                    mini: true,
                    child: icon,
                    onPressed: () => onPressed(state, context),
                  ))
            ],
          ),
        ));
  }

  Widget _showMainFab() {
    return Container(
        alignment: FractionalOffset.bottomRight,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, UIConstants.SMALLER_PADDING, 0.0, 0.0),
            child: FloatingActionButton(
              heroTag: null,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: widgetState._animationController,
              ),
              onPressed: () {
                if (widgetState._animationController.isDismissed) {
                  widgetState._animationController.forward();
                } else {
                  widgetState._animationController.reverse();
                }
              },
            )));
  }

  void _showEditCategoriesDialog(MainState state, BuildContext upperContext) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text("Edit your climb categories"), children: <Widget>[
            StringCollectionInputScreen(
                items: state.categories,
                itemName: "Category",
                upperContext: upperContext,
                submitInput: _submitInput),
          ]);
        });
  }

  void _createLocation(MainState state, BuildContext context) {
    var uuid = new Uuid();
    Location location =
        new Location("location-${uuid.v1()}", "", "", "", null, state.categories, <String>[], null);
    NavigationHelper.navigateToCreateLocation(widgetState.context, location, false,
        addToBackStack: true);
  }

  void _submitInput(List<String> itemList, BuildContext context) {
    BlocProvider.of<MainBloc>(context).editCategories(itemList);
  }

  void navigateToLogin() {
    NavigationHelper.navigateToLogin(widgetState.context);
  }

  void navigateToLocation(SelectedLocation location, List<String> categories) {
    NavigationHelper.navigateToLocation(widgetState.context, location, categories,
        addToBackStack: true);
  }
}
