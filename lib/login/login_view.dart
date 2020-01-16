import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/navigation_helper.dart';

import 'login_bloc.dart';
import 'login_state.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(),
        child: LoginWidget(widget: widget, widgetState: this));
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget(
      {Key key, @required this.widget, @required this.widgetState})
      : super(key: key);

  final LoginScreen widget;
  final _LoginState widgetState;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<LoginBloc>(context).setupAuthStateListener(this);
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: BlocBuilder(
          bloc: BlocProvider.of<LoginBloc>(context),
          builder: (context, LoginState state) {
            if (state.loading) {
              return Center(child: CircularProgressIndicator(strokeWidth: 4.0));
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[showForm(state, context)],
                ),
              );
            }
          }),
    );
  }

  Widget showForm(LoginState state, BuildContext context) {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: state.formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showUsernameInput(state),
              showPasswordInput(state),
              showPrimaryButton(state, context),
              showSecondaryButton(state, context),
              showErrorMessage(state),
            ],
          ),
        ));
  }

  Widget showUsernameInput(LoginState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Username',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (String value) {
          if (value.trim().isEmpty) {
            return 'Username cannot be empty';
          }
          return null;
        },
        onSaved: (value) => state.username = value.trim(),
      ),
    );
  }

  Widget showPasswordInput(LoginState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (String value) {
          if (value.trim().length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        onSaved: (value) => state.password = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton(LoginState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: StreamBuilder(
              stream:
                  BlocProvider.of<LoginBloc>(context).isLoginFormStream.stream,
              builder: (BuildContext context, snapshot) {
                String buttonText =
                    'Login'; // Button text if snapshot is true (login form)
                if (snapshot.data == false) {
                  buttonText = 'Create account';
                }
                return new Text(buttonText,
                    style: new TextStyle(fontSize: 20.0, color: Colors.white));
              },
            ),
            onPressed: () =>
                BlocProvider.of<LoginBloc>(context).validateAndSubmit(state),
          ),
        ));
  }

  Widget showSecondaryButton(LoginState state, BuildContext context) {
    return new FlatButton(
        child: StreamBuilder(
          stream: BlocProvider.of<LoginBloc>(context).isLoginFormStream.stream,
          builder: (BuildContext context, snapshot) {
            String buttonText =
                'Create an account'; // Button text if snapshot is true (login form)
            if (snapshot.data == false) {
              buttonText = 'Have an account? Sign in';
            }
            return new Text(buttonText,
                style:
                    new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300));
          },
        ),
        onPressed: () =>
            BlocProvider.of<LoginBloc>(context).toggleFormMode(state));
  }

  Widget showErrorMessage(LoginState state) {
    if (state.errorMessage.length > 0 && state.errorMessage != null) {
      return new Text(
        state.errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  void navigateToMain() {
    NavigationHelper.navigateToMain(widgetState.context);
  }
}
