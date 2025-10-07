import 'package:excel/excel.dart';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ExcelFunctions {
  
  /// -------------------------------------------------------------------------------------
  /// Generates a template for Lessons Learned in Excel format.
  static Future<void> generateLessonsLearnedTemplate({
    required List<String> lessonTypes,
  }) async {
    try {
      var excel = Excel.createExcel();

      // --- 1. Create and populate the Instructions Sheet ---
      Sheet instructionsSheet = excel['Instructions'];
      excel.setDefaultSheet(instructionsSheet.sheetName);

      // Add content to the instructions sheet
      instructionsSheet.appendRow([TextCellValue('How to Use This Template')]);
      instructionsSheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('B1'));

      instructionsSheet.appendRow([]); // Spacer row
      instructionsSheet.appendRow([TextCellValue('General Instructions:')]);
      instructionsSheet.appendRow([TextCellValue("• Please fill out the required data in the 'LessonsLearned' sheet.")]);
      instructionsSheet.appendRow([TextCellValue('• Do not change, rename, or remove the column headers.')]);
      instructionsSheet.appendRow([TextCellValue('• Each row represents a single Lesson Learned item.')]);

      instructionsSheet.appendRow([]); // Spacer row
      instructionsSheet.appendRow([TextCellValue('Column Guide:')]);
      instructionsSheet.appendRow([TextCellValue('Lesson Title'), TextCellValue('A concise, descriptive title for the lesson.')]);
      instructionsSheet.appendRow([TextCellValue('Event'), TextCellValue('A detailed description of the situation or event that occurred.')]);
      instructionsSheet.appendRow([TextCellValue('Type'), TextCellValue('The category of the lesson. You must use one of the following exact values:')]);
      // List the valid types
      for (var type in lessonTypes) {
        instructionsSheet.appendRow([TextCellValue(''), TextCellValue('  - $type')]);
      }
      instructionsSheet.appendRow([TextCellValue('Outcome'), TextCellValue('The result or impact of the event.')]);
      instructionsSheet.appendRow([TextCellValue('What is the Learning'), TextCellValue('The key takeaway or recommendation to be applied in the future.')]);
      instructionsSheet.appendRow([TextCellValue('Cost Savings'), TextCellValue('The estimated cost savings. Enter as a number (e.g., 15000) or "0" if not applicable.')]);

      // Note: The excel package does not support setting column widths directly.
      // Column widths will use default sizing in the generated Excel file.

      // --- 2. Create the LessonsLearned data sheet ---
      Sheet lessonsSheet = excel['LessonsLearned'];
      excel.delete('Sheet1'); // Remove the default sheet.

      List<String> headers = [
        'Lesson Title',
        'Event',
        'Type',
        'Outcome',
        'What is the Learning',
        'Cost Savings'
      ];
      lessonsSheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

      // Auto-fit columns for the data sheet as well
      // Note: The excel package does not support auto-fitting columns directly.
      // Columns will use default sizing in the generated Excel file.
      // --- 3. Save and Download the File ---
      final List<int>? fileBytes = excel.save();

      if (fileBytes != null) {
        final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", "Lessons_Learned_Template.xlsx")
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      //print('Error generating Excel template: $e');
      rethrow;
    }
  }

  /// -------------------------------------------------------------------------------------
  /// Uploads Lessons Learned data from an Excel template.
  static Future<List<Map<String, dynamic>>?> uploadLessonsLearnedFromTemplate({
    required List<Map<String, dynamic>> llTypes,
  }) async {
    // 1. Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) {
      // User cancelled the picker or file is empty
      return null;
    }

    // 2. Decode the file bytes into an Excel object
    var bytes = result.files.single.bytes!;
    var excel = Excel.decodeBytes(bytes);

    // 3. Find the correct sheet and validate headers
    if (!excel.tables.keys.contains('LessonsLearned')) {
      throw Exception("The template is invalid. Missing 'LessonsLearned' sheet.");
    }
    Sheet sheet = excel['LessonsLearned'];
    if (sheet.maxRows < 2) {
      // No data rows found
      return [];
    }

    List<Map<String, dynamic>> lessons = [];
    final typeMap = {for (var item in llTypes) item['type'].toString().toLowerCase(): item['typeID']};

    // 4. Iterate over rows and parse data (skip header row at index 0)
    for (var i = 1; i < sheet.maxRows; i++) {
      var row = sheet.row(i);

      // Helper to safely get cell value as string
      String? getCellValue(int col) => row[col]?.value?.toString().trim();

      final title = getCellValue(0);
      final event = getCellValue(1);
      final typeString = getCellValue(2)?.toLowerCase();
      final outcome = getCellValue(3);
      final learning = getCellValue(4);

      // Basic validation: ensure required fields are not empty
      if (title == null || title.isEmpty || event == null || event.isEmpty || typeString == null || typeString.isEmpty) {
        debugPrint('Skipping row ${i + 1} due to missing required data.');
        continue; // Skip incomplete rows
      }

      if (!typeMap.containsKey(typeString)) {
        debugPrint('Skipping row ${i + 1} due to invalid type: "${getCellValue(2)}".');
        continue; // Skip rows with an invalid type
      }

      lessons.add({
        'lessonTitle': title,
        'event': event,
        'type': typeMap[typeString],
        'outcome': outcome ?? '',
        'whatIsTheLearning': learning ?? '',
        'costSavings': getCellValue(5) ?? '0',
      });
    }
    return lessons;
  }
}