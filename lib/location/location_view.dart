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
  LocationScreen({Key key, @required this.location, @required this.categories})
      : super(key: key);

  final Location location;
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
  const LocationWidget(
      {Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final LocationScreen widget;
  final _LocationState widgetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Material(
            color: Colors.transparent,
            child: Hero(
                tag: "${widget.location.displayName}-text",
                child: Text(
                  widget.location.displayName,
                  style: Theme.of(context).primaryTextTheme.headline6,
                ))),
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
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ),
            );
          } else if (state.climbs.isEmpty) {
            content = Column(children: <Widget>[
              Container(
                color: Theme.of(context).cardColor,
                child: _showFilterDropdownRow(state, context),
              ),
              Padding(
                  padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                  child: _showImage()),
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
              Container(
                color: Theme.of(context).cardColor,
                child: _showFilterDropdownRow(state, context),
              ),
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
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                child: _showDropdown(
                    widget.location.sections,
                    state.filterSection,
                    "Section",
                    BlocProvider.of<LocationBloc>(context).setSectionFilter,
                    state,
                    context),
              ),
              Expanded(
                child: _showDropdown(
                    widget.location.grades,
                    state.filterGrade,
                    "Grade",
                    BlocProvider.of<LocationBloc>(context).setGradeFilter,
                    state,
                    context),
              ),
            ]),
            Row(children: <Widget>[
              Expanded(
                child: _showDropdown(
                    SendTypes.CATEGORIES,
                    state.filterStatus,
                    "Status",
                    BlocProvider.of<LocationBloc>(context).setStatusFilter,
                    state,
                    context),
              ),
              Expanded(
                child: _showDropdown(
                    widget.categories,
                    state.filterCategory,
                    "Category",
                    BlocProvider.of<LocationBloc>(context).setCategoryFilter,
                    state,
                    context),
              ),
            ]),
          ]),
        ),
        _showClearDropdownsButton(state, context)
      ]),
      Divider(
        color: Theme.of(context).accentColor,
        thickness: 1.0,
        height: 0.0,
      )
    ]);
  }

  Widget _showDropdown(List<String> items, String value, String hintText,
      Function(String) onChanged, LocationState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          style: Theme.of(context).accentTextTheme.subtitle2,
          items: _createDropdownItems(items),
          value: value,
          hint: Text(hintText),
          isExpanded: true,
          onChanged: (value) => onChanged(value),
        )));
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

  Widget _showClearDropdownsButton(LocationState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        child: IconButton(
            icon: Icon(Icons.cancel,
                color: (state.filterSection == null &&
                        state.filterGrade == null &&
                        state.filterStatus == null &&
                        state.filterCategory == null)
                    ? Colors.grey
                    : Theme.of(context).accentColor),
            onPressed: () =>
                BlocProvider.of<LocationBloc>(context).clearFilters()));
  }

  Widget _buildFilteredList(LocationState state, BuildContext context) {
    List<Climb> filteredClimbs = List.from(state.climbs.where((climb) =>
        (state.filterSection == null || climb.section == state.filterSection) &&
        (state.filterGrade == null || climb.grade == state.filterGrade) &&
        (state.filterStatus == null ||
            ((state.filterStatus == "Repeated" && climb.repeated) ||
                (state.filterStatus == "Sent, Not Repeated" &&
                    !climb.repeated &&
                    climb.sent) ||
                (state.filterStatus == "Not Sent" &&
                    !(climb.sent || climb.repeated)))) &&
        (state.filterCategory == null ||
            climb.categories.contains(state.filterCategory))));
    filteredClimbs.sort((a, b) => widget.location.grades
        .indexOf(a.grade)
        .compareTo(widget.location.grades.indexOf(b.grade)));

    if (filteredClimbs.isEmpty) {
      return _showEmptyFilteredList(state, context);
    }
    if (widget.location.sections.isNotEmpty) {
      return _buildContentWithSections(state, context, filteredClimbs);
    } else {
      return _buildContentWithoutSections(state, context, filteredClimbs);
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
      LocationState state, BuildContext context, List<Climb> filteredClimbs) {
    int itemCount = 0;
    int indexOffset = 0;
    if (widget.location.imageURL != "") {
      itemCount++;
      indexOffset = 1;
    }
    if (state.filterSection != null) {
      itemCount++;
    } else {
      itemCount += widget.location.sections.length;
    }
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        if (index == 0 && widget.location.imageURL != "") {
          return _showImage();
        } else {
          if (state.filterSection != null) {
            return _buildSection(
                context, state, state.filterSection, filteredClimbs);
          } else {
            return _buildSection(context, state,
                widget.location.sections[index - indexOffset], filteredClimbs);
          }
        }
      },
      itemCount: itemCount,
    );
  }

  Widget _buildSection(BuildContext context, LocationState state,
      String section, List<Climb> filteredClimbs) {
    List<Widget> cardHeaderChildren = [
      Expanded(
        child: Text(section,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).primaryTextTheme.subtitle2),
      )
    ];
    if ([state.filterSection, state.filterGrade, state.filterCategory]
            ?.every((value) => value == null) ??
        null) {
      cardHeaderChildren.add(SizedBox(
          height: 24,
          width: 24,
          child: IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(
                Icons.archive,
                color: Colors.black,
              ),
              onPressed: () => _showArchiveSectionDialog(context, section))));
    }

    List<Climb> climbsToInclude =
        filteredClimbs.where((climb) => climb.section == section).toList();
    if (climbsToInclude.isNotEmpty) {
      return Card(
          margin: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                  UIConstants.CARD_BORDER_RADIUS)),
                          color: Theme.of(context).accentColor,
                        ),
                        padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                        child: Row(children: cardHeaderChildren),
                      ))),
            ]),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: climbsToInclude
                    .map((climb) => _buildClimbItem(climb, state))
                    .toList())
          ]));
    } else {
      return Column();
    }
  }

  Widget _buildContentWithoutSections(
      LocationState state, BuildContext context, List<Climb> filteredClimbs) {
    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
      itemBuilder: (context, index) {
        if (index == 0 && widget.location.imageURL != "") {
          return _showImage();
        } else {
          return _buildClimbs(context, state, filteredClimbs);
        }
      },
      itemCount: widget.location.imageURL != "" ? 2 : 1,
    );
  }

  Widget _buildClimbs(
      BuildContext context, LocationState state, List<Climb> climbs) {
    List<Widget> climbItems =
        climbs.map((climb) => _buildClimbItem(climb, state)).toList();
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(
                Radius.circular(UIConstants.CARD_BORDER_RADIUS))),
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
    if (widget.location.imageURL != "") {
      return Container(
        height: 200,
        padding: EdgeInsets.only(bottom: UIConstants.SMALLER_PADDING),
        child: CachedNetworkImage(
          imageUrl: widget.location.imageURL,
          imageBuilder: (context, imageProvider) => InkWell(
            child: Material(
              borderRadius: BorderRadius.all(
                  Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
              child: Hero(
                  tag: "${widget.location.displayName}-image",
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )))),
            ),
            onTap: () => navigateToImageView(imageProvider),
          ),
          placeholder: (context, url) => SizedBox(
              width: 60,
              height: 60,
              child: Center(
                  child: CircularProgressIndicator(
                strokeWidth: 4.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ))),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _wrapContentWithFab(
      LocationState state, BuildContext context, Widget content) {
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

  void _showArchiveSectionDialog(BuildContext upperContext, String section) {
    showDialog(
        context: upperContext,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                  "Are you sure you want to archive this section's climbs?",
                  style: Theme.of(context).accentTextTheme.headline5),
              content: Text(
                  "The climbs will still appear in your log but will no longer appear for this location",
                  style: Theme.of(context).accentTextTheme.bodyText2),
              actions: <Widget>[
                TextButton(
                  child: Text("CANCEL",
                      style: Theme.of(context).accentTextTheme.button),
                  onPressed: () =>
                      NavigationHelper.navigateBackOne(upperContext),
                ),
                TextButton(
                  child: Text("ARCHIVE",
                      style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => BlocProvider.of<LocationBloc>(upperContext)
                      .archiveSection(section, upperContext),
                )
              ]);
        });
  }

  void _createClimb(LocationState state) {
    var uuid = Uuid();
    // the null values for grade and section here are required as they are used as the initial
    // values for the dropdowns
    Climb climb = Climb("climb-${uuid.v1()}", "", "", "", widget.location.id,
        null, widget.location.gradeSet, null, false, false, false, <String>[]);
    NavigationHelper.navigateToCreateClimb(
        widgetState.context, climb, widget.location, widget.categories, false,
        addToBackStack: true);
  }

  void _editLocation(Location location) {
    NavigationHelper.navigateToCreateLocation(
        widgetState.context, location, widget.categories, true,
        addToBackStack: true);
  }

  void navigateToClimb(Climb climb, LocationState state) {
    NavigationHelper.navigateToClimb(
        widgetState.context, climb, widget.location, widget.categories,
        addToBackStack: true);
  }

  void navigateToImageView(ImageProvider image) {
    NavigationHelper.navigateToImageView(
        widgetState.context, image, "${widget.location.displayName}-image",
        addToBackStack: true);
  }
}
