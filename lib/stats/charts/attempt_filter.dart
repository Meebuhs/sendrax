import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

class AttemptFilter extends StatefulWidget {
  AttemptFilter(
      {Key key,
      @required this.attempts,
      @required this.locationNamesToIds,
      @required this.filteredAttemptsStream,
      this.filterGrades = false,
      this.grades})
      : super(key: key);
  final List<Attempt> attempts;
  final Map<String, String> locationNamesToIds;
  final StreamController<List<Attempt>> filteredAttemptsStream;
  final bool filterGrades;
  final Map<String, List<String>> grades;

  @override
  _AttemptFilterState createState() => _AttemptFilterState();
}

class _AttemptFilterState extends State<AttemptFilter> {
  String filterGradeset;
  String filterGrade;
  String filterTimeframe;
  String filterLocation;
  String filterSendType;
  String filterCategory;

  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    children = [
      Row(
        children: <Widget>[
          _showTimeFrameDropdown(context),
          _showLocationDropdown(context),
        ],
      ),
      Row(
        children: <Widget>[
          _showSendTypeDropdown(context),
          _showCategoryDropdown(context),
        ],
      )
    ];

    if (widget.filterGrades) {
      children.insert(
        0,
        Row(
          children: <Widget>[
            _showGradeSetDropdown(context),
            _showGradeDropdown(context),
          ],
        ),
      );
    }

    return Container(
        child: Row(children: <Widget>[
      Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: children)),
      _showClearDropdownsButton(context),
    ]));
  }

  Widget _showGradeSetDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                0.0, 0.0, UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2),
            child: Container(
                padding: EdgeInsets.all(UIConstants.SMALL_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        style: Theme.of(context).accentTextTheme.subtitle2,
                        items: _createDropdownItems(widget.grades.keys.toList()),
                        value: filterGradeset,
                        hint: Text("Grade set"),
                        isExpanded: true,
                        isDense: true,
                        onChanged: (value) {
                          setState(() {
                            filterGradeset = value;
                          });
                          widget.filteredAttemptsStream.add(_filterAttempts());
                        })))));
  }

  Widget _showGradeDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                0.0, UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2, 0.0),
            child: Container(
                padding: EdgeInsets.all(UIConstants.SMALL_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        style: Theme.of(context).accentTextTheme.subtitle2,
                        items: _createDropdownItems(widget.grades[filterGradeset]),
                        value: filterGrade,
                        hint: Text("Grade"),
                        isExpanded: true,
                        isDense: true,
                        disabledHint: Text(
                          "Grade",
                          style: TextStyle(color: Theme.of(context).dialogBackgroundColor),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filterGrade = value;
                          });
                          widget.filteredAttemptsStream.add(_filterAttempts());
                        })))));
  }

  Widget _showTimeFrameDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(UIConstants.SMALLER_PADDING / 2, 0.0,
                UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2),
            child: Container(
                padding: EdgeInsets.all(UIConstants.SMALL_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        style: Theme.of(context).accentTextTheme.subtitle2,
                        items: _createDropdownItems(TimeFrames.TIME_FRAMES.values.toList()),
                        value: filterTimeframe,
                        hint: Text("Time"),
                        isExpanded: true,
                        isDense: true,
                        onChanged: (value) {
                          setState(() {
                            filterTimeframe = value;
                          });
                          widget.filteredAttemptsStream.add(_filterAttempts());
                        })))));
  }

  Widget _showLocationDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(UIConstants.SMALLER_PADDING / 2,
                0.0, 0.0, UIConstants.SMALLER_PADDING / 2),
            child: Container(
                padding: EdgeInsets.all(UIConstants.SMALL_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        style: Theme.of(context).accentTextTheme.subtitle2,
                        items: _createDropdownItems(widget.locationNamesToIds.keys.toList()),
                        value: filterLocation,
                        hint: Text("Location"),
                        isExpanded: true,
                        isDense: true,
                        onChanged: (value) {
                          setState(() {
                            filterLocation = value;
                          });
                          widget.filteredAttemptsStream.add(_filterAttempts());
                        })))));
  }

  Widget _showSendTypeDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2, 0.0),
            child: Container(
                padding: EdgeInsets.all(UIConstants.SMALL_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        style: Theme.of(context).accentTextTheme.subtitle2,
                        items: _createDropdownItems(SendTypes.SEND_TYPES),
                        value: filterSendType,
                        hint: Text("Send type"),
                        isExpanded: true,
                        isDense: true,
                        onChanged: (value) {
                          setState(() {
                            filterSendType = value;
                          });
                          widget.filteredAttemptsStream.add(_filterAttempts());
                        })))));
  }

  Widget _showCategoryDropdown(BuildContext context) {
    return Expanded(
        child: Padding(
        padding: EdgeInsets.fromLTRB(UIConstants.SMALLER_PADDING / 2, UIConstants.SMALLER_PADDING / 2, 0.0, 0.0),
    child: Container(
            padding: EdgeInsets.all(UIConstants.SMALL_PADDING),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                    style: Theme.of(context).accentTextTheme.subtitle2,
                    items: _createDropdownItems(ClimbCategories.CATEGORIES),
                    value: filterCategory,
                    hint: Text("Category"),
                    isExpanded: true,
                    isDense: true,
                    onChanged: (value) {
                      setState(() {
                        filterCategory = value;
                      });
                      widget.filteredAttemptsStream.add(_filterAttempts());
                    })))));
  }

  Widget _showClearDropdownsButton(BuildContext context) {
    return Container(
        child: IconButton(
            icon: Icon(Icons.cancel,
                color: (filterGradeset == null &&
                        filterGrade == null &&
                        filterTimeframe == null &&
                        filterLocation == null &&
                        filterSendType == null &&
                        filterCategory == null)
                    ? Colors.grey
                    : Theme.of(context).accentColor),
            onPressed: () {
              setState(() {
                filterGradeset = null;
                filterGrade = null;
                filterTimeframe = null;
                filterLocation = null;
                filterSendType = null;
                filterCategory = null;
              });
              widget.filteredAttemptsStream.add(_filterAttempts());
            }));
  }

  List<DropdownMenuItem> _createDropdownItems(List<String> items) {
    if (items?.isNotEmpty ?? false) {
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

  List<Attempt> _filterAttempts() {
    List<Attempt> filteredAttempts = widget.attempts;

    if (filterGradeset != null) {
      if (filterGrade != null) {
        filteredAttempts =
            filteredAttempts.where((attempt) => attempt.climbGrade == filterGrade).toList();
      } else {
        filteredAttempts = filteredAttempts
            .where((attempt) => widget.grades[filterGradeset].contains(attempt.climbGrade))
            .toList();
      }
    }

    if (filterTimeframe != null) {
      if (filterTimeframe == TimeFrames.TIME_FRAMES["lastWeek"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 7))
            .toList();
      } else if (filterTimeframe == TimeFrames.TIME_FRAMES["lastMonth"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 30))
            .toList();
      } else if (filterTimeframe == TimeFrames.TIME_FRAMES["lastYear"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 365))
            .toList();
      }
    }
    if (filterLocation != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) => attempt.locationId == widget.locationNamesToIds[filterLocation])
          .toList();
    }
    if (filterSendType != null) {
      filteredAttempts =
          filteredAttempts.where((attempt) => attempt.sendType == filterSendType).toList();
    }
    if (filterCategory != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) => attempt.climbCategories.contains(filterCategory))
          .toList();
    }

    return filteredAttempts;
  }
}
