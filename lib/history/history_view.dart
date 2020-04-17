import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sendrax/history/history_attempt_item.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/models/location.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'history_bloc.dart';
import 'history_state.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen(
      {Key key,
      @required this.attempts,
      @required this.locations,
      @required this.categories,
      @required this.locationNamesToIds,
      @required this.grades})
      : super(key: key);

  final List<Attempt> attempts;
  final List<Location> locations;
  final List<String> categories;
  final Map<String, String> locationNamesToIds;
  final Map<String, List<String>> grades;

  @override
  State<StatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryBloc>(
      create: (context) => HistoryBloc(),
      child: HistoryWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final HistoryScreen widget;
  final _HistoryState widgetState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<HistoryBloc>(context),
        builder: (context, HistoryState state) {
          if (widget.attempts.isEmpty) {
            return Column(children: <Widget>[
              Container(
                color: Theme
                    .of(context)
                    .cardColor,
                child: _showFilterDropdownRow(state, context),
              ),
              Expanded(
                  child: Center(
                child: Text(
                  "You have not yet logged any attempts.",
                  style: Theme.of(context).accentTextTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
              ))
            ]);
          } else {
            return Column(children: <Widget>[
              Container(
                color: Theme.of(context).cardColor,
                child: _showFilterDropdownRow(state, context),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
                  child: _buildGroupedList(state, context),
                ),
              ),
            ]);
          }
        });
  }

  Widget _showFilterDropdownRow(HistoryState state, BuildContext context) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        Expanded(
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                child: _showDropdown(widget.grades.keys.toList(), state.filterGradeSet, "Grade Set",
                    BlocProvider
                        .of<HistoryBloc>(context)
                        .setGradeSetFilter, state, context),
              ),
              Expanded(
                child: _showDropdown(widget.grades[state.filterGradeSet], state.filterGrade,
                    "Grade", BlocProvider
                        .of<HistoryBloc>(context)
                        .setGradeFilter, state, context),
              ),
            ]),
            Row(children: <Widget>[
              Expanded(
                child: _showDropdown(
                    widget.locationNamesToIds.keys.toList(),
                    state.filterLocation,
                    "Location",
                    BlocProvider
                        .of<HistoryBloc>(context)
                        .setLocationFilter,
                    state,
                    context),
              ),
              Expanded(
                child: _showDropdown(widget.categories, state.filterCategory, "Category",
                    BlocProvider
                        .of<HistoryBloc>(context)
                        .setCategoryFilter, state, context),
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
      Function(String) onChanged, HistoryState state, BuildContext context) {
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

  Widget _showClearDropdownsButton(HistoryState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        child: IconButton(
            icon: Icon(Icons.cancel,
                color: (state.filterGradeSet == null &&
                        state.filterGrade == null &&
                        state.filterLocation == null &&
                        state.filterCategory == null)
                    ? Colors.grey
                    : Theme.of(context).accentColor),
            onPressed: () => BlocProvider.of<HistoryBloc>(context).clearFilters()));
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

  Widget _buildGroupedList(HistoryState state, BuildContext context) {
    List<Attempt> filteredAttempts = _filterAttempts(state);
    List<DateTime> datesToBuild = _generateDates(filteredAttempts);

    return (filteredAttempts.isEmpty)
        ? Center(
            child: Text(
            "There are no existing attempts matching the above criteria.",
            style: Theme.of(context).accentTextTheme.subtitle2,
          ))
        : ListView.builder(
            itemBuilder: (context, index) {
              return _buildDateCard(context, filteredAttempts, datesToBuild, index);
            },
            itemCount: datesToBuild.length,
          );
  }

  List<Attempt> _filterAttempts(HistoryState state) {
    List<Attempt> filteredAttempts = List.from(widget.attempts);
    if (state.filterGradeSet != null) {
      filteredAttempts.retainWhere((attempt) => attempt.climbGradeSet == state.filterGradeSet);
    }

    if (state.filterGrade != null) {
      filteredAttempts.retainWhere((attempt) => attempt.climbGrade == state.filterGrade);
    }

    if (state.filterLocation != null) {
      filteredAttempts.retainWhere(
          (attempt) => attempt.locationId == widget.locationNamesToIds[state.filterLocation]);
    }

    if (state.filterCategory != null) {
      filteredAttempts
          .retainWhere((attempt) => attempt.climbCategories.contains(state.filterCategory));
    }

    return filteredAttempts;
  }

  List<DateTime> _generateDates(List<Attempt> attempts) {
    List<DateTime> dates = <DateTime>[];
    for (Attempt attempt in attempts) {
      DateTime attemptDate = attempt.timestamp.toDate();
      DateTime startOfDay = DateTime(attemptDate.year, attemptDate.month, attemptDate.day);
      if (!dates.contains(startOfDay)) {
        dates.add(startOfDay);
      }
    }
    return dates;
  }

  Widget _buildDateCard(
      BuildContext context, List<Attempt> attempts, List<DateTime> dates, int index) {
    List<Attempt> attemptsOnDate = List.from(attempts.where((attempt) =>
        (attempt.timestamp.toDate().difference(dates[index]) > Duration() &&
            attempt.timestamp.toDate().difference(dates[index]) < Duration(days: 1))));
    if (attemptsOnDate.isNotEmpty) {
      List<String> climbsToInclude = <String>[];
      attemptsOnDate.forEach((attempt) {
        if (!climbsToInclude.contains(attempt.climbId)) {
          climbsToInclude.add(attempt.climbId);
        }
      });

      List<Widget> climbItems = <Widget>[];
      climbItems.add(
        Padding(
          padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              DateFormat('EEEE d/M').format(dates[index]),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).accentTextTheme.subtitle2,
              textAlign: TextAlign.start,
            ),
          ),
        ),
      );
      for (String climb in climbsToInclude) {
        climbItems.insert(
            1,
            _buildClimb(
                context,
                climb,
                attemptsOnDate
                    .where((attempt) => attempt.climbId == climb)
                    .toList()
                    .reversed
                    .toList()));
      }
      return Column(
        children: climbItems,
      );
    } else {
      return Column();
    }
  }

  Widget _buildClimb(BuildContext context, String climbId, List<Attempt> climbAttempts) {
    return Card(
        child: Column(children: <Widget>[
      Row(children: <Widget>[
        Expanded(
            child: Padding(
                padding: EdgeInsets.all(1.0),
                child: InkWell(
                  onTap: () {
                    navigateToClimb(context, climbId, climbAttempts.first.climbName);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(UIConstants.CARD_BORDER_RADIUS)),
                      color: Theme.of(context).accentColor,
                    ),
                    padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                    child: Text(_buildClimbText(climbAttempts.first),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).primaryTextTheme.subtitle2),
                  ),
                ))),
      ]),
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: climbAttempts.map((attempt) => _buildAttempt(attempt)).toList())
    ]));
  }

  String _buildClimbText(Attempt attempt) {
    String label;

    if (attempt.climbName == "") {
      if (attempt.climbCategories.isEmpty) {
        label = "${attempt.climbGrade}";
      } else {
        label = "${attempt.climbGrade} - ${(attempt.climbCategories..sort()).join(', ')}";
      }
    } else {
      if (attempt.climbCategories.isEmpty) {
        label = "${attempt.climbGrade} - ${attempt.climbName}";
      } else {
        label =
            "${attempt.climbGrade} - ${attempt.climbName} - ${(attempt.climbCategories..sort()).join(', ')}";
      }
    }

    return label;
  }

  Widget _buildAttempt(Attempt attempt) {
    return AttemptItem(attempt: attempt);
  }

  void navigateToClimb(BuildContext context, String climbId, String climbName) {
    NavigationHelper.navigateToViewOnlyClimb(context, climbId, climbName, addToBackStack: true);
  }
}
