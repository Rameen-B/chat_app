import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  File? _selectedIamge;

  var _isAuthenticating = false;
  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }
    if (_selectedIamge == null && !_isLogin) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please upload an image.')));
      return;
    }
    _form.currentState!.save();

    try {
      _enteredEmail = _enteredEmail.trim();
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        // Log user in
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        _enteredUsername = _enteredUsername.trim();
        _enteredUsername = _enteredUsername.toLowerCase();
        // Sign user up
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images-new')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedIamge!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
              'username': _enteredUsername,
              'email': _enteredEmail,
              'image_url': imageUrl,
            });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Failed.')),
        );
      }
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  right: 20,
                  left: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png', fit: BoxFit.cover),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedIamge = pickedImage;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (newValue) => _enteredEmail = newValue!,
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              autocorrect: false,
                              enableSuggestions: false,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter at least 4 characters..';
                                }
                                return null;
                              },
                              onSaved:
                                  (newValue) => _enteredUsername = newValue!,
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (newValue) => _enteredPassword = newValue!,
                            onFieldSubmitted: (value) {
                              if (!_isAuthenticating) return _submit();
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              ),
                              child: Text(_isLogin ? 'Login' : 'Signup'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? "Create an account"
                                    : "I already have an account",
                              ),
                            ),
                        ],
                      ),
                    ),
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
