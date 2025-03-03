import 'package:arkes_chat_app/services/auth_service.dart';
import 'package:arkes_chat_app/widgets/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  var _isLogin = true;
  var _isAuthenticating = false;

  final _form = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signInWithGoogle() async {
    final userCredential = await _authService.signInWithGoogle();

    if (userCredential == null) {
      print('thua luon');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google Sign-In failed')));
      return;
    }
    final user = userCredential!.user;
    if (user == null) {
      return;
    }
    final userEmail = user!.email;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'username': '',
        'image_url': '',
        'isProfileComplete': false,
      });
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Chờ Firestore cập nhật
    }

    FirebaseAuth.instance.authStateChanges().listen((user) {
      print("Auth State Changed: ${user?.uid}");
    });
    print('google thanh cong');
    return;
  }

  void snackBarResult(String result) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  void _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }

    final _enteredEmail = _emailController.text;
    final _enteredPassword = _passwordController.text;

    print("Email: $_enteredEmail, Password: $_enteredPassword");

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        // Tạo user trên Firestore với isProfileComplete = false
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'email': _enteredEmail,
              'username': '',
              'image_url': '',
              'isProfileComplete': false,
            });

        print('tao thanh cong');
      }
      if (mounted) {
        snackBarResult('${_isLogin ? 'Login' : 'Sign up'} Successfully');
        setState(() {
          _isAuthenticating = false;
        });
      }
      FirebaseAuth.instance.authStateChanges().listen((user) {
        print("Auth State Changed: ${user?.uid}");
      });
      setState(() {
        _isAuthenticating = false;
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isAuthenticating = false;
      });

      snackBarResult(error.message.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/swim.png', width: 180),
              const SizedBox(height: 10),
              Column(
                children: [
                  Text(
                    'Welcome!',
                    style: GoogleFonts.itim(
                      fontSize: 45,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'to',
                            style: GoogleFonts.itim(
                              fontSize: 40,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),

                      Image.asset('assets/images/logostar.png', width: 150),
                    ],
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an email.';
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (!RegExp(
                            r'^(?=.*[A-Z])(?=.*[!@#\$%^&*.,<>?])[^\s_]{6,}$',
                          ).hasMatch(value)) {
                            return 'Password must be at least 6 characters, \ninclude an uppercase letter and a special character';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isAuthenticating ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(300, 50),
                          backgroundColor: Color.fromRGBO(88, 170, 137, 1),
                        ),
                        child:
                            !_isAuthenticating
                                ? Text(
                                  _isLogin ? 'Login' : 'Signup',
                                  style: TextStyle(color: Colors.white),
                                )
                                : const CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 10),
                      if (_isLogin)
                        ElevatedButton(
                          onPressed: _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(300, 50),
                            backgroundColor: Color.fromRGBO(219, 73, 57, 1),
                          ),
                          child: const Text(
                            'Login with Google',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'Don\'t have an account ?'
                                : 'Do you have an account ?',
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin ? 'Sign up' : 'Login',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
