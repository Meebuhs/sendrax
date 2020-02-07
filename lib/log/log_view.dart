import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/string_collection_input/string_collection_input_view.dart';
import 'package:sendrax/util/constants.dart';
import 'package:uuid/uuid.dart';

import 'log_bloc.dart';
import 'log_location_item.dart';
import 'log_state.dart';
import 'mini_fab_label_clipper.dart';

class LogScreen extends StatefulWidget {
  LogScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LogState();
}

class _LogState extends State<LogScreen> with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogBloc>(
        create: (context) => LogBloc(), child: LogWidget(widget: widget, widgetState: this));
  }
}

class LogWidget extends StatelessWidget {
  const LogWidget({Key key, @required this.widget, @required this.widgetState}) : super(key: key);

  final LogScreen widget;
  final _LogState widgetState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<LogBloc>(context),
        builder: (context, LogState state) {
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
                style: Theme.of(context).accentTextTheme.subtitle2,
              ),
            );
          } else {
            content = GridView.builder(
              padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return _buildItem(state.locations[index], state.categories, _onLocationTap);
              },
              itemCount: state.locations.length,
            );
          }
          return _wrapContentWithFab(context, state, content);
        });
  }

  LocationItem _buildItem(
      Location location, List<String> categories, Function(Location, List<String>) onTapped) {
    return LocationItem(location: location, categories: categories, onTapped: _onLocationTap);
  }

  void _onLocationTap(Location location, List<String> categories) {
    SelectedLocation selectedLocation = SelectedLocation(location.id, location.displayName,
        location.imagePath, location.imageUri, location.gradeSet);
    navigateToLocation(selectedLocation, categories);
  }

  Widget _wrapContentWithFab(BuildContext context, LogState state, Widget content) {
    return Stack(
      children: <Widget>[
        content,
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _buildMiniFab("Edit categories", Icon(Icons.mode_edit, color: Colors.black),
                    _showEditCategoriesDialog, state, context),
                _buildMiniFab("Add location", Icon(Icons.add, color: Colors.black), _createLocation,
                    state, context),
                _showMainFab(),
              ]),
        )
      ],
    );
  }

  Widget _buildMiniFab(String labelText, Icon icon, Function(LogState, BuildContext) onPressed,
      LogState state, BuildContext context) {
    double totalWidth = 160;
    double fabContainerSize = 56;
    double xProportionToFabCenter = 1 - (fabContainerSize / 2 / totalWidth);
    return Container(
        height: 56.0,
        width: totalWidth,
        alignment: FractionalOffset.center,
        child: ScaleTransition(
          alignment: FractionalOffset(xProportionToFabCenter, 0.5),
          scale: CurvedAnimation(
            parent: widgetState._animationController,
            curve: Interval(0.0, 1.0, curve: Curves.easeOutQuad),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _showMiniFabButton(fabContainerSize, icon, onPressed, context, state),
              _showMiniFabLabel(fabContainerSize, labelText, context)
            ],
          ),
        ));
  }

  Widget _showMiniFabButton(double fabContainerSize, Icon icon,
      Function(LogState, BuildContext) onPressed, BuildContext context, LogState state) {
    return Positioned(
        right: 0.0,
        child: Container(
            height: fabContainerSize,
            width: fabContainerSize,
            alignment: FractionalOffset.center,
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).accentColor,
              mini: true,
              child: icon,
              onPressed: () => onPressed(state, context),
            )));
  }

  Widget _showMiniFabLabel(double fabContainerSize, String labelText, BuildContext context) {
    return Positioned(
      right: fabContainerSize - 8,
      child: ClipPath(
          clipper: MiniFabLabelClipper(),
          child: Container(
              padding: EdgeInsets.fromLTRB(
                  UIConstants.SMALLER_PADDING / 2,
                  UIConstants.SMALLER_PADDING / 2,
                  UIConstants.SMALLER_PADDING,
                  UIConstants.SMALLER_PADDING / 2),
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
              child: Text(
                labelText,
                style: Theme.of(context).primaryTextTheme.subtitle2,
              ))),
    );
  }

  Widget _showMainFab() {
    return Container(
        alignment: FractionalOffset.bottomRight,
        child: Padding(
            padding: EdgeInsets.only(top: UIConstants.STANDARD_PADDING),
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

  void _showEditCategoriesDialog(LogState state, BuildContext upperContext) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text("Edit your climb categories",
                  style: Theme.of(context).accentTextTheme.headline5),
              backgroundColor: Theme.of(context).cardColor,
              children: <Widget>[
                StringCollectionInputScreen(
                    items: state.categories,
                    itemName: "Category",
                    upperContext: upperContext,
                    submitInput: _submitInput),
              ]);
        });
  }

  void _createLocation(LogState state, BuildContext context) {
    var uuid = Uuid();
    Location location =
        Location("location-${uuid.v1()}", "", "", "", null, state.categories, <String>[], null);
    NavigationHelper.navigateToCreateLocation(widgetState.context, location, false,
        addToBackStack: true);
  }

  void _submitInput(List<String> itemList, BuildContext context) {
    BlocProvider.of<LogBloc>(context).editCategories(itemList);
  }

  void navigateToLocation(SelectedLocation location, List<String> categories) {
    NavigationHelper.navigateToLocation(widgetState.context, location, categories,
        addToBackStack: true);
  }
}
