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
  HistoryScreen({Key key, @required this.locations, @required this.categories}) : super(key: key);

  final List<Location> locations;
  final List<String> categories;

  @override
  State<StatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends State<HistoryScreen> {
  List<String> grades = <String>[];
  Map<String, String> locationNamesToIds = <String, String>{};

  @override
  void initState() {
    List<String> gradeSets = <String>[];
    for (Location location in widget.locations) {
      if (!gradeSets.contains(location.gradeSet)) {
        gradeSets.add(location.gradeSet);
        grades.addAll(location.grades);
      }
      locationNamesToIds.putIfAbsent(location.displayName, () => location.id);
    }
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
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            );
          } else if (state.attempts.isEmpty) {
            return Column(children: <Widget>[
              _showFilterDropdownRow(state, context),
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
              _showFilterDropdownRow(state, context),
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
          child: _showGradeDropdown(state, context),
        ),
        Expanded(
          child: _showLocationDropdown(state, context),
        ),
        Expanded(
          child: _showCategoryDropdown(state, context),
        ),
        _showClearDropdownsButton(state, context),
      ]),
      Divider(
        color: Theme.of(context).accentColor,
        thickness: 1.0,
        height: 0.0,
      )
    ]);
  }

  Widget _showGradeDropdown(HistoryState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          style: Theme.of(context).accentTextTheme.subtitle2,
          items: _createDropdownItems(widgetState.grades),
          value: state.filterGrade,
          hint: Text("Grade"),
          isExpanded: true,
          onChanged: (value) => BlocProvider.of<HistoryBloc>(context).setGradeFilter(value),
        )));
  }

  Widget _showLocationDropdown(HistoryState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          style: Theme.of(context).accentTextTheme.subtitle2,
          items: _createDropdownItems(widgetState.locationNamesToIds.keys.toList()),
          value: state.filterLocation,
          hint: Text("Location"),
          isExpanded: true,
          onChanged: (value) => BlocProvider.of<HistoryBloc>(context).setLocationFilter(value),
        )));
  }

  Widget _showCategoryDropdown(HistoryState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: UIConstants.SMALLER_PADDING),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          style: Theme.of(context).accentTextTheme.subtitle2,
          items: _createDropdownItems(widget.categories),
          value: state.filterCategory,
          hint: Text("Category"),
          isExpanded: true,
          onChanged: (value) => BlocProvider.of<HistoryBloc>(context).setCategoryFilter(value),
        )));
  }

  Widget _showClearDropdownsButton(HistoryState state, BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        child: IconButton(
            icon: Icon(Icons.cancel,
                color: (state.filterGrade == null &&
                        state.filterLocation == null &&
                        state.filterCategory == null)
                    ? Colors.grey
                    : Theme.of(context).accentColor),
            onPressed: () => BlocProvider.of<HistoryBloc>(context).clearFilters()));
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

  Widget _buildGroupedList(HistoryState state, BuildContext context) {
    List<Attempt> filteredAttempts = _filterAttempts(state);
    List<DateTime> datesToBuild = _generateDates(filteredAttempts);

    Widget content = (filteredAttempts.isEmpty)
        ? Column(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Text(
                "There are no ${(state.reachedEnd) ? "existing" : "loaded"} attempts matching the above criteria.",
                style: Theme.of(context).accentTextTheme.subtitle2,
              ))),
              _showLoadMoreButton(state, context)
            ],
          )
        : ListView.builder(
            itemBuilder: (context, index) {
              if (index == datesToBuild.length) {
                return _showLoadMoreButton(state, context);
              } else {
                return _buildDateCard(context, filteredAttempts, datesToBuild, index);
              }
            },
            itemCount: datesToBuild.length + 1,
          );

    return RefreshIndicator(
        onRefresh: () => BlocProvider.of<HistoryBloc>(context).refreshAttempts(), child: content);
  }

  List<Attempt> _filterAttempts(HistoryState state) {
    List<Attempt> filteredAttempts = List.from(state.attempts);
    if (state.filterGrade != null) {
      filteredAttempts.retainWhere((attempt) => attempt.climbGrade == state.filterGrade);
    }
    if (state.filterLocation != null) {
      filteredAttempts.retainWhere(
          (attempt) => attempt.locationId == widgetState.locationNamesToIds[state.filterLocation]);
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

  Widget _showLoadMoreButton(HistoryState state, BuildContext context) {
    if (!state.reachedEnd) {
      return Padding(
          padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
          child: SizedBox(
            height: 40.0,
            width: double.infinity,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
              color: Theme.of(context).accentColor,
              child: (state.attemptsLoading)
                  ? Center(
                      child: Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black,
                          )))
                  : Text('LOAD MORE', style: Theme.of(context).primaryTextTheme.button),
              onPressed: () => BlocProvider.of<HistoryBloc>(context).retrieveMoreAttempts(),
            ),
          ));
    } else {
      return Padding(
        padding: EdgeInsets.only(top: UIConstants.SMALLER_PADDING),
        child: SizedBox(
          height: 40.0,
          width: double.infinity,
          child: Text(
            "You've reached the end of your ${state.attempts.length} attempts",
            style: Theme.of(context).accentTextTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void navigateToClimb(BuildContext context, String climbId, String climbName) {
    NavigationHelper.navigateToViewOnlyClimb(context, climbId, climbName, addToBackStack: true);
  }
}
