import 'dart:convert';
import 'dart:math' as math;
import 'package:connectivity/connectivity.dart';
import 'package:fasttrackgarage_app/models/MakeMode.dart';
import 'package:fasttrackgarage_app/utils/Constants.dart';
import 'package:fasttrackgarage_app/utils/ExtraColors.dart';
import 'package:fasttrackgarage_app/utils/Rcode.dart';
import 'package:fasttrackgarage_app/utils/SPUtils.dart';
import 'package:fasttrackgarage_app/utils/Toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

class OilFilterInquiryDetail extends StatefulWidget {
  OilFilterInquiryDetail({Key key}) : super(key: key);

  @override
  _OilFilterInquiryDetailState createState() => _OilFilterInquiryDetailState();
}

class _OilFilterInquiryDetailState extends State<OilFilterInquiryDetail>
    with TickerProviderStateMixin {
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  TextEditingController mileageController = TextEditingController();
  TextEditingController winController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  List<String> locationList = [];

  List<String> makeList = [];

  String selectedMake, makeDate, selectedLocation, selectedModel, selectedYear;
  DateTime selectedDate = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  bool isProgressBarShown = false;
  List<int> yearList = [];
  String nearestStorePhn, whatsAppNum;
  var _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> modelList = [];
  List<MakeModel> makeModelList = [];

  static const List<String> imageList = const [
    "images/call.png",
    "images/whatsapp.png"
  ];
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    getMakeList().whenComplete(() async {
      getLocation().then((value) async {
        getPrefs();
      });
      getYearList();
    });
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    Color backgroundColor = Theme.of(context).cardColor;
    // Color foregroundColor = Theme.of(context).accentColor;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(ExtraColors.scaffoldColor),

      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
         centerTitle: true,
        backgroundColor: Color(ExtraColors.appBarColor),
        title: Text("OIL FILTER INQUIRY ",
            style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isProgressBarShown,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 40,
                    width: width * 0.45,

                    padding: EdgeInsets.only(left: 5),
                    // margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.orange),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        iconEnabledColor: Colors.white,
                        iconDisabledColor: Colors.white,
                        dropdownColor: Color(ExtraColors.scaffoldColor),
                        hint: Text(
                          "Select Make",
                          style: TextStyle(color: Colors.white),
                        ),
                        isExpanded: true,
                        items: makeModelList.map((MakeModel value) {
                          return new DropdownMenuItem<String>(
                            value: value.name,
                            child: new Text(
                              value.name,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        value: selectedMake,
                        onChanged: (value) {
                          getModelCode(value);

                          setState(() {
                            selectedMake = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: width * 0.45,
                    padding: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                        // border: Border.all(width: 0.3),
                        border: Border.all(width: 1, color: Colors.orange),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        iconEnabledColor: Colors.white,
                        iconDisabledColor: Colors.white,
                        dropdownColor: Color(ExtraColors.scaffoldColor),
                        hint: Text(
                          "Select Model",
                          style: TextStyle(color: Colors.white),
                        ),
                        isExpanded: true,
                        items: modelList.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(
                              value,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        value: selectedModel,
                        onChanged: (value) {
                          setState(() {
                            selectedModel = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 60,
                    width: width * 0.45,
                    child: TextFormField(
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      controller: mileageController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Mileage',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: width * 0.45,
                    child: TextFormField(
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      controller: winController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'VIN No.',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   height: 60,
                  //   width: 170,
                  //   child: TextFormField(
                  //     validator: (value) {
                  //       if (value.length == 0) {
                  //         return ("Please fill up this field.");
                  //       } else {
                  //         return null;
                  //       }
                  //     },
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //     ),
                  //     controller: nameController,
                  //     decoration: InputDecoration(
                  //       contentPadding: EdgeInsets.all(8),
                  //       isDense: true,
                  //       labelText: 'Name',
                  //       hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                  //       border: OutlineInputBorder(),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 40,
                    width: width * 0.45,
                    padding: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.orange),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        iconEnabledColor: Colors.white,
                        iconDisabledColor: Colors.white,
                        dropdownColor: Color(ExtraColors.scaffoldColor),
                        hint: Text(
                          "Select Year",
                          style: TextStyle(color: Colors.white),
                        ),
                        isExpanded: true,
                        items: yearList.map((int value) {
                          return new DropdownMenuItem<String>(
                            value: value.toString(),
                            child: new Text(
                              value.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        value: selectedYear,
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: width * 0.45,

                    padding: EdgeInsets.only(left: 5),
                    // margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.orange),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        iconEnabledColor: Colors.white,
                        iconDisabledColor: Colors.white,
                        dropdownColor: Color(ExtraColors.scaffoldColor),
                        hint: Text(
                          "Location",
                          style: TextStyle(color: Colors.white),
                        ),
                        isExpanded: true,
                        items: locationList.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(
                              value,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        value: selectedLocation,
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 60,
                    width: width * 0.45,
                    child: TextFormField(
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      controller: nameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: width * 0.45,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      controller: phoneController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Phone Number',
                        hintStyle: TextStyle(color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 60,
                    width: width * 0.45,
                    child: TextFormField(
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        _selectDate(context);
                      },
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      controller: dateController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Date',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: width * 0.45,
                    child: TextFormField(
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        _selectTime(context);
                      },
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      controller: timeController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Time',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 60,
                    width: width * 0.94,
                    child: TextFormField(
                      validator: (value) {
                        bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value);
                        if (value.isEmpty) {
                          return 'Please fill up this field';
                        } else if (!emailValid) {
                          return 'Please enter a valid address';
                        }
                        return null;
                      },
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      controller: emailController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[],
              )),
              Container(
                width: width * 0.94,
                child: TextFormField(
                  validator: (value) {
                    if (value.length == 0) {
                      return ("Please fill up this field.");
                    } else {
                      return null;
                    }
                  },
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  controller: commentController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    isDense: true,
                    labelText: 'Enter the comment',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.orange,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.orange,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 35, 0, 5),
                  width: width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                      ),
                      primary: Color(0xffef773c),
                    ),
                    onPressed: () {
                      // performLogin();
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        submitOilInquiryData();
                      }
                    },
                    child: Text(
                      "Send",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context).pop();
                        // String nearestPhoneNo = SpUtil.getString(
                        //         Constants.nearestStorePhoneNo)
                        //     .replaceAll(
                        //         new RegExp(r"\s+\b|\b\s"), "");
                        var url = "tel:$nearestStorePhn";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffef773c),
                        ),
                        child: Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        alignment: Alignment.center,
                      ),
                      // child: Image.asset(
                      //   "images/call.png",
                      //   height: 40,
                      //   width: 40,
                      // ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context).pop();
                        // String whatappNO = SpUtil.getString(
                        //     Constants.whatsAppNumber);
                        print("Whats app number $whatsAppNum");
                        var whatsappUrl = "whatsapp://send?phone=$whatsAppNum";
                        await canLaunch(whatsappUrl)
                            ? launch(whatsappUrl)
                            : showAlert();
                      },
                      child: Image.asset(
                        "images/logowa.png",
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ]),
          ),
        ),
      ),
      // floatingActionButton: new Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: new List.generate(imageList.length, (int index) {
      //     Widget child = new Container(
      //       height: 70.0,
      //       width: 56.0,
      //       alignment: FractionalOffset.topCenter,
      //       child: new ScaleTransition(
      //         scale: new CurvedAnimation(
      //           parent: _controller,
      //           curve: new Interval(0.0, 1.0 - index / imageList.length / 2.0,
      //               curve: Curves.easeOut),
      //         ),
      //         child: new FloatingActionButton(
      //           heroTag: null,
      //           backgroundColor: backgroundColor,
      //           mini: true,
      //           // child: new Icon(icons[index], color: foregroundColor),
      //           child: new Image.asset(
      //             imageList[index],
      //           ),
      //           onPressed: () async {
      //             if (index == 0) {
      //               var url = "tel:$nearestStorePhn";
      //               if (await canLaunch(url)) {
      //                 await launch(url);
      //               } else {
      //                 throw 'Could not launch $url';
      //               }
      //             } else if (index == 1) {
      //               var whatsappUrl = "whatsapp://send?phone=$whatsAppNum";
      //               await canLaunch(whatsappUrl)
      //                   ? launch(whatsappUrl)
      //                   : showAlert();
      //             }
      //           },
      //         ),
      //       ),
      //     );
      //     return child;
      //   }).toList()
      //     ..add(
      //       new FloatingActionButton(
      //         backgroundColor: Color(0xffef773c),
      //         heroTag: null,
      //         child: new AnimatedBuilder(
      //           animation: _controller,
      //           builder: (BuildContext context, Widget child) {
      //             return new Transform(
      //               transform: new Matrix4.rotationZ(
      //                   _controller.value * 0.5 * math.pi),
      //               alignment: FractionalOffset.center,
      //               child: new Icon(
      //                   _controller.isDismissed ? Icons.call : Icons.close),
      //             );
      //           },
      //         ),
      //         onPressed: () {
      //           if (_controller.isDismissed) {
      //             _controller.forward();
      //           } else {
      //             _controller.reverse();
      //           }
      //         },
      //       ),
      //     ),
      // ),
    );
  }

  showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10.0),
          actions: <Widget>[
            Container(
              width: 100,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                // color: Colors.blue[700],
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
          ],
          content: Container(
            height: 100,
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 35, 0, 20),
                        child: Text(
                            "There is no whatsapp installed on your mobile device"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Future<void> getInquiryDataForOil() async {
  //   showProgressBar();
  //   Map<String, String> header = {
  //     "Content-Type": "application/json",
  //   };
  //   await http
  //       .get("https://fasttrackemarat.com/feed/oil_change.json",
  //           headers: header)
  //       .then((res) {
  //     hideProgressBar();
  //     int status = res.statusCode;
  //     if (status == Rcode.successCode) {
  //       var result = json.decode(res.body);

  //       var values = result['data'];
  //       setState(() {
  //         makeList = List<String>.from(values['make']);
  //         // heightList = List<String>.from(values['height']);
  //         // rimSizeList = List<String>.from(values['rim-size']);
  //         // brandList = List<String>.from(values['brand']);
  //       });

  //       print(values);
  //     }
  //   });
  // }

  Future<void> getMakeList() async {
    Map<String, String> header = {
      "Content-Type": "application/json",
    };
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      showProgressBar();
      await http
          .get("https://fasttrackemarat.com/feed/make-model.json",
              headers: header)
          .then((res) {
        hideProgressBar();
        int status = res.statusCode;
        if (status == Rcode.successCode) {
          var result = json.decode(res.body);

          var values = result['data']["make"];

          makeModelList = values
              .map<MakeModel>((json) => MakeModel.fromJson(json))
              .toList();

          setState(() {});
        }
      });
    } else {
      ShowToast.showToast(context, "No internet connection");
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        makeDate = picked.toString();
        dateController.text = makeDate.substring(0, 10);
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    TimeOfDay t = await showTimePicker(
      context: context,
      initialTime: time,
    );
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    if (t != null) {
      String formattedTime =
          localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
      setState(() {
        timeController.text = formattedTime;
      });
    }
  }

  Future<void> getLocation() async {
    Map<String, String> header = {
      "Content-Type": "application/json",
    };
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      showProgressBar();
      await http
          .get("https://fasttrackemarat.com/feed/brakes.json", headers: header)
          .then((res) {
        hideProgressBar();
        int status = res.statusCode;
        if (status == Rcode.successCode) {
          var result = json.decode(res.body);
          var values = result['data'];
          setState(() {
            locationList = List<String>.from(values['location']);
          });
        }
      });
    } else {
      ShowToast.showToast(context, "No internet connection");
    }
  }

  displaySnackbar(BuildContext context, msg) {
    final snackBar = SnackBar(
      content: Text('$msg'),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showProgressBar() {
    setState(() {
      isProgressBarShown = true;
    });
  }

  void hideProgressBar() {
    setState(() {
      isProgressBarShown = false;
    });
  }

  void submitOilInquiryData() async {
    showProgressBar();
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    final body = jsonEncode({
      "car-brand": selectedMake,
      "car-model": selectedModel,
      "mileage": mileageController.text,
      "winno": winController.text,
      "year": selectedYear,
      "location": selectedLocation,
      "date": dateController.text,
      "time": timeController.text,
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "message": commentController.text
    });

    await http
        .post("https://fasttrackemarat.com/contact-from-app/oil-change.php",
            headers: header, body: body)
        .then((res) {
      hideProgressBar();
      if (res.statusCode == Rcode.successCode) {
        displaySnackbar(context, "Inquiry submitted successfully");
        setState(() {
          dateController.text = "";
          timeController.text = "";
          commentController.text = "";
          mileageController.text = "";
          winController.text = "";
          selectedMake = null;
          selectedModel = null;
          selectedYear = null;
          selectedLocation = null;
        });
      } else {
        displaySnackbar(context, "Error: ${res.body}");
      }
    });
  }

  Future<Null> getYearList() async {
    for (int i = 1964; i <= int.parse(DateTime.now().year.toString()); i++) {
      yearList.add(i);
    }
    setState(() {});
  }

  void getModelCode(String selectedMake) async {
    makeModelList.forEach((item) {
      if (item.name == selectedMake) {
        setState(() {
          modelList = item.model;
        });
      }
    });
  }

  Future<void> getPrefs() async {
    String customerName, customerNumber, customerEmail;
    setState(() {
      nearestStorePhn = SpUtil.getString(Constants.nearestStorePhoneNo)
          .replaceAll(new RegExp(r"\s+\b|\b\s"), "");
      whatsAppNum = SpUtil.getString(Constants.whatsAppNumber);
      customerName = SpUtil.getString(Constants.customerName);
      customerNumber = SpUtil.getString(Constants.customerMobileNo);
      customerEmail = SpUtil.getString(Constants.customerEmail);

      nameController.text = customerName;
      phoneController.text = customerNumber;
      emailController.text = customerEmail;
    });
  }
}
