import 'package:excel/excel.dart';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

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

  /// -------------------------------------------------------------------------------------
  /// Populates and exports the Lessons Learned template with current project data.
  static Future<void> populateAndExportLessonsLearnedTemplate({
    required List<Map<String, dynamic>> lessonsLearned,
    required List<Map<String, dynamic>> llTypes,
    required Map<String, dynamic>? selectedProject,
  }) async {
    try {
      // Create a new Excel file
      var excel = Excel.createExcel();
      
      // Remove the default Sheet1 first
      excel.delete('Sheet1');
      
      // Create the Instructions sheet first and set it as default
      Sheet instructionsSheet = excel['Instructions'];
      excel.setDefaultSheet('Instructions');
      
      // Populate the Instructions sheet
      instructionsSheet.appendRow([TextCellValue('PMG-FOR-110230 Lessons Learned Export')]);
      instructionsSheet.appendRow([]);
      instructionsSheet.appendRow([TextCellValue('Project Information:')]);
      instructionsSheet.appendRow([TextCellValue('Project Number:'), TextCellValue(selectedProject?['fld_ProjectNo']?.toString() ?? 'N/A')]);
      instructionsSheet.appendRow([TextCellValue('Project Title:'), TextCellValue(selectedProject?['fld_ProjectTitle']?.toString() ?? selectedProject?['fld_ProjectName']?.toString() ?? 'N/A')]);
      instructionsSheet.appendRow([TextCellValue('Export Date:'), TextCellValue(DateTime.now().toString().split(' ')[0])]);
      instructionsSheet.appendRow([TextCellValue('Total Lessons:'), TextCellValue(lessonsLearned.length.toString())]);
      instructionsSheet.appendRow([]);
      instructionsSheet.appendRow([TextCellValue('Notes:')]);
      instructionsSheet.appendRow([TextCellValue('• Data is populated in the "Lessons Capture Sheet" starting from row 11')]);
      instructionsSheet.appendRow([TextCellValue('• This file matches the PMG-FOR-110230 template structure')]);
      instructionsSheet.appendRow([TextCellValue('• Empty columns can be filled manually if additional data is available')]);
      
      // Now create the "Lessons Capture Sheet"
      Sheet sheet = excel['Lessons Capture Sheet'];
      
      // Add empty rows 1-9 to match your template structure
      for (int i = 0; i < 9; i++) {
        sheet.appendRow([]);
      }
      
      // Add headers at row 10 (index 9) - matching your template headers
      List<String> headers = [
        'Lesson Title',           // A
        'Date Raised',            // B  
        'Event',                  // C
        'Type',                   // D
        'Cost Savings',           // E
        'Outcome',                // F
        'what is the learning',   // G
        'Organisation level 1',   // H
        'Organisation level 2',   // I
        'Organisation level 3',   // J
        'Organisation level 4',   // K
        'Organisation level 5',   // L
        'Organisation level 6',   // M
        'Organisation level 7',   // N
        'Project Number',         // O
        'Project Title',          // P
        'Project Scope',          // Q
        'Project Phase',          // R
        'Function',               // S
        'Discipline'              // T
      ];
      
      sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
      
      // Create type lookup map for converting type IDs to names
      final typeMap = {for (var item in llTypes) item['typeID']: item['type'].toString()};
      
      // Populate data starting from row 11 (after headers)
      for (var lesson in lessonsLearned) {
        List<CellValue?> rowData = List.filled(20, null);
        
        // Column A: Lesson Title
        rowData[0] = TextCellValue(lesson['lessonTitle']?.toString() ?? '');
        
        // Column B: Date Raised
        rowData[1] = TextCellValue(lesson['dateRaised']?.toString().split('T')[0] ?? '');
        
        // Column C: Event
        rowData[2] = TextCellValue(lesson['event']?.toString() ?? '');
        
        // Column D: Type (convert from ID to readable text)
        rowData[3] = TextCellValue(typeMap[lesson['type']] ?? 'Unknown');
        
        // Column E: Cost Savings
        rowData[4] = TextCellValue(lesson['costSavings']?.toString() ?? '0');
        
        // Column F: Outcome
        rowData[5] = TextCellValue(lesson['outcome']?.toString() ?? '');
        
        // Column G: What is the Learning
        rowData[6] = TextCellValue(lesson['whatIsTheLearning']?.toString() ?? '');
        
        // Columns H-N: Organisation levels 1-7 (leave empty for now)
        // These would need to be mapped from your data structure if available
        
        // Column O: Project Number
        rowData[14] = TextCellValue(selectedProject?['fld_ProjectNo']?.toString() ?? '');
        
        // Column P: Project Title
        rowData[15] = TextCellValue(selectedProject?['fld_ProjectTitle']?.toString() ?? selectedProject?['fld_ProjectName']?.toString() ?? '');
        
        // Columns Q-T: Project Scope, Project Phase, Function, Discipline (leave empty for now)
        // These would need additional data mapping
        
        // Filter out null values and add the row
        List<CellValue> finalRowData = [];
        for (int i = 0; i < rowData.length; i++) {
          if (rowData[i] != null) {
            finalRowData.add(rowData[i]!);
          } else {
            finalRowData.add(TextCellValue(''));
          }
        }
        
        sheet.appendRow(finalRowData);
      }
      
      // Save and download the file
      final List<int>? fileBytes = excel.save();
      
      if (fileBytes != null) {
        final projectNo = selectedProject?['fld_ProjectNo']?.toString() ?? 'Unknown';
        final timestamp = DateTime.now().toString().split(' ')[0];
        final fileName = 'PMG-FOR-110230_Export_${projectNo}_$timestamp.xlsx';
        
        final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      debugPrint('Error in populateAndExportLessonsLearnedTemplate: $e');
      rethrow;
    }
  }
}