import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase/supabase.dart';
import 'package:Tasks/Screens/Auth/registerPage.dart';
import 'package:Tasks/Screens/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:Tasks/Services/AuthService/authService.dart';

class LoginPage extends StatefulWidget {
  String email = '';
  LoginPage({this.email});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthService _service = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool logging = false, obscure = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _emailController.text = widget.email;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(100.0),
                ),
                child: Center(
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: ScreenUtil().setSp(100.0),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: size.height / 8,
                  left: ScreenUtil().setWidth(80.0),
                  right: ScreenUtil().setWidth(80.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: ScreenUtil().setHeight(10.0),
                    left: ScreenUtil().setWidth(40.0),
                    right: ScreenUtil().setWidth(40.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor: Colors.grey[600],
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: "Required"),
                            EmailValidator(
                                errorText:
                                    "Please enter a valid email address"),
                          ]),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15.0),
                        ),
                        TextFormField(
                          obscureText: obscure,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.edit_attributes,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[600],
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: "Required"),
                            MinLengthValidator(6,
                                errorText:
                                    "Password must contain atleast 6 characters"),
                            MaxLengthValidator(20,
                                errorText:
                                    "Password must not be more than 20 characters"),
                          ]),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15.0),
                        ),
                        logging == false
                            ? ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      logging = true;
                                    });
                                    login();
                                  }
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 50.0),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                              )
                            : CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: ScreenUtil().setHeight(40.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future login() async {
    final box = Get.find<GetStorage>();
    GotrueSessionResponse result =
        await _service.signIn(_emailController.text, _passwordController.text);

    if (result.data != null) {
      await box.write('user', result.data.persistSessionString);
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(content: "Login successful", type: "Success"),
      );
      setState(() {
        logging = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else if (result.error.message != null) {
      setState(() {
        logging = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(content: result.error.message, type: "Error"),
      );
    }
  }
}

SnackBar snackBar({String content, String type}) => SnackBar(
      content: Text(
        content,
        style: TextStyle(
          color: Colors.white,
          fontSize: 40.0.sp,
        ),
      ),
      backgroundColor: type == "Error" ? Colors.red : Colors.green,
    );
