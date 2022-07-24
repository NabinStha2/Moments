import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:moment/screens/news_feed_screen.dart';
import 'package:moment/screens/profile_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController confirmPasswordController =
      new TextEditingController();
  bool isSignIn = true;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    // getStorageValues();
  }

  // getStorageValues() async {
  //   authStorageValues = await getStorage();

  //   if (authStorageValues != null) {
  //     log("AuthScreen: $authStorageValues");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text("Login Successfully"),
                elevation: 0.0,
                duration: Duration(seconds: 1),
              ),
            );
        }
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text("Register Successfully"),
                elevation: 0.0,
                duration: Duration(seconds: 1),
              ),
            );
        }
        // if (state is UploadImageLoading) {
        //   ScaffoldMessenger.of(context)
        //     ..hideCurrentSnackBar()
        //     ..showSnackBar(
        //       SnackBar(
        //         behavior: SnackBarBehavior.floating,
        //         backgroundColor: Colors.grey,
        //         content: Text("Image Uploading..."),
        //         elevation: 0.0,
        //         duration: Duration(seconds: 3),
        //       ),
        //     );
        // }
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 1),
                elevation: 0.0,
                content: Text(state.error),
              ),
            );
        }
      },
      builder: (context, state) {
        if (state is LogoutSuccess) {
          return buildForm(state);
        }
        // if (state is AuthLoading) {
        //   return buildForm(state);
        // }
        if (state is RegisterSuccess) {
          return buildForm(state);
        }
        if (state is AuthLoaded) {
          // print(state.user);
          return ProfileScreen(userId: state.ownerUser!.id!);
        }
        if (state is AuthError) {
          // print(state.user);
          return buildForm(state);
        }
        return authStorageValues != null && authStorageValues!.isNotEmpty
            ? ProfileScreen(userId: authStorageValues!["id"]!)
            : buildForm(state);
      },
    );
  }

  Widget buildForm(state) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                isSignIn ? "Sign In" : "Sign Up",
                style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: GoogleFonts.courgette().fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    !isSignIn
                        ? TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: firstNameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "FirstName",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              hintText: 'Enter your firstname',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter firstname';
                              }
                              return null;
                            },
                          )
                        : Container(),
                    const SizedBox(height: 10.0),
                    !isSignIn
                        ? TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: lastNameController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "LastName",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              hintText: 'Enter your lastname',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter lastname';
                              }
                              return null;
                            },
                          )
                        : Container(),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        hintText: 'Enter your email',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 12.0),
                          child: IconButton(
                            splashRadius: 20.0,
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            icon: showPassword
                                ? const FaIcon(
                                    FontAwesomeIcons.eyeSlash,
                                    color: Colors.black,
                                    size: 18.0,
                                  )
                                : const Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.black,
                                    size: 22.0,
                                  ),
                          ), // myIcon is a 48px-wide widget.
                        ),
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        hintText: 'Enter your password',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    !isSignIn
                        ? TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: confirmPasswordController,
                            keyboardType: TextInputType.text,
                            obscureText: !showPassword,
                            decoration: InputDecoration(
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 12.0),
                                child: IconButton(
                                  splashRadius: 20.0,
                                  onPressed: () {
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                  icon: showPassword
                                      ? const FaIcon(
                                          FontAwesomeIcons.eyeSlash,
                                          color: Colors.black,
                                          size: 18.0,
                                        )
                                      : const Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.black,
                                          size: 22.0,
                                        ),
                                ), // myIcon is a 48px-wide widget.
                              ),
                              labelText: "Confirm Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              hintText: 'Enter your confirmpassword',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter confirmpassword';
                              }
                              return null;
                            },
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          fixedSize: MaterialStateProperty.all(
                            Size.fromWidth(
                                MediaQuery.of(context).size.width / 2.5),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            print("success");
                            if (isSignIn) {
                              BlocProvider.of<AuthBloc>(context)
                                  .add(LoginEvent(data: {
                                "email": emailController.text,
                                "password": passwordController.text,
                              }));
                              await storage.write(
                                key: "password",
                                value: passwordController.text,
                                aOptions: const AndroidOptions(),
                                iOptions: IOSOptions(
                                  accountName:
                                      accountNameController.text.isEmpty
                                          ? null
                                          : accountNameController.text,
                                ),
                              );
                            } else {
                              BlocProvider.of<AuthBloc>(context)
                                  .add(RegisterEvent(data: {
                                "firstName": firstNameController.text,
                                "lastName": lastNameController.text,
                                "email": emailController.text,
                                "password": passwordController.text,
                                "confirmPassword":
                                    confirmPasswordController.text,
                              }));
                            }
                          }
                        },
                        child: state is AuthLoading
                            ? const Center(
                                child: const SpinKitCircle(
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                              )
                            : isSignIn
                                ? const Text("Sign In")
                                : const Text("Register"),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isSignIn
                      ? const Text("Don't have an account?")
                      : const Text("Have an account?"),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isSignIn = !isSignIn;
                      });
                    },
                    child:
                        isSignIn ? const Text("SignUp") : const Text("SignIn"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
