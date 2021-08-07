import 'dart:math';

import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:random_color/random_color.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_auth/Screens/Auth/loginPage.dart';
import 'package:supabase_auth/Services/AuthService/authService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth/Services/DB_Service/dbService.dart';
import 'package:supabase_auth/main.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService _authservice = AuthService();
  bool loading = false, logOutLoader = false;
  List del_loading;
  DBService _dbService = DBService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _status = TextEditingController();
  RandomColor _randomColor = RandomColor();
  List taskList;
  List<Widget> tasks;
  Future getData() async {
    setState(() {
      loading = true;
    });
    List list = await _dbService.readData();
    setState(() {
      taskList = list;
      loading = false;
    });
    print(taskList);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  SnackBar snackBar({String content, String type}) => SnackBar(
        content: Text(
          content,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: type == "Error" ? Colors.red : Colors.green,
      );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              bottom: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 50.0,
                elevation: 0.0,
                backgroundColor: Colors.grey[900], // Color(0xffE5E5E5),
                title: Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Text(
                    'My Tasks',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              elevation: 0.0,
              backgroundColor: Colors.grey[700], // Color(0xffE5E5E5),
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              leading: Padding(
                padding: EdgeInsets.only(top: 8.0, left: 8.0),
                child: InkWell(
                  onTap: () async {
                    //Scaffold.of(context).openDrawer();
                    print('loggin');
                    setState(() {
                      logOutLoader = true;
                    });
                    await _authservice.logOut();
                    setState(() {
                      logOutLoader = false;
                    });
                    Get.to(Wrapper());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: logOutLoader == false
                        ? Icon(
                            Icons.menu_open,
                            color: Colors.black,
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.green),
                            ),
                          ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(''),
                background: Container(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Keep Working',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 40.0,
                              ),
                            ),
                            Text(
                              'Stay Productive',
                              style: TextStyle(
                                color: Colors.green[500],
                                fontSize: 30.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: loading == false
            ? taskList.length != 0
                ? Padding(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                    ),
                    child: Center(
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: taskList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0),
                                  topLeft: Radius.circular(12.0),
                                  bottomLeft: Radius.circular(12.0),
                                ),
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.grey[400],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 10.0),
                                    height: size.height,
                                    width: 10.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                      ),
                                      color: RandomColor().randomColor(
                                        colorHue: ColorHue.multiple(
                                          colorHues: [
                                            ColorHue.green,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(top: 20.0),
                                        child: Text(
                                          taskList[index]["Title"],
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 20.0),
                                        child: Text(
                                          taskList[index]["Description"]
                                                      .toString()
                                                      .length >
                                                  35
                                              ? '${taskList[index]["Description"].toString().substring(0, 35)}...'
                                              : taskList[index]["Description"]
                                                      .toString() ??
                                                  '',
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 60.0,
                                            left: 110.0,
                                          ),
                                          alignment: Alignment.bottomRight,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete_outlined,
                                              color: Colors.red[300],
                                            ),
                                            onPressed: () async {
                                              try {
                                                await _dbService.removeData(
                                                    taskList[index]['Title'],
                                                    taskList[index]
                                                        ['Description']);
                                                getData();
                                              } catch (e) {
                                                getData();
                                                print(e);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  )
                : Center(
                    child: Text(
                      "No upcoming tasks",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  )
            : Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                ),
              ),
      ),
      floatingActionButton: ElevatedButton.icon(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
          ),
          backgroundColor: MaterialStateProperty.all(Colors.green),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                bool buttonLoading = false;
                return Scaffold(
                  backgroundColor: Colors.grey[900],
                  appBar: AppBar(
                    elevation: 0.0,
                    backgroundColor: Colors.grey[900],
                  ),
                  body: Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: ListView(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Text(
                              'Title : ',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 30.0,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              focusColor: Colors.grey[300],
                              hintText: "Type here...",
                              hintStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            validator: MultiValidator([
                              RequiredValidator(errorText: "Required"),
                            ]),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Text(
                              'Description : ',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 30.0,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _descController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              focusColor: Colors.grey[300],
                              hintText: "Type here...",
                              hintStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            validator: MultiValidator([
                              RequiredValidator(errorText: "Required"),
                            ]),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          buttonLoading == false
                              ? ElevatedButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10.0,
                                      ),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.green),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                    ),
                                  ),
                                  child: Text('Submit'),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        buttonLoading = true;
                                      });
                                      try {
                                        await _dbService.addData(
                                          _titleController.text,
                                          _descController.text,
                                          false,
                                        );

                                        setState(() {
                                          buttonLoading = false;
                                        });
                                        getData();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          snackBar(
                                              content: "New task created",
                                              type: "Success"),
                                        );
                                        Navigator.pop(context);

                                        setState(() {
                                          buttonLoading = false;
                                        });
                                        _titleController.clear();
                                        _descController.clear();
                                      } catch (e) {
                                        getData();
                                        _formKey.currentState.reset();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          snackBar(content: e, type: "Error"),
                                        );
                                        setState(() {
                                          buttonLoading = false;
                                        });
                                        print(e);
                                      }
                                    }
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.green),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              });
          getData();
        },
        icon: Icon(Icons.add),
        label: Text('Add Task'),
      ),
    );
  }

  Future logout() async {
    await _authservice.logOut();
    setState(() {
      loading = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
