import 'dart:convert' show json;
import 'dart:io' show File;
import 'dart:ui';
import 'package:dio/dio.dart' show Dio, FormData, MultipartFile, Response;
import 'package:flutter/material.dart' show AlertDialog, BuildContext, Colors, Column, Container, CrossAxisAlignment, DropdownButtonFormField, DropdownMenuItem, EdgeInsets, ElevatedButton, FontWeight, Form, FormState, GlobalKey, Icon, Icons, InputDecoration, Key, ListView, Navigator, OutlineInputBorder, Padding, Radio, Row, Scaffold, ScaffoldMessenger, SizedBox, SnackBar, State, StatefulWidget, Text, TextButton, TextEditingController, TextFormField, TextOverflow, TextStyle, Widget, showDatePicker, showDialog;
import 'package:file_picker/file_picker.dart' show FilePicker, FilePickerResult, FileType;
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
import 'package:intl/intl.dart' show DateFormat;
import 'package:http/http.dart' as http;

class MyForm extends StatefulWidget {
  const MyForm({Key? key}) : super(key: key);

  @override
  State<MyForm> createState() => MyFormState();
}

class MyFormState extends State<MyForm> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  File? _selectedFile;

//validate name
bool validateName(String? name) {
  final RegExp regex = RegExp(r'^[a-zA-Z ]+$');
  return regex.hasMatch(name!) && name.trim().isNotEmpty;
}
  // date pickers
Future<void> selectDate(BuildContext context, bool isFromDate) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now().subtract(const Duration(days: 365 * 1)),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    selectableDayPredicate: (DateTime date) {
      if (_selectedLeaveType == 'Earned Leave' || _selectedLeaveType == 'Casual Leave') {
        return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      } else {
        return true;
      }
    },
  );

  if (pickedDate != null) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    if (isFromDate) {
      setState(() {
        _fromDateController.text = formatter.format(pickedDate);
      });
    } else {
      final DateTime fromDate = formatter.parse(_fromDateController.text);
      if (pickedDate.isBefore(fromDate)) {
        Fluttertoast.showToast(
          msg: 'Please select a valid to date!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        setState(() {
          _toDateController.text = formatter.format(pickedDate);
        });
      }
    }
  }
}

// upload file
Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png']
    );

    if (result != null && result.paths.isNotEmpty) {
      String? path = result.paths.first;
      _selectedFile = File(path!);
    } else {
      Fluttertoast.showToast(
          msg: 'Select a File',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
      );
    }
  }


//clear form
  void clearForm() {
    _fullNameController.clear();
    _fromDateController.clear();
    _toDateController.clear();
    _selectedFile = null;
    _selectedLeaveType = null;
    _selectedReportingManager = null;
    _selectedTeamNames = null;
  }


// send data
Future<void> submitForm() async {
  if (_formKey.currentState!.validate()) {
    if (_selectedLeaveType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a leave type')),
        );
        return;
      }

      if (_selectedTeamNames == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a team name')),
        );
        return;
      }

      if (_selectedReportingManager == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a reporting manager')),
        );
        return;
      }

    if (_selectedLeaveType == 'Sick Leave' && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please Upload a File')),
      );
      return;
    }

    FormData data = FormData.fromMap({
      'name': _fullNameController.text.trim(),
      'fromDate': _fromDateController.text,
      'toDate': _toDateController.text,
      'leaveType': _selectedLeaveType.toString(),
      'team': _selectedTeamNames.toString(),
      'reporter': _selectedReportingManager.toString(),
    });

    if (_selectedFile != null) {
      data.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          _selectedFile!.path,
          filename: _selectedFile!.path.split('/').last,
        ),
      ));
    }

    const url = 'http://10.0.50.56:8080/postleave';
    Dio dio = Dio();
    try {
      Response response = await dio.post(
        url,
        data: data,
      );
      if (response.statusCode != 201) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Failed!'),
              content:const  Text('Failed! Try Again?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        _formKey.currentState!.reset();
          // ignore: use_build_context_synchronously
          showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content:const  Text('Leave Applied Successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        clearForm();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Failed'),
              content:const  Text('Something went wrong!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
    }
  }
}

// feth leave types
  Future<List<String>> fetchLeaveTypes() async {
    final response =
        await http.get(Uri.parse('http://10.0.50.56:8080/leaveTypes'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('leaveTypes')) {
        final List<dynamic> leaveTypeList = data['leaveTypes'];
        return leaveTypeList.map((type) => type.toString()).toList();
      } else {
        throw Exception('Invalid response format: Missing "leaveTypes" key');
      }
    } else {
      throw Exception('Failed to fetch leave types');
    }
  }
//fetch team names
  Future<List<String>> fetchTeamNames() async {
    final response =
        await http.get(Uri.parse('http://10.0.50.56:8080/teamNames'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('teamNames')) {
        final List<dynamic> leaveTypeList = data['teamNames'];
        return leaveTypeList.map((type) => type.toString()).toList();
      } else {
        throw Exception('Invalid response format: Missing "teamNames" key');
      }
    } else {
      throw Exception('Failed to fetch team names');
    }
  }

  List<String> leaveTypes = [];
  List<String> teamNames = [];
  String? _selectedLeaveType;
  String? _selectedTeamNames;
  String? _selectedReportingManager;

  List<String> reportingManagers = [
    'Surya Kant',
    'Pradeep Kumar Bharti',
    'Avinashi Sharma',
    'Nitin Aggarwal',
  ];

  @override
  void initState() {
    super.initState();
    fetchLeaveTypes().then((response) {
      setState(() {
        leaveTypes = response;
      });
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: "Failed to fetch leave",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });

    fetchTeamNames().then((response) {
      setState(() {
        teamNames = response;
      });
    }).catchError((error) {
      Fluttertoast.showToast(
        msg:"Failed to fetch team names",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: ListView(children: <Widget>[
              const SizedBox(
                child: Text(
                  'Fill Leave Details',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                      color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16.0,),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.person, color: Colors.black),
                  label: Text('Full Name'),
                  
                ),
                validator: (value) {
                  if (!validateName(value)) {
                    return 'Please Enter Your Name';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const Row(
                  children: [
                    Icon(Icons.work_off),
                    SizedBox(width: 16.0),
                    Text(
                      'Leave Type',
                      style: TextStyle(fontSize: 16),
                    ),
                    
                  ],
                ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Column(
                      children: leaveTypes.map((String type) {
                        return Row(
                          children: [
                            Radio<String>(
                              value: type,
                              groupValue: _selectedLeaveType,
                              onChanged: (String? value) {
                                setState(() {
                                    _selectedLeaveType = value;
                                });
                              },
                            ),
                            Text(type),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                TextFormField(
                  controller: _fromDateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.date_range, color: Colors.black),
                    labelText: 'From Date',
                  ),
                  readOnly: true,
                  onTap: () {
                    selectDate(context, true);
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the from date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _toDateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.date_range, color: Colors.black),
                    labelText: 'To Date',
                  ),
                  readOnly: true,
                  onTap: () {
                    selectDate(context, false);
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the to date';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(
                  height: 16.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.group),
                        SizedBox(width: 16.0),
                        Text(
                          'Team Names',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Column(
                        children: teamNames.map((String name) {
                          return Row(
                            children: [
                              Radio<String>(
                                value: name,
                                groupValue: _selectedTeamNames,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedTeamNames = value;
                                  });
                                },
                              ),
                              Text(name),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: reportingManagers.isNotEmpty
                          ? reportingManagers[0]
                          : '',
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedReportingManager = newValue;
                        });
                      },
                      items: reportingManagers
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Reporting Manager',
                        labelStyle: TextStyle(fontSize: 20),
                        icon: Icon(Icons.person_2,color: Colors.black,),
                      ),
                    ),
                    
                    const SizedBox(
                      height: 16.0,
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedLeaveType == 'Sick Leave') {
                        uploadFile();
                      } else if (_selectedLeaveType == 'Casual Leave' || _selectedLeaveType == 'Earned Leave') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File upload is not required for Casual Leave and Earned Leave'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedLeaveType == 'Sick Leave' ? Colors.orangeAccent : Colors.grey,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('Select File'),
                        if (_selectedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              _selectedFile!.path.split('/').last,
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          textStyle: const TextStyle(fontSize: 18)),
                      onPressed: submitForm,
                      child: const Text('Submit'),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ]),
            ]),
          ),
        ),
    );
  }
}
