import 'package:cached_network_image/cached_network_image.dart';
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
  State<StatefulWidget> createState() => _LocationState();
}

class _LocationState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>(
      create: (context) => LocationBloc(widget.location, widget.categories),
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
            onPressed: () => _editLocation(widget.location),
          )
        ],
      ),
      body: _buildBody(context),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder(
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
            content = Column(children: <Widget>[
              _showImage(),
              Expanded(
                  child: Center(
                child: Text(
                  "This location doesn't have any climbs.\nLet's create one right now!",
                  style: Theme.of(context).accentTextTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
              ))
            ]);
          } else {
            content = Column(children: <Widget>[
              _showFilterDropdownRow(state, context),
              Expanded(
                child: _buildFilteredList(state, context),
              )
            ]);
          }
          return _wrapContentWithFab(state, context, content);
        });
  }

  Widget _showFilterDropdownRow(LocationState state, BuildContext context) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        Expanded(
          child: _showGradeDropdown(state, context),
        ),
        Expanded(
          child: _showSectionDropdown(state, context),
        )
      ]),
      Divider(
        color: Theme.of(context).accentColor,
        thickness: 1.0,
        height: 0.0,
      )
    ]);
  }

  Widget _showGradeDropdown(LocationState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
        child: Row(children: <Widget>[
          Expanded(
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
            style: Theme.of(context).accentTextTheme.subtitle2,
            items: _createDropdownItems(state.grades),
            value: state.filterGrade,
            hint: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: UIConstants.STANDARD_PADDING),
                  child: Icon(Icons.filter_list, color: Colors.grey)),
              Text("Grade"),
            ]),
            isExpanded: true,
            onChanged: (value) => BlocProvider.of<LocationBloc>(context).setGradeFilter(value),
          ))),
          IconButton(
              icon: Icon(Icons.cancel,
                  color: (state.filterGrade == null) ? Colors.grey : Theme.of(context).accentColor),
              onPressed: () => BlocProvider.of<LocationBloc>(context).setGradeFilter(null))
        ]));
  }

  Widget _showSectionDropdown(LocationState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
        child: Row(children: <Widget>[
          Expanded(
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
            style: Theme.of(context).accentTextTheme.subtitle2,
            disabledHint: Text("No sections"),
            iconDisabledColor: Theme.of(context).cardColor,
            items: _createDropdownItems(state.sections),
            value: state.filterSection,
            hint: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: UIConstants.STANDARD_PADDING),
                  child: Icon(Icons.filter_list, color: Colors.grey)),
              Text("Section"),
            ]),
            isExpanded: true,
            onChanged: (value) => BlocProvider.of<LocationBloc>(context).setSectionFilter(value),
          ))),
          IconButton(
              icon: Icon(Icons.cancel,
                  color:
                      (state.filterSection == null) ? Colors.grey : Theme.of(context).accentColor),
              onPressed: () => BlocProvider.of<LocationBloc>(context).setSectionFilter(null))
        ]));
  }

  List<DropdownMenuItem> _createDropdownItems(List<String> items) {
    if (items.isNotEmpty) {
      return items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    } else {
      // null disables the dropdown
      return null;
    }
  }

  Widget _buildFilteredList(LocationState state, BuildContext context) {
    if (List.from(state.climbs.where((climb) =>
        (state.filterSection == null || climb.section == state.filterSection) &&
        (state.filterGrade == null || climb.grade == state.filterGrade))).isEmpty) {
      return _showEmptyFilteredList(state, context);
    }
    if (state.sections.isNotEmpty) {
      return _buildContentWithSections(state, context, state.filterSection, state.filterGrade);
    } else {
      return _buildContentWithoutSections(state, context, state.filterGrade);
    }
  }

  Widget _showEmptyFilteredList(LocationState state, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      child: Column(children: <Widget>[
        _showImage(),
        Expanded(
            child: Center(
          child: Text(
            "There are no climbs matching these filter parameters.",
            textAlign: TextAlign.center,
            style: Theme.of(context).accentTextTheme.subtitle2,
          ),
        ))
      ]),
    );
  }

  Widget _buildContentWithSections(
      LocationState state, BuildContext context, String filterSection, String filterGrade) {
    int itemCount = 0;
    int indexOffset = 0;
    if (widget.location.imagePath != "") {
      itemCount++;
      indexOffset = 1;
    }
    if (state.filterSection != null) {
      itemCount++;
    } else {
      itemCount += state.sections.length;
    }
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        if (index == 0 && widget.location.imagePath != "") {
          return _showImage();
        } else {
          if (filterSection != null) {
            return _buildSection(context, state, filterGrade, filterSection);
          } else {
            return _buildSection(context, state, filterGrade, state.sections[index - indexOffset]);
          }
        }
      },
      itemCount: itemCount,
    );
  }

  Widget _buildSection(
      BuildContext context, LocationState state, String filterGrade, String section) {
    List<Climb> climbsToInclude = List.from(state.climbs.where(
        (climb) => climb.section == section && (filterGrade == null || climb.grade == filterGrade)))
      ..sort((a, b) => state.grades.indexOf(a.grade).compareTo(state.grades.indexOf(b.grade)));
    if (climbsToInclude.isNotEmpty) {
      return Card(
          child: Column(children: <Widget>[
        Row(children: <Widget>[
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
                color: Theme.of(context).accentColor,
              ),
              padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
              child: Text(section,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).primaryTextTheme.subtitle2),
            ),
          )),
        ]),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: climbsToInclude.map((climb) => _buildClimbItem(climb, state)).toList())
      ]));
    } else {
      return Column();
    }
  }

  Widget _buildContentWithoutSections(
      LocationState state, BuildContext context, String filterGrade) {
    List<Climb> climbsToInclude = List.from(
        state.climbs.where((climb) => (filterGrade == null || climb.grade == filterGrade)))
      ..sort((a, b) => state.grades.indexOf(a.grade).compareTo(state.grades.indexOf(b.grade)));
    ;
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        if (index == 0 && widget.location.imagePath != "") {
          return _showImage();
        } else {
          return _buildClimbs(context, state, climbsToInclude);
        }
      },
      itemCount: widget.location.imagePath != "" ? 2 : 1,
    );
  }

  Widget _buildClimbs(BuildContext context, LocationState state, List<Climb> climbs) {
    List<Widget> climbItems = climbs.map((climb) => _buildClimbItem(climb, state)).toList();
    return Container(
        color: Theme.of(context).cardColor,
        child: Column(
          children: climbItems,
        ));
  }

  Widget _buildClimbItem(Climb climb, LocationState state) {
    return Row(children: <Widget>[
      Expanded(
          child: InkWell(
              child: ClimbItem(
                climb: climb,
              ),
              onTap: () {
                navigateToClimb(climb, state);
              }))
    ]);
  }

  Widget _showImage() {
    if (widget.location.imagePath != "") {
      return Container(
        height: 200,
        padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
        child: CachedNetworkImage(
          imageUrl: widget.location.imagePath,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            )),
          ),
          placeholder: (context, url) => SizedBox(
              width: 60,
              height: 60,
              child: Center(
                  child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ))),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    } else {
      return Container();
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
              child: Icon(Icons.add, color: Colors.black),
              backgroundColor: Theme.of(context).accentColor),
        )
      ],
    );
  }

  void _createClimb(LocationState state) {
    var uuid = Uuid();
    // the null values for grade and section here are required as they are used as the initial
    // values for the dropdowns
    Climb climb = Climb("climb-${uuid.v1()}", "", "", "", widget.location.id, null,
        widget.location.gradeSet, null, false, <String>[]);
    NavigationHelper.navigateToCreateClimb(
        widgetState.context,
        climb,
        SelectedLocation(widget.location.id, widget.location.displayName, widget.location.imagePath,
            widget.location.imageUri, widget.location.gradeSet),
        state.sections,
        state.grades,
        widget.categories,
        false,
        addToBackStack: true);
  }

  void _editLocation(SelectedLocation selectedLocation) {
    Location location = Location(
        selectedLocation.id,
        selectedLocation.displayName,
        selectedLocation.imagePath,
        selectedLocation.imageUri,
        selectedLocation.gradeSet, <String>[], <String>[]);
    NavigationHelper.navigateToCreateLocation(widgetState.context, location, true,
        addToBackStack: true);
  }

  void navigateToClimb(Climb climb, LocationState state) {
    NavigationHelper.navigateToClimb(
        widgetState.context,
        climb,
        SelectedLocation(widget.location.id, widget.location.displayName, widget.location.imagePath,
            widget.location.imageUri, widget.location.gradeSet),
        state.sections,
        state.grades,
        widget.categories,
        addToBackStack: true);
  }
}
