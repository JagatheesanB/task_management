// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';
// import 'package:task_management/tasks/domain/models/completed.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// class PDFGenerator extends ConsumerStatefulWidget {
//   final List<CompletedTask> completedTasks;
//   const PDFGenerator({Key? key, required this.completedTasks})
//       : super(key: key);
//   @override
//   ConsumerState createState() => _PDFGeneratorState();
// }
// class _PDFGeneratorState extends ConsumerState<PDFGenerator> {
//   late pw.Document pdf;
//   late File pdfFile;
//   @override
//   void initState() {
//     super.initState();
//     generatePDF();
//   }
//   Future<void> generatePDF() async {
//     pdf = pw.Document();
//     pdf.addPage(
//       pw.MultiPage(
//         margin: const pw.EdgeInsets.all(20.0),
//         build: (context) => [
//           pw.Header(
//             level: 0,
//             child: pw.Container(
//               margin: const pw.EdgeInsets.only(bottom: 20.0),
//               child: pw.Text(
//                 'Task Reports',
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 30,
//                   color: PdfColors.blue,
//                 ),
//               ),
//             ),
//           ),
//           pw.ListView.builder(
//             itemCount: widget.completedTasks.length,
//             itemBuilder: (context, index) {
//               final completedTask = widget.completedTasks[index];
//               String displayTime =
//                   '${(completedTask.seconds ~/ 3600).toString().padLeft(2, '0')}'
//                   ':${((completedTask.seconds ~/ 60) % 60).toString().padLeft(2, '0')}'
//                   ':${(completedTask.seconds % 60).toString().padLeft(2, '0')}';
//               return pw.Container(
//                 margin: const pw.EdgeInsets.symmetric(vertical: 10.0),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       completedTask.task.taskName,
//                       style: pw.TextStyle(
//                         fontWeight: pw.FontWeight.bold,
//                         fontSize: 24,
//                       ),
//                     ),
//                     pw.SizedBox(height: 10),
//                     pw.Text(
//                       'Time Spent: $displayTime',
//                       style: const pw.TextStyle(
//                         fontSize: 18.0,
//                         color: PdfColors.grey,
//                       ),
//                     ),
//                     pw.Divider(
//                       thickness: 1.0,
//                       color: PdfColors.grey,
//                       height: 20.0,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//     // Save the PDF to a file
//     final output = await getTemporaryDirectory();
//     pdfFile = File('${output.path}/Completed_Tasks.pdf');
//     await pdfFile.writeAsBytes(await pdf.save());
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context)!.generatePDF,
//           style: const TextStyle(
//               fontFamily: 'Poppins', fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PDFDisplayPage(pdfFile: pdfFile),
//               ),
//             );
//           },
//           style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.shade700,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               )),
//           child: Text(
//             AppLocalizations.of(context)!.generatePDF,
//             style: const TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class PDFDisplayPage extends StatelessWidget {
//   final File pdfFile;
//   const PDFDisplayPage({Key? key, required this.pdfFile}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context)!.sharePDF,
//           style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () async {
//               final bytes = await pdfFile.readAsBytes();
//               final tempDir = await getTemporaryDirectory();
//               final tempFilePath = '${tempDir.path}/Completed_Task.pdf';
//               final tempPdfFile = File(tempFilePath);
//               await tempPdfFile.writeAsBytes(bytes);
//               await Share.shareXFiles(
//                 [XFile(tempFilePath)],
//                 text: 'Share PDF',
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: PDFView(filePath: pdfFile.path),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:excel/excel.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';

// import 'package:task_management/tasks/domain/models/completed.dart';
// // import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class ExcelGenerator extends ConsumerStatefulWidget {
//   final List<CompletedTask> completedTasks;

//   const ExcelGenerator({Key? key, required this.completedTasks})
//       : super(key: key);

//   @override
//   ConsumerState createState() => _ExcelGeneratorState();
// }

// class _ExcelGeneratorState extends ConsumerState<ExcelGenerator> {
//   late File excelFile;

//   @override
//   void initState() {
//     super.initState();
//     generateExcel();
//   }

//   Future<void> generateExcel() async {
//     var excel = Excel.createExcel();
//     var sheet = excel['CompletedTasks'];

//     // Adding header row
//     sheet.appendRow(['Task Name','Time Spent']);

//     for (var completedTask in widget.completedTasks) {
//       String displayTime =
//           '${(completedTask.seconds ~/ 3600).toString().padLeft(2, '0')}:'
//           '${((completedTask.seconds ~/ 60) % 60).toString().padLeft(2, '0')}:'
//           '${(completedTask.seconds % 60).toString().padLeft(2, '0')}';
//       sheet.appendRow([completedTask.task.taskName.toUpperCase(),displayTime]);
//     }

//     // Save the Excel to a file
//     final output = await getTemporaryDirectory();
//     excelFile = File('${output.path}/Completed_Tasks.xlsx');
//     excelFile.writeAsBytesSync(excel.save()!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Generate Excel",
//           // AppLocalizations.of(context)!.generateExcel,
//           style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ExcelDisplayPage(excelFile: excelFile),
//               ),
//             );
//           },
//           style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.purple,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               )),
//           child: const Text(
//             "Generate Excel",
//             // AppLocalizations.of(context)!.generateExcel,
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ExcelDisplayPage extends StatelessWidget {
//   final File excelFile;

//   const ExcelDisplayPage({Key? key, required this.excelFile}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Share Excel",
//           // AppLocalizations.of(context)!.shareExcel,
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () async {
//               final bytes = await excelFile.readAsBytes();
//               final tempDir = await getTemporaryDirectory();
//               final tempFilePath = '${tempDir.path}/Completed_Tasks.xlsx';
//               final tempExcelFile = File(tempFilePath);
//               await tempExcelFile.writeAsBytes(bytes);
//               await Share.shareXFiles(
//                 [XFile(tempFilePath)],
//                 text: 'Share Excel',
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             final bytes = await excelFile.readAsBytes();
//             final tempDir = await getTemporaryDirectory();
//             final tempFilePath = '${tempDir.path}/Completed_Tasks.xlsx';
//             final tempExcelFile = File(tempFilePath);
//             await tempExcelFile.writeAsBytes(bytes);
//             await Share.shareXFiles(
//               [XFile(tempFilePath)],
//               text: 'Share Excel',
//             );
//           },
//           style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.purple,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               )),
//           child: const Text(
//             "Share Excel",
//             // AppLocalizations.of(context)!.shareExcel,
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_management/tasks/domain/models/completed.dart';

class ExcelGenerator extends ConsumerStatefulWidget {
  final List<CompletedTask> completedTasks;

  const ExcelGenerator({Key? key, required this.completedTasks})
      : super(key: key);

  @override
  ConsumerState createState() => _ExcelGeneratorState();
}

class _ExcelGeneratorState extends ConsumerState<ExcelGenerator> {
  late File excelFile;

  @override
  void initState() {
    super.initState();
    generateExcel();
  }

  String _getDisplayTime(String taskHours) {
    int totalMinutes = int.parse(taskHours);
    if (totalMinutes >= 60) {
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;
      return '$hours H $minutes M';
    } else {
      return '$totalMinutes M';
    }
  }

  Future<void> generateExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['CompletedTasks'];

    // Adding header row
    sheet.appendRow(['Task Name', 'Time Spent']);

    for (var completedTask in widget.completedTasks) {
      String displayTime = _getDisplayTime(completedTask.seconds.toString());
      sheet.appendRow([completedTask.task.taskName.toUpperCase(), displayTime]);
    }

    // Save the Excel to a file
    final output = await getTemporaryDirectory();
    excelFile = File('${output.path}/Completed_Tasks.xlsx');
    excelFile.writeAsBytesSync(excel.save()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.generateExcel,
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExcelDisplayPage(excelFile: excelFile),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          child: Text(
            AppLocalizations.of(context)!.generateExcel,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ExcelDisplayPage extends StatelessWidget {
  final File excelFile;

  const ExcelDisplayPage({Key? key, required this.excelFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.excelPreview,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final bytes = await excelFile.readAsBytes();
              final tempDir = await getTemporaryDirectory();
              final tempFilePath = '${tempDir.path}/Completed_Tasks.xlsx';
              final tempExcelFile = File(tempFilePath);
              await tempExcelFile.writeAsBytes(bytes);
              if (context.mounted) {
                await Share.shareXFiles(
                  [XFile(tempFilePath)],
                  text: AppLocalizations.of(context)!.shareExcel,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _readExcel(),
        builder: (context, AsyncSnapshot<List<List<String>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      // border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: _buildTableColumns(data[0]),
                        rows: _buildTableRows(data),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }

  Future<List<List<String>>> _readExcel() async {
    var bytes = await excelFile.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel['CompletedTasks'];
    List<List<String>> excelData = [];

    for (var row in sheet.rows) {
      excelData.add(row.map((cell) => cell!.value.toString()).toList());
    }

    return excelData;
  }

  List<DataColumn> _buildTableColumns(List<String> headers) {
    return headers.map((header) {
      String capitalizedHeader = header.toUpperCase();
      return DataColumn(
          label: Text(
        capitalizedHeader,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'poppins',
            color: Colors.purple),
      ));
    }).toList();
  }

  List<DataRow> _buildTableRows(List<List<String>> data) {
    return data
        .skip(1)
        .map((row) => DataRow(
            cells: row
                .map((cell) => DataCell(Text(
                      cell,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontFamily: 'poppins',
                      ),
                    )))
                .toList()))
        .toList();
  }
}
