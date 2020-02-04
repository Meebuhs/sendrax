import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendrax/navigation_helper.dart';
import 'package:sendrax/util/constants.dart';

import 'login_bloc.dart';
import 'login_state.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _heightAnimation;
  Animation _slideAnimation;

  @override
  initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _heightAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        curve: Interval(0.0, 0.5, curve: Curves.easeOutQuad), parent: _animationController));
    _slideAnimation = Tween(begin: const Offset(-1.5, 0.0), end: Offset.zero).animate(
        CurvedAnimation(
            curve: Interval(0.4, 1.0, curve: Curves.easeOutQuad), parent: _animationController));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(), child: LoginWidget(widget: widget, widgetState: this));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        title: Text("sendrax"),
      ),
      body: _buildBody(context),
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<LoginBloc>(context),
        builder: (context, LoginState state) {
          Widget content = ListView(
            children: <Widget>[_showForm(state, context)],
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
                            borderRadius: BorderRadius.circular(UIConstants.FIELD_BORDER_RADIUS),
                          ))),
                  SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 4.0,
                      ))),
                ]),
              )
            ]);
          } else {
            return content;
          }
        });
  }

  Widget _showForm(LoginState state, BuildContext context) {
    return new Container(
        padding: EdgeInsets.all(UIConstants.STANDARD_PADDING),
        child: new Form(
          key: state.formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showUsernameInput(state, context),
              _showPasswordInputs(state, context),
              _showPrimaryButton(state, context),
              _showSecondaryButton(state, context),
              _showErrorMessage(state, context),
            ],
          ),
        ));
  }

  Widget _showUsernameInput(LoginState state, BuildContext context) {
    return new TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      style: Theme.of(context).accentTextTheme.subtitle2,
      decoration: new InputDecoration(
          labelText: 'Username',
          filled: true,
          fillColor: Theme.of(context).cardColor,
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
          enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
          errorBorder: Theme.of(context).inputDecorationTheme.errorBorder,
          focusedErrorBorder: Theme.of(context).inputDecorationTheme.focusedErrorBorder,
          errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
          prefixIcon: new Icon(Icons.perm_identity)),
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
    return Column(
      children: <Widget>[
        _showPasswordInput(state, context),
        _showConfirmPasswordInput(state, context),
      ],
    );
  }

  Widget _showPasswordInput(LoginState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, UIConstants.STANDARD_PADDING, 0.0, 0.0),
      child: new TextFormField(
        key: state.passwordKey,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        style: Theme.of(context).accentTextTheme.subtitle2,
        decoration: new InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            errorBorder: Theme.of(context).inputDecorationTheme.errorBorder,
            focusedErrorBorder: Theme.of(context).inputDecorationTheme.focusedErrorBorder,
            errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
            prefixIcon: new Icon(Icons.lock_outline)),
        validator: (String value) {
          if (!state.isLogin && value.trim().length < 6) {
            return 'Password must be at least 6 characters';
          } else if (value.trim().isEmpty) {
            return 'Password cannot be empty';
          }
          return null;
        },
        onSaved: (value) => state.password = value.trim(),
      ),
    );
  }

  Widget _showConfirmPasswordInput(LoginState state, BuildContext context) {
    Widget passwordContent = Padding(
      padding: const EdgeInsets.fromLTRB(0.0, UIConstants.STANDARD_PADDING, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        style: Theme.of(context).accentTextTheme.subtitle2,
        decoration: new InputDecoration(
            labelText: 'Confirm Password',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            errorBorder: Theme.of(context).inputDecorationTheme.errorBorder,
            focusedErrorBorder: Theme.of(context).inputDecorationTheme.focusedErrorBorder,
            errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
            prefixIcon: new Icon(Icons.lock_outline)),
        validator: (String value) {
          if (value.trim() != state.passwordKey.currentState.value) {
            return 'Passwords do not match';
          }
          return null;
        },
        onSaved: (value) => state.confirmPassword = value.trim(),
      ),
    );

    return AnimatedBuilder(
        animation: widgetState._animationController,
        builder: (context, child) {
          return Stack(children: <Widget>[
            Opacity(
                opacity: 0,
                child: Container(
                  height: widgetState._heightAnimation.value * 75,
                )),
            SlideTransition(
              position: widgetState._slideAnimation,
              child: widgetState._heightAnimation.value == 1 ? passwordContent : null,
            )
          ]);
        });
  }

  Widget _showPrimaryButton(LoginState state, BuildContext context) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, UIConstants.STANDARD_PADDING, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: UIConstants.STANDARD_ELEVATION,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(UIConstants.BUTTON_BORDER_RADIUS)),
            color: Theme.of(context).accentColor,
            child: Text(state.isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
                style: Theme.of(context).primaryTextTheme.button),
            onPressed: () => BlocProvider.of<LoginBloc>(context).validateAndSubmit(state, context),
          ),
        ));
  }

  Widget _showSecondaryButton(LoginState state, BuildContext context) {
    return new FlatButton(
        child: Text(state.isLogin ? 'Create an account' : 'Have an account? Sign in',
            style: Theme.of(context).accentTextTheme.subtitle2),
        onPressed: () {
          BlocProvider.of<LoginBloc>(context).toggleFormMode(state);
          state.isLogin
              ? widgetState._animationController.forward()
              : widgetState._animationController.reverse();
        });
  }

  Widget _showErrorMessage(LoginState state, BuildContext context) {
    if (state.errorMessage.length > 0) {
      return new Center(
          child: Text(state.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).inputDecorationTheme.errorStyle));
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
