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
            return StreamBuilder(
                stream: BlocProvider.of<LoginBloc>(context).loadingStream.stream,
                initialData: false,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.data) {
                    return Center(child: CircularProgressIndicator(strokeWidth: 4.0));
                  } else {
                    return Center(
                      child: ListView(
                        children: <Widget>[showForm(state, context)],
                      ),
                    );
                  }
                });
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
        onSaved: (value) => state.username = value.trim().toLowerCase(),
      ),
    );
  }

  Widget _showPasswordInputs(LoginState state, BuildContext context) {
    return StreamBuilder(
        stream: BlocProvider.of<LoginBloc>(context).isLoginFormStream.stream,
        initialData: true,
        builder: (BuildContext context, snapshot) {
          Widget content = _showSignInPasswordInput(state, context);
          if (snapshot.data == false) {
            content = Column(
              children: <Widget>[
                _showSignUpPasswordInput(state, context),
                _showConfirmPasswordInput(state),
              ],
            );
          }
          return content;
        });
  }

  Widget _showSignInPasswordInput(LoginState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        key: state.passwordKey,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        onSaved: (value) => state.password = value.trim(),
      ),
    );
  }

  Widget _showSignUpPasswordInput(LoginState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        key: state.passwordKey,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            helperText: 'Must be at least 6 characters',
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
              Icons.lock,
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
            child: StreamBuilder(
              stream: BlocProvider.of<LoginBloc>(context).isLoginFormStream.stream,
              initialData: true,
              builder: (BuildContext context, snapshot) {
                String buttonText = snapshot.data ? 'Login' : 'Create account';
                return new Text(buttonText,
                    style: new TextStyle(fontSize: 20.0, color: Colors.white));
              },
            ),
            onPressed: () => BlocProvider.of<LoginBloc>(context).validateAndSubmit(state, context),
          ),
        ));
  }

  Widget _showSecondaryButton(LoginState state, BuildContext context) {
    return new FlatButton(
        child: StreamBuilder(
          stream: BlocProvider.of<LoginBloc>(context).isLoginFormStream.stream,
          initialData: true,
          builder: (BuildContext context, snapshot) {
            String buttonText = snapshot.data ? 'Create an account' : 'Have an account? Sign in';
            return new Text(buttonText,
                style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300));
          },
        ),
        onPressed: () => BlocProvider.of<LoginBloc>(context).toggleFormMode(state));
  }

  Widget _showErrorMessage(LoginState state, BuildContext context) {
    return StreamBuilder(
        stream: BlocProvider.of<LoginBloc>(context).errorMessageStream.stream,
        initialData: "",
        builder: (BuildContext context, snapshot) {
          if (snapshot.data.length > 0) {
            return new Center(
                child: Text(
              snapshot.data,
              style: TextStyle(
                  fontSize: 13.0, color: Colors.red, height: 1.0, fontWeight: FontWeight.w300),
            ));
          } else {
            return new Container(
              height: 0.0,
            );
          }
        });
  }

  void navigateToMain() {
    NavigationHelper.navigateToMain(widgetState.context);
  }
}
