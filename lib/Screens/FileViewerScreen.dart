import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String fileName;

  const PdfViewerScreen({required this.pdfUrl,required this.fileName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName)
      ),
      body: SfPdfViewer.network(pdfUrl,
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
      print(details.document.pages.count);
      },
    ),
    );
  }
}
