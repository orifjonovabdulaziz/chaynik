
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_provider.dart';

class AuthPage extends ConsumerStatefulWidget  {
  const AuthPage({super.key});


  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _userlogin = '';
  String _password = '';

  bool _isObscured = true;

  bool isLoading = false;

  Future<void> _login() async {
    setState(() => isLoading = true);
    final success = await ref.read(authProvider.notifier).login(
      _userlogin.trim(),
      _password.trim(),

    );
    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home'); // Переход в HomeScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Неправильный логин или пароль")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(

          child: Form(
              key: _formKey,
              child: Padding(padding: EdgeInsets.all(40.0),
                  child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Логин",
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0), // Закругление углов
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter some text";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _userlogin = value ?? '';
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          obscureText: _isObscured,
                          decoration: InputDecoration(
                            labelText: "Пароль",
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0), // Закругление углов
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter some text";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value ?? '';
                          },

                        ),
                        SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity, // Кнопка занимает всю ширину экрана
                          child:isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Закругление углов
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _login();
                                print("Email: $_userlogin\nPassword: $_password"); // Используем сохранённое значение
                              }
                            },
                            child: Text("Войти",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, // Жирный текст
                                  color: Colors.white,
                                  fontSize: 18,
                                )
                            ),
                          ),
                        ),


                      ]
                  )
              )
          )
      ),
    );
  }
}