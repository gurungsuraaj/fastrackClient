import 'dart:convert';
import 'dart:math' as math;
import 'package:fasttrackgarage_app/models/MakeMode.dart';
import 'package:fasttrackgarage_app/utils/Constants.dart';
import 'package:fasttrackgarage_app/utils/ExtraColors.dart';
import 'package:fasttrackgarage_app/utils/InquiryInfo.dart';
import 'package:fasttrackgarage_app/utils/Rcode.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<String> locationList = List();

  List<String> makeList = List();

  String selectedMake, makeDate, selectedLocation, selectedModel, selectedYear;
  DateTime selectedDate = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  bool isProgressBarShown = false;
  List<int> yearList = List();
  String nearestStorePhn, whatsAppNum;
  var _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> modelList = List();
  List<MakeModel> makeModelList = List();

  static const List<String> imageList = const [
    "images/call.png",
    "images/whatsapp.png"
  ];
  AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
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
    Color foregroundColor = Theme.of(context).accentColor;
    return Scaffold(
      key: _scaffoldKey,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color(ExtraColors.DARK_BLUE),
        title: Text("Oil Filter Inquiry"),
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
                    width: 170,
                    padding: EdgeInsets.only(left: 5),
                    // margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3),
                        borderRadius: BorderRadius.circular(5)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: Text("Select Make"),
                        isExpanded: true,
                        items: makeModelList.map((MakeModel value) {
                          return new DropdownMenuItem<String>(
                            value: value.name,
                            child: new Text(value.name),
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
                    width: 170,
                    padding: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3),
                        borderRadius: BorderRadius.circular(5)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: Text("Select Model"),
                        isExpanded: true,
                        items: modelList.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
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
                    width: 170,
                    child: TextFormField(
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      controller: mileageController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Mileage',
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 170,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      controller: winController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'WIN No.',
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        border: OutlineInputBorder(),
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
                    width: 170,
                    padding: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3),
                        borderRadius: BorderRadius.circular(5)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: Text("Select Year"),
                        isExpanded: true,
                        items: yearList.map((int value) {
                          return new DropdownMenuItem<String>(
                            value: value.toString(),
                            child: new Text(value.toString()),
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
                    width: 170,
                    padding: EdgeInsets.only(left: 5),
                    // margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3),
                        borderRadius: BorderRadius.circular(5)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: Text("Location"),
                        isExpanded: true,
                        items: locationList.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
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
                    width: 170,
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
                      ),
                      controller: nameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Name',
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 170,
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
                        fontSize: 16,
                      ),
                      controller: emailController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Email',
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        border: OutlineInputBorder(),
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
                    width: 170,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.length == 0) {
                          return ("Please fill up this field.");
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      controller: phoneController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Phone Number',
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 170,
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
                      ),
                      controller: dateController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Date',
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        border: OutlineInputBorder(),
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
                    width: width * 0.9,
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
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      controller: timeController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Time',
                        hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                        border: OutlineInputBorder(),
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
                width: width * 0.93,
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
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  controller: commentController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    isDense: true,
                    labelText: 'Enter the comment',
                    hintStyle: TextStyle(color: Color(0xffb8b8b8)),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 35, 0, 5),
                  width: width * 0.75,
                  child: RaisedButton(
                    color: Color(ExtraColors.DARK_BLUE),
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                      // side: BorderSide(color: Colors.black),
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
              SizedBox(
                height: 30,
              ),
            ]),
          ),
        ),
      ),
      floatingActionButton: new Column(
        mainAxisSize: MainAxisSize.min,
        children: new List.generate(imageList.length, (int index) {
          Widget child = new Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: new ScaleTransition(
              scale: new CurvedAnimation(
                parent: _controller,
                curve: new Interval(0.0, 1.0 - index / imageList.length / 2.0,
                    curve: Curves.easeOut),
              ),
              child: new FloatingActionButton(
                heroTag: null,
                backgroundColor: backgroundColor,
                mini: true,
                // child: new Icon(icons[index], color: foregroundColor),
                child: new Image.asset(
                  imageList[index],
                ),
                onPressed: () async {
                  if (index == 0) {
                    print("hello 0");
                    var url = "tel:$nearestStorePhn";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  } else if (index == 1) {
                    print("hello 1");
                    var whatsappUrl = "whatsapp://send?phone=$whatsAppNum";
                    await canLaunch(whatsappUrl)
                        ? launch(whatsappUrl)
                        : showAlert();
                  }
                },
              ),
            ),
          );
          return child;
        }).toList()
          ..add(
            new FloatingActionButton(
              backgroundColor: Color(ExtraColors.DARK_BLUE),
              heroTag: null,
              child: new AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget child) {
                  return new Transform(
                    transform: new Matrix4.rotationZ(
                        _controller.value * 0.5 * math.pi),
                    alignment: FractionalOffset.center,
                    child: new Icon(
                        _controller.isDismissed ? Icons.call : Icons.close),
                  );
                },
              ),
              onPressed: () {
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
            ),
          ),
      ),
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
              child: FlatButton(
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
  //     if (status == Rcode.SUCCESS_CODE) {
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
    showProgressBar();
    Map<String, String> header = {
      "Content-Type": "application/json",
    };
    await http
        .get("https://fasttrackemarat.com/feed/make-model.json",
            headers: header)
        .then((res) {
      hideProgressBar();
      int status = res.statusCode;
      if (status == Rcode.SUCCESS_CODE) {
        var result = json.decode(res.body);

        var values = result['data']["make"];

        makeModelList =
            values.map<MakeModel>((json) => MakeModel.fromJson(json)).toList();

        setState(() {});

        print(values);
      }
    });
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
      print(formattedTime);
    }
  }

  Future<void> getLocation() async {
    showProgressBar();
    Map<String, String> header = {
      "Content-Type": "application/json",
    };
    await http
        .get("https://fasttrackemarat.com/feed/brakes.json", headers: header)
        .then((res) {
      hideProgressBar();
      int status = res.statusCode;
      if (status == Rcode.SUCCESS_CODE) {
        var result = json.decode(res.body);
        var values = result['data'];
        setState(() {
          locationList = List<String>.from(values['location']);
        });
        print(values);
      }
    });
  }

  Future<void> displaySnackbar(BuildContext context, msg) {
    final snackBar = SnackBar(
      content: Text('$msg'),
      duration: const Duration(seconds: 2),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
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
      print(body);
      if (res.statusCode == Rcode.SUCCESS_CODE) {
        print(res.body);
        displaySnackbar(context, "Inquiry submitted successfully");
        setState(() {
          dateController.text = "";
          timeController.text = "";
          nameController.text = "";
          emailController.text = "";
          phoneController.text = "";
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
    final prefs = await SharedPreferences.getInstance();
    String customerName, customerNumber, customerEmail;
    setState(() async {
      nearestStorePhn = await prefs.getString(Constants.NEAREST_STORE_PHONENO);
      whatsAppNum = await prefs.getString(Constants.WHATS_APP_NUMBER);
      customerName = await prefs.getString(Constants.CUSTOMER_NAME);
      customerNumber = await prefs.get(Constants.CUSTOMER_MOBILE_NO);
      customerEmail = await prefs.getString(Constants.CUSTOMER_EMAIL);

      nameController.text = customerName;
      phoneController.text = customerNumber;
      emailController.text = customerEmail;
    });
  }
}