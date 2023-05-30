import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../utils/storage_services.dart';
import '../../../widgets/custom_text_form_field_widget.dart';

class AuthBody extends StatefulWidget {
  final AuthState? state;
  const AuthBody({Key? key, this.state}) : super(key: key);

  @override
  State<AuthBody> createState() => _AuthBodyState();
}

class _AuthBodyState extends State<AuthBody> {
  static GlobalKey<FormState> userFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: Column(
            children: [
              CustomText(
                BlocProvider.of<AuthBloc>(context).isSignIn
                    ? "Sign In"
                    : "Sign Up",
                isFontFamily: true,
                fontSize: 30.0,
                fontFamily: GoogleFonts.courgette().fontFamily,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 15.0),
              Form(
                key: userFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    !(BlocProvider.of<AuthBloc>(context).isSignIn)
                        ? CustomTextFormFieldWidget(
                            controller: BlocProvider.of<AuthBloc>(context)
                                .firstNameController,
                            keyboardType: TextInputType.text,
                            labelText: "FirstName",
                            hintText: 'Enter your firstname',
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter firstname';
                              }
                              return null;
                            },
                          )
                        : Container(),
                    const SizedBox(height: 15.0),
                    !(BlocProvider.of<AuthBloc>(context).isSignIn)
                        ? CustomTextFormFieldWidget(
                            controller: BlocProvider.of<AuthBloc>(context)
                                .lastNameController,
                            keyboardType: TextInputType.emailAddress,
                            labelText: "LastName",
                            hintText: 'Enter your lastname',
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter lastname';
                              }
                              return null;
                            },
                          )
                        : Container(),
                    const SizedBox(height: 15.0),
                    CustomTextFormFieldWidget(
                      controller:
                          BlocProvider.of<AuthBloc>(context).emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: "Email",
                      hintText: 'Enter your email',
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    CustomTextFormFieldWidget(
                      controller:
                          BlocProvider.of<AuthBloc>(context).passwordController,
                      keyboardType: TextInputType.text,
                      labelText: "Password",
                      hintText: 'Enter your password',
                      showSuffix: true,
                      suffix: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12.0),
                        child: IconButton(
                          splashRadius: 15.0,
                          onPressed: () {
                            setState(() {
                              BlocProvider.of<AuthBloc>(context).showPassword =
                                  !BlocProvider.of<AuthBloc>(context)
                                      .showPassword;
                            });
                          },
                          icon: BlocProvider.of<AuthBloc>(context).showPassword
                              ? const FaIcon(
                                  FontAwesomeIcons.eyeSlash,
                                  color: Colors.white,
                                  size: 18.0,
                                )
                              : const Icon(
                                  Icons.remove_red_eye,
                                  size: 22.0,
                                  color: Colors.white,
                                ),
                        ), // myIcon is a 48px-wide widget.
                      ),
                      showPassword:
                          !BlocProvider.of<AuthBloc>(context).showPassword,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    !BlocProvider.of<AuthBloc>(context).isSignIn
                        ? CustomTextFormFieldWidget(
                            controller: BlocProvider.of<AuthBloc>(context)
                                .confirmPasswordController,
                            showSuffix: true,
                            suffix: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 12.0),
                              child: IconButton(
                                splashRadius: 15.0,
                                onPressed: () {
                                  setState(() {
                                    BlocProvider.of<AuthBloc>(context)
                                            .showPassword =
                                        !BlocProvider.of<AuthBloc>(context)
                                            .showPassword;
                                  });
                                },
                                icon: BlocProvider.of<AuthBloc>(context)
                                        .showPassword
                                    ? const FaIcon(
                                        FontAwesomeIcons.eyeSlash,
                                        size: 18.0,
                                        color: Colors.white,
                                      )
                                    : const Icon(
                                        Icons.remove_red_eye,
                                        size: 22.0,
                                        color: Colors.white,
                                      ),
                              ), // myIcon is a 48px-wide widget.
                            ),
                            labelText: "Confirm Password",
                            hintText: 'Enter your confirmpassword',
                            showPassword: !BlocProvider.of<AuthBloc>(context)
                                .showPassword,
                            keyboardType: TextInputType.text,
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
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          fixedSize: Size.fromWidth(
                              MediaQuery.of(context).size.width / 2.5),
                        ),
                        onPressed: widget.state is AuthLoading
                            ? null
                            : () async {
                                if (userFormKey.currentState?.validate() ==
                                    true) {
                                  if (BlocProvider.of<AuthBloc>(context)
                                      .isSignIn) {
                                    BlocProvider.of<AuthBloc>(context).add(
                                        LoginEvent(context: context, data: {
                                      "email":
                                          BlocProvider.of<AuthBloc>(context)
                                              .emailController
                                              .text,
                                      "password":
                                          BlocProvider.of<AuthBloc>(context)
                                              .passwordController
                                              .text,
                                    }));
                                    await StorageServices.writeStorage(
                                        key: "password",
                                        value:
                                            BlocProvider.of<AuthBloc>(context)
                                                .passwordController
                                                .text);
                                  } else {
                                    BlocProvider.of<AuthBloc>(context).add(
                                      RegisterEvent(
                                        data: {
                                          "firstName":
                                              BlocProvider.of<AuthBloc>(context)
                                                  .firstNameController
                                                  .text,
                                          "lastName":
                                              BlocProvider.of<AuthBloc>(context)
                                                  .lastNameController
                                                  .text,
                                          "email":
                                              BlocProvider.of<AuthBloc>(context)
                                                  .emailController
                                                  .text,
                                          "password":
                                              BlocProvider.of<AuthBloc>(context)
                                                  .passwordController
                                                  .text,
                                          "confirmPassword":
                                              BlocProvider.of<AuthBloc>(context)
                                                  .confirmPasswordController
                                                  .text,
                                        },
                                        context: context,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: BlocProvider.of<AuthBloc>(context).isSignIn
                            ? CustomText(
                                "Sign In",
                                color: MColors.primaryColor,
                              )
                            : CustomText(
                                "Register",
                                color: MColors.primaryColor,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocProvider.of<AuthBloc>(context).isSignIn
                      ? CustomText("Don't have an account?")
                      : CustomText("Have an account?"),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        BlocProvider.of<AuthBloc>(context).isSignIn =
                            !BlocProvider.of<AuthBloc>(context).isSignIn;
                      });
                    },
                    child: BlocProvider.of<AuthBloc>(context).isSignIn
                        ? CustomText(
                            "SignUp",
                            color: MColors.primaryGrayColor35,
                          )
                        : CustomText(
                            "SignIn",
                            color: MColors.primaryGrayColor35,
                          ),
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
