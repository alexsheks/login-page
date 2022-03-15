import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:login_page/validator.dart';
import 'package:provider/provider.dart';

import 'auth.dart';
import 'dimension.dart';
import 'or_devider.dart';
import 'rounded_button.dart';
import 'show_exception_alert_dialog.dart';
import 'social_icon.dart';
import 'text_field_container.dart';

enum EmailSignInFormType { signIn, register }

class LoginPage extends StatefulWidget with EmailAndPasswordValidators {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;
  String get _password => _passwordController.text;
  EmailSignInFormType _formType = EmailSignInFormType.signIn;
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      if (_formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await auth.createUserWithEmailAndPassword(_email, _password);
      }
    } on FirebaseAuthException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Что-то пошло не так...',
        exception: e,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _emailEditingComplete() {
    final newFocus = widget.emailValidator.isValid(_email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleFormType() {
    setState(() {
      _submitted = false;
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final primaryText =
        _formType == EmailSignInFormType.signIn ? 'Войти' : 'Создать аккаунт';
    final secondaryText = _formType == EmailSignInFormType.signIn
        ? 'Нужен аккаунт?'
        : 'Уже есть аккаунт?';
    final secondaryTextTwo = _formType == EmailSignInFormType.signIn
        ? 'Зарегестрироваться'
        : 'Войти';
    final imageAsset = _formType == EmailSignInFormType.signIn
        ? 'img/other/sign_up_cats.svg'
        : 'img/other/login_green.svg';

    bool submitEnabled = widget.emailValidator.isValid(_email) &&
        widget.passwordValidator.isValid(_password) &&
        !_isLoading;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Dimensions.screenHeight * 0.03),
            SvgPicture.asset(
              imageAsset,
              height: Dimensions.screenHeight * 0.35,
            ),
            SizedBox(height: Dimensions.screenHeight * 0.03),
            _buildEmailTextField(),
            _buildPasswordTextField(),
            RoundedButton(
              text: primaryText,
              press: submitEnabled ? _submit : null,
            ),
            SizedBox(height: Dimensions.screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  secondaryText,
                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: !_isLoading ? _toggleFormType : null,
                  child: Text(
                    secondaryTextTwo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocialIcon(
                  iconSrc: "img/other/google-plus.svg",
                  press: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildPasswordTextField() {
    bool showErrorText =
        _submitted && !widget.passwordValidator.isValid(_password);
    return TextFieldContainer(
      child: TextField(
        obscureText: true,
        cursorColor: Color(0xFF6F35A5),
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        decoration: InputDecoration(
          hintText: 'Пароль',
          errorText: showErrorText ? widget.invalidPasswordErrorText : null,
          enabled: _isLoading == false,
          icon: Icon(
            Icons.lock,
            color: Color(0xFF6F35A5),
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: Colors.black38,
          ),
          border: InputBorder.none,
        ),
        textInputAction: TextInputAction.done,
        onChanged: (password) => _updateState(),
        onEditingComplete: _submit,
      ),
    );
  }

  _buildEmailTextField() {
    bool showErrorText = _submitted && !widget.emailValidator.isValid(_email);
    return TextFieldContainer(
      child: TextField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        onChanged: (email) => _updateState(),
        cursorColor: Color(0xFF6F35A5),
        decoration: InputDecoration(
          errorText: showErrorText ? widget.invalidEmailErrorText : null,
          enabled: _isLoading == false,
          icon: Icon(
            Icons.person,
            color: Color(0xFF6F35A5),
          ),
          hintText: "Email",
          border: InputBorder.none,
        ),
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        onEditingComplete: _emailEditingComplete,
      ),
    );
  }

  void _updateState() {
    setState(() {});
  }
}
