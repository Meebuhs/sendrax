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
        create: (context) => LoginBloc(), child: LoginWidget(widget: widget, widgetState: this));
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({Key key, @required this.widget, @required this.widgetState}) : super(key: key);

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
            Widget content = ListView(
              children: <Widget>[showForm(state, context)],
            );
            if (state.loading) {
              return Stack(children: <Widget>[
                content,
                Center(
                  child: Stack(children: <Widget>[
                    Opacity(
                        opacity: 0.4,
                        child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5.0),
                            ))),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 4.0,
                        )),
                  ]),
                )
              ]);
            } else {
              return content;
            }
          }),
      resizeToAvoidBottomPadding: false,
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
              _showUsernameInput(state),
              _showPasswordInputs(state, context),
              _showPrimaryButton(state, context),
              _showSecondaryButton(state, context),
              _showErrorMessage(state, context),
            ],
          ),
        ));
  }

  Widget _showUsernameInput(LoginState state) {
    return new TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: new InputDecoration(
          labelText: 'Username',
          icon: new Icon(
            Icons.perm_identity,
            color: Colors.grey,
          )),
      validator: (String value) {
        if (value.trim().isEmpty) {
          return 'Username cannot be empty';
        }
        return null;
      },
      onSaved: (value) => state.username = value.trim().toLowerCase(),
    );
  }

  Widget _showPasswordInputs(LoginState state, BuildContext context) {
    return state.isLogin
        ? _showPasswordInput(state, context)
        : Column(
            children: <Widget>[
              _showPasswordInput(state, context),
              _showConfirmPasswordInput(state),
            ],
          );
  }

  Widget _showPasswordInput(LoginState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        key: state.passwordKey,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            labelText: 'Password',
            helperText: state.isLogin ? null : 'Must be at least 6 characters',
            icon: new Icon(
              Icons.lock_outline,
              color: Colors.grey,
            )),
        validator: (String value) {
          if (!state.isLogin && value.trim().length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        onSaved: (value) => state.password = value.trim(),
      ),
    );
  }

  Widget _showConfirmPasswordInput(LoginState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Confirm Password',
            icon: new Icon(
              Icons.lock_outline,
              color: Colors.grey,
            )),
        validator: (String value) {
          if (value.trim() != state.passwordKey.currentState.value) {
            return 'Passwords do not match';
          }
          return null;
        },
        onSaved: (value) => state.confirmPassword = value.trim(),
      ),
    );
  }

  Widget _showPrimaryButton(LoginState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pink,
            child: Text(state.isLogin ? 'Login' : 'Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () => BlocProvider.of<LoginBloc>(context).validateAndSubmit(state, context),
          ),
        ));
  }

  Widget _showSecondaryButton(LoginState state, BuildContext context) {
    return new FlatButton(
        child: Text(state.isLogin ? 'Create an account' : 'Have an account? Sign in',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: () => BlocProvider.of<LoginBloc>(context).toggleFormMode(state));
  }

  Widget _showErrorMessage(LoginState state, BuildContext context) {
    if (state.errorMessage.length > 0) {
      return new Center(
          child: Text(
        state.errorMessage,
        style:
            TextStyle(fontSize: 13.0, color: Colors.red, height: 1.0, fontWeight: FontWeight.w300),
      ));
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
