import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';
import 'package:Tasks/Screens/Home/home.dart';
import 'package:Tasks/Services/DB_Service/dbService.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewPage extends StatefulWidget {
  String title, desc;
  int index;
  ViewPage({this.title, this.desc, this.index});

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  bool loading = false;

  DBService _dbService = DBService();

  List taskList;

  TextEditingController _descController = TextEditingController();

  TextEditingController _titleController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future getData() async {
    setState(() {
      loading = true;
    });
    List list = await _dbService.readData();
    setState(() {
      taskList = list;
      loading = false;
      widget.title = taskList[widget.index]["Title"];
      widget.desc = taskList[widget.index]["Description"];
    });
    print(taskList);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Get.off(() => HomePage());
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () async {
                await updateForm(context, "Title", _titleController);
                getData();
              },
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20.0.h,
                  left: 60.0.w,
                  bottom: 10.0.h,
                ),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 100.0.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 60.0.w,
              ),
              child: Divider(
                thickness: 5.0,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 5.0.h,
            ),
            InkWell(
              onTap: () async {
                await updateForm(context, "Description", _descController);
                getData();
              },
              child: Padding(
                padding: EdgeInsets.only(top: 20.0.h, left: 60.0.w),
                child: Text(
                  widget.desc,
                  style: TextStyle(
                    fontSize: 70.0.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateForm(BuildContext context, String text,
      TextEditingController controller) async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.grey[900],
        ),
        body: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0.w),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5.0.w, bottom: 5.0.h),
                    child: Text(
                      '$text : ',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 60.0.sp,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: controller,
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
                    height: 10.0.h,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          horizontal: 10.0.h,
                          vertical: 5.0.h,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    child: Text('Submit'),
                    onPressed: () async {
                      if (1 == 1) {
                        try {
                          PostgrestResponse response = text == 'Title'
                              ? await _dbService.upDateTitle(
                                  widget.title,
                                  _titleController.text,
                                )
                              : await _dbService.upDateDesc(
                                  widget.desc,
                                  _descController.text,
                                );
                          getData();
                          if (response.error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBar(
                                  content: "Task updated", type: "Success"),
                            );
                            setState(() {
                              text == 'Title'
                                  ? widget.title = _titleController.text
                                  : widget.desc = _descController.text;
                            });
                          }
                          Navigator.pop(context);
                          //print(_titleController.text);
                          // print(response.data);
                          _titleController.clear();
                          _descController.clear();
                        } catch (e) {
                          getData();
                          _formKey.currentState.reset();
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBar(content: e.toString(), type: "Error"),
                          );
                          print("Error in next line");
                          print(e);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
