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
      this.enableFilters = const <FilterType>[
        FilterType.gradeSet,
        FilterType.grade,
        FilterType.timeframe,
        FilterType.location,
        FilterType.sendType,
        FilterType.category
      ],
      this.gradeSetFilterStream,
      this.grades})
      : super(key: key);
  final List<Attempt> attempts;
  final List<String> categories;
  final Map<String, String> locationNamesToIds;
  final StreamController<List<Attempt>> filteredAttemptsStream;
  final StreamController<String> gradeSetFilterStream;
  final Map<String, List<String>> grades;
  final List<FilterType> enableFilters;

  @override
  _AttemptFilterState createState() => _AttemptFilterState();
}

class _AttemptFilterState extends State<AttemptFilter> {
  Map<FilterType, String> filters;

  Map<FilterType, Function(BuildContext)> filterDropdowns;

  @override
  void initState() {
    filterDropdowns = <FilterType, Function(BuildContext)>{
      FilterType.gradeSet: _showGradeSetDropdown,
      FilterType.grade: _showGradeDropdown,
      FilterType.timeframe: _showTimeFrameDropdown,
      FilterType.location: _showLocationDropdown,
      FilterType.sendType: _showSendTypeDropdown,
      FilterType.category: _showCategoryDropdown,
    };

    filters = <FilterType, String>{};
    for (FilterType filterType in filterDropdowns.keys) {
      if (widget.enableFilters.contains(filterType)) {
        filters.putIfAbsent(filterType, () => null);
      }
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    List<Widget> columnChildren = <Widget>[];
    List<Widget> rowChildren = <Widget>[];
    bool firstInRow = true;

    for (FilterType filterType in filters.keys) {
      rowChildren.add(filterDropdowns[filterType](context));
      if (firstInRow) {
        firstInRow = false;
      } else {
        columnChildren.add(Row(children: rowChildren));
        rowChildren = <Widget>[];
        firstInRow = true;
      }
    }
    if (rowChildren.isNotEmpty) {
      columnChildren.add(Row(children: rowChildren));
    }

    return Container(
        child: Row(children: <Widget>[
      Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: columnChildren)),
      _showClearDropdownsButton(context),
    ]));
  }

  Widget _showGradeSetDropdown(BuildContext context) {
    return _createDropdown(context, widget.grades.keys.toList(), "Grade set", FilterType.gradeSet);
  }

  Widget _showGradeDropdown(BuildContext context) {
    return _createDropdown(
        context, widget.grades[filters[FilterType.gradeSet]], "Grade", FilterType.grade);
  }

  Widget _showTimeFrameDropdown(BuildContext context) {
    return _createDropdown(
        context, TimeFrames.TIME_FRAMES.values.toList(), "Timeframe", FilterType.timeframe);
  }

  Widget _showLocationDropdown(BuildContext context) {
    return _createDropdown(
        context, widget.locationNamesToIds.keys.toList(), "Location", FilterType.location);
  }

  Widget _showSendTypeDropdown(BuildContext context) {
    return _createDropdown(context, SendTypes.SEND_TYPES, "Send type", FilterType.sendType);
  }

  Widget _showCategoryDropdown(BuildContext context) {
    return _createDropdown(context, widget.categories, "Category", FilterType.category);
  }

  Widget _createDropdown(
      BuildContext context, List<String> dropdownItems, String hintString, FilterType filterValue) {
    if (dropdownItems?.length == 1 ?? false) {
      filters.update(filterValue, (value) => dropdownItems.first);
      if (filterValue == FilterType.gradeSet) {
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
                          if (filterValue == FilterType.gradeSet) {
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

    if (filters[FilterType.gradeSet] != null) {
      if (filters[FilterType.grade] != null) {
        filteredAttempts = filteredAttempts
            .where((attempt) => attempt.climbGrade == filters[FilterType.grade])
            .toList();
      } else {
        filteredAttempts = filteredAttempts
            .where((attempt) => attempt.climbGradeSet == filters[FilterType.gradeSet])
            .toList();
      }
    }

    if (filters[FilterType.timeframe] != null) {
      if (filters[FilterType.timeframe] == TimeFrames.TIME_FRAMES["pastDay"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 1))
            .toList();
      } else if (filters[FilterType.timeframe] == TimeFrames.TIME_FRAMES["pastWeek"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 7))
            .toList();
      } else if (filters[FilterType.timeframe] == TimeFrames.TIME_FRAMES["pastMonth"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 30))
            .toList();
      } else if (filters[FilterType.timeframe] == TimeFrames.TIME_FRAMES["pastYear"]) {
        filteredAttempts = filteredAttempts
            .where((attempt) =>
                DateTime.now().difference(attempt.timestamp.toDate()) < Duration(days: 365))
            .toList();
      }
    }

    if (filters[FilterType.location] != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) =>
              attempt.locationId == widget.locationNamesToIds[filters[FilterType.location]])
          .toList();
    }

    if (filters[FilterType.sendType] != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) => attempt.sendType == filters[FilterType.sendType])
          .toList();
    }

    if (filters[FilterType.category] != null) {
      filteredAttempts = filteredAttempts
          .where((attempt) => attempt.climbCategories.contains(filters[FilterType.category]))
          .toList();
    }

    return filteredAttempts;
  }
}
