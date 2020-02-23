import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

class AttemptFilter extends StatefulWidget {
  AttemptFilter(
      {Key key,
      @required this.attempts,
      @required this.categories,
      @required this.locationNamesToIds,
      @required this.filteredAttemptsStream,
      this.filterGrades = false,
      this.gradeSetFilterStream,
      this.grades})
      : super(key: key);
  final List<Attempt> attempts;
  final List<String> categories;
  final Map<String, String> locationNamesToIds;
  final StreamController<List<Attempt>> filteredAttemptsStream;
  final bool filterGrades;
  final StreamController<String> gradeSetFilterStream;
  final Map<String, List<String>> grades;

  @override
  _AttemptFilterState createState() => _AttemptFilterState();
}

class _AttemptFilterState extends State<AttemptFilter> {
  Map<FilterTypes, String> filters = <FilterTypes, String>{
    FilterTypes.gradeSet: null,
    FilterTypes.grade: null,
    FilterTypes.timeframe: null,
    FilterTypes.location: null,
    FilterTypes.sendType: null,
    FilterTypes.category: null,
  };

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
    return _createDropdown(context, widget.grades.keys.toList(), "Grade set", FilterTypes.gradeSet);
  }

  Widget _showGradeDropdown(BuildContext context) {
    return _createDropdown(
        context, widget.grades[filters[FilterTypes.gradeSet]], "Grade", FilterTypes.grade);
  }

  Widget _showTimeFrameDropdown(BuildContext context) {
    return _createDropdown(
        context, TimeFrames.TIME_FRAMES.values.toList(), "Timeframe", FilterTypes.timeframe);
  }

  Widget _showLocationDropdown(BuildContext context) {
    return _createDropdown(
        context, widget.locationNamesToIds.keys.toList(), "Location", FilterTypes.location);
  }

  Widget _showSendTypeDropdown(BuildContext context) {
    return _createDropdown(context, SendTypes.SEND_TYPES, "Send type", FilterTypes.sendType);
  }

  Widget _showCategoryDropdown(BuildContext context) {
    return _createDropdown(context, widget.categories, "Category", FilterTypes.category);
  }

  Widget _createDropdown(BuildContext context, List<String> dropdownItems, String hintString,
      FilterTypes filterValue) {
    if (dropdownItems?.length == 1 ?? false) {
      filters.update(filterValue, (value) => dropdownItems.first);
      if (filterValue == FilterTypes.gradeSet) {
        if (widget.gradeSetFilterStream != null) {
          widget.gradeSetFilterStream.add(dropdownItems.first);
        }
      }
    }

    return Expanded(
        child: Padding(
            padding:
                EdgeInsets.fromLTRB(0, 0, UIConstants.SMALLER_PADDING, UIConstants.SMALLER_PADDING),
            child: Container(
                padding: EdgeInsets.all(UIConstants.SMALL_PADDING),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(UIConstants.BUTTON_BORDER_RADIUS))),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        style: Theme.of(context).accentTextTheme.subtitle2,
                        items: _createDropdownItems(dropdownItems),
                        value: filters[filterValue],
                        hint: Text(hintString),
                        isExpanded: true,
                        isDense: true,
                        onChanged: (value) {
                          setState(() {
                            filters[filterValue] = value;
                          });
                          if (filterValue == FilterTypes.gradeSet) {
                            if (widget.gradeSetFilterStream != null) {
                              widget.gradeSetFilterStream.add(value);
                            }
                          }
                          widget.filteredAttemptsStream.add(_filterAttempts());
                        })))));
  }

  Widget _showClearDropdownsButton(BuildContext context) {
    return Container(
        child: IconButton(
            icon: Icon(Icons.cancel,
                color: (filters.values.every((value) => value == null))
                    ? Colors.grey
                    : Theme.of(context).accentColor),
            onPressed: () {
              setState(() {
                filters.keys.forEach((key) {
                  filters.update(key, (value) => null);
                });
              });
              if (widget.gradeSetFilterStream != null && widget.grades.keys.length > 1) {
                widget.gradeSetFilterStream.add(null);
              }
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

    if (filters[FilterTypes.gradeSet] != null) {
      if (filters[FilterTypes.grade] != null) {
        filteredAttempts = filteredAttempts
            .where((attempt) => attempt.climbGrade == filters[FilterTypes.grade])
            .toList();
      } else {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                widget.grades[filters[FilterTypes.gradeSet]].contains(attempt.climbGrade))
            .toList();
      }
    }

    if (filters[FilterTypes.timeframe] != null) {
      if (filters[FilterTypes.timeframe] == TimeFrames.TIME_FRAMES["lastWeek"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 7))
            .toList();
      } else if (filters[FilterTypes.timeframe] == TimeFrames.TIME_FRAMES["lastMonth"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 30))
            .toList();
      } else if (filters[FilterTypes.timeframe] == TimeFrames.TIME_FRAMES["lastYear"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 365))
            .toList();
      }
    }

    if (filters[FilterTypes.location] != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) =>
              attempt.locationId == widget.locationNamesToIds[filters[FilterTypes.location]])
          .toList();
    }

    if (filters[FilterTypes.sendType] != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) => attempt.sendType == filters[FilterTypes.sendType])
          .toList();
    }

    if (filters[FilterTypes.category] != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) => attempt.climbCategories.contains(filters[FilterTypes.category]))
          .toList();
    }

    return filteredAttempts;
  }
}

enum FilterTypes {
  gradeSet,
  grade,
  timeframe,
  location,
  sendType,
  category,
}
