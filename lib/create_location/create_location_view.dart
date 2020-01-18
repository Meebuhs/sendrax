import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_location_bloc.dart';
import 'create_location_state.dart';

class CreateLocationScreen extends StatefulWidget {
  CreateLocationScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocationScreen> {
  _CreateLocationState();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateLocationBloc>(
      create: (context) => CreateLocationBloc(),
      child: CreateLocationWidget(
        widget: widget,
        widgetState: this,
      ),
    );
  }
}

class CreateLocationWidget extends StatelessWidget {
  const CreateLocationWidget({Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final CreateLocationScreen widget;
  final _CreateLocationState widgetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a location"),
      ),
      body: BlocBuilder(
          bloc: BlocProvider.of<CreateLocationBloc>(context),
          builder: (context, CreateLocationState state) {
            if (state.loading) {
              return Center(child: CircularProgressIndicator(strokeWidth: 4.0));
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              );
            }
          }),
    );
  }
}
