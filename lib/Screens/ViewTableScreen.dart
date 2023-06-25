import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:form_app/Screens/FileViewerScreen.dart';

class ViewTablePage extends StatefulWidget {
  const ViewTablePage({Key? key}) : super(key: key);

  @override
  _ViewTablePageState createState() => _ViewTablePageState();
}

class _ViewTablePageState extends State<ViewTablePage> {
  List<Map<String, dynamic>> leaveData = [];

  @override
  void initState() {
    super.initState();
    fetchLeaveData();
  }

  void openPdfViewer(String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
      ),
    );
  }

  Future<void> fetchLeaveData() async {
    try {
      const url = 'http://192.168.0.94:8080/getleave';
      Dio dio = Dio();
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        setState(() {
          leaveData = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch leave data',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              // DataColumn(
              //   label: Text('Serial No'),
              // ),
              DataColumn(
                label: Text('Name'),
              ),
              DataColumn(
                label: Text('From Date'),
              ),
              DataColumn(
                label: Text('To Date'),
              ),
              DataColumn(
                label: Text('Leave Type'),
              ),
              DataColumn(
                label: Text('Team'),
              ),
              DataColumn(
                label: Text('Attachment'),
              ),
              DataColumn(
                label: Text('Reporter'),
              ),
            ],
            rows: leaveData.map((data) {
              return DataRow(cells: [
                //DataCell(Text(data['id']??'')),
                DataCell(Text(data['name'] ?? '')),
                DataCell(Text(data['fromDate'] ?? '')),
                DataCell(Text(data['toDate'] ?? '')),
                DataCell(Text(data['leaveType'] ?? '')),
                DataCell(Text(data['team'] ?? '')),
                DataCell(GestureDetector(
                  child: Text(
                    data['filePath'] ?? '',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  onTap: () {
                    if (data['filePath'] != null) {
                      if (data['filePath'].toLowerCase().endsWith('.pdf')) {
                        String pdfUrl = 'http://192.168.0.94:8080/file/${data['filePath']}';
                        openPdfViewer(pdfUrl);
                      } else if (data['filePath'].toLowerCase().endsWith('.png')) {
                        final imageProvider = Image.network('http://192.168.0.94:8080/file/${data['filePath']}').image;
                        showImageViewer(context, imageProvider, onViewerDismissed: () {
                          print("dismissed");
                        });
                      }
                    }
                  },
                )),
                DataCell(Text(data['reporter'] ?? '')),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}