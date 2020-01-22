import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/models/attempt.dart';
import 'package:sendrax/util/constants.dart';

import 'climb_attempt_item.dart';
import 'climb_bloc.dart';
import 'climb_state.dart';

class ClimbScreen extends StatefulWidget {
  ClimbScreen({Key key, @required this.displayName, @required this.climbId}) : super(key: key);

  final String displayName;
  final String climbId;

  @override
  State<StatefulWidget> createState() => _ClimbState(climbId);
}

class _ClimbState extends State<ClimbScreen> {
  final String climbId;

  _ClimbState(this.climbId);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClimbBloc>(
      create: (context) => ClimbBloc(climbId),
      child: ClimbWidget(widget: widget),
    );
  }
}

class ClimbWidget extends StatelessWidget {
  const ClimbWidget({Key key, @required this.widget}) : super(key: key);

  final ClimbScreen widget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.displayName)),
      body: BlocBuilder(
          bloc: BlocProvider.of<ClimbBloc>(context),
          builder: (context, ClimbState state) {
            Widget content;
            if (state.loading) {
              content = Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4.0,
                ),
              );
            } else {
              content = ListView.builder(
                padding: EdgeInsets.all(UIConstants.SMALLER_PADDING),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return SizedBox(
                      height: 200.0,
                      child: Center(
                        child: Text(
                          "Image placeholder",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (state.attempts.isEmpty) {
                    return Center(
                      child: Text(
                        "This climb doesn't have any attempts.\nLet's create one right now!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return _buildItem(state.attempts[index - 1]);
                  }
                },
                itemCount: state.attempts.isEmpty ? 2 : state.attempts.length + 1,
              );
            }
            return content;
          }),
    );
  }

  AttemptItem _buildItem(Attempt attempt) {
    return AttemptItem(attempt: attempt);
  }
}
