import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Provider/lessons_learned_provider.dart';
import 'package:woodproposals/Provider/project_provider.dart';
import 'package:woodproposals/Utilities/globalvariables.dart';
import 'package:woodproposals/Utilities/Excel/excel_functions.dart';
import 'package:woodproposals/Widgets/widgets.dart';

class LessonsLearnedGridSide extends StatefulWidget {
  const LessonsLearnedGridSide({super.key});

  @override
  State<LessonsLearnedGridSide> createState() => _LessonsLearnedGridSideState();
}

class _LessonsLearnedGridSideState extends State<LessonsLearnedGridSide> {

  @override
  void dispose() {
    // Cancel any ongoing operations in the provider
    final lessonsLearnedProvider = Provider.of<LessonsLearnedProvider>(context, listen: false);
    lessonsLearnedProvider.cancelOperations();
    super.dispose();
  }

  /// -------------------------------------------------------------------------------------
  /// Extract Lessons Learned into Excel
  void _extractLessonsLearnedIntoExcel() async {
    final lessonsLearnedProvider = Provider.of<LessonsLearnedProvider>(context, listen: false);
    final projectProvider = Provider.of<Projectprovider>(context, listen: false);
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);

    final selectedProject = projectProvider.selectedProject;
    
    if (selectedProject == null) {
      snackbar(context: context, header: 'Please select a project before extracting lessons.');
      return;
    }

    try {
      // Filter lessons for the selected project
      final allLessons = lessonsLearnedProvider.lessonsLearned;
      final projectLessons = allLessons.where((lesson) => 
        lesson['projectID'] == selectedProject['fld_ID']
      ).toList();

      if (projectLessons.isEmpty) {
        snackbar(context: context, header: 'No lessons learned found for the selected project.');
        return;
      }

      // Show loading state
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const AlertDialog(
            title: Text('Exporting Lessons Learned'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Preparing Excel file...'),
                SizedBox(height: 8),
                Text('Please wait a moment.'),
              ],
            ),
          );
        },
      );

      // Export the lessons to Excel
      await ExcelFunctions.populateAndExportLessonsLearnedTemplate(
        lessonsLearned: projectLessons,
        llTypes: formStatusProvider.llTypes,
        selectedProject: selectedProject,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        snackbar(
          context: context, 
          header: 'Successfully exported ${projectLessons.length} lessons learned for ${selectedProject['fld_ProjectNo']}.'
        );
      }
    } catch (e) {
      // Close loading dialog on error
      if (context.mounted) {
        Navigator.of(context).pop();
        snackbar(context: context, header: 'Export failed: ${e.toString()}');
      }
    }
  }

  /// -------------------------------------------------------------------------------------
  /// Generate Lessons Learned Template
  void _generateLessonsLearnedTemplate() async {
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);
    try {
      // Extract the string values from the list of type maps.
      final List<String> lessonTypes = formStatusProvider.llTypes
          .map((typeMap) => typeMap['type'].toString())
          .toList();

      await ExcelFunctions.generateLessonsLearnedTemplate(lessonTypes: lessonTypes);
      snackbar(context: context, header: 'Template downloaded successfully.');
    } catch (e) {
      snackbar(context: context, header: 'Error generating template: ${e.toString()}');
    }
  }

  /// -------------------------------------------------------------------------------------
  /// Upload Lessons Learned
  void _uploadLessonsLearned() async {
    final lessonsLearnedProvider = Provider.of<LessonsLearnedProvider>(context, listen: false);
    final projectProvider = Provider.of<Projectprovider>(context, listen: false);
    final applicationInfo = Provider.of<AppInfo>(context, listen: false);
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);

    if (projectProvider.selectedProject == null) {
      snackbar(context: context, header: 'Please select a project before uploading.');
      return;
    }

    try {
      // The await here can create an async gap.
      final List<Map<String, dynamic>>? lessons = await ExcelFunctions.uploadLessonsLearnedFromTemplate(
        llTypes: formStatusProvider.llTypes,
      );

      // After an await, always check if the widget is still mounted before using its context.
      if (!context.mounted) return;

      if (lessons != null && lessons.isNotEmpty) {
        // Create a ValueNotifier to track progress
        ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);
        
        // Show loading dialog to prevent navigation during upload
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Uploading Lessons Learned'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<int>(
                    valueListenable: progressNotifier,
                    builder: (context, progress, child) {
                      return Text('Uploading lesson $progress of ${lessons.length}...');
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('Please do not navigate away.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    lessonsLearnedProvider.cancelOperations();
                    Navigator.of(dialogContext).pop();
                    snackbar(context: context, header: 'Upload cancelled.');
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );

        try {
          await lessonsLearnedProvider.addBulkLessonsLearnedWithProgress(
            lessons,
            projectProvider,
            applicationInfo,
            context,
            onProgress: (current, total) {
              progressNotifier.value = current;
            },
          );
          
          // Close loading dialog
          if (context.mounted) {
            Navigator.of(context).pop();
            snackbar(context: context, header: 'Successfully uploaded ${lessons.length} lessons.');
          }
        } catch (e) {
          // Close loading dialog on error
          if (context.mounted) {
            Navigator.of(context).pop();
            snackbar(context: context, header: 'Upload failed: ${e.toString()}');
          }
        } finally {
          progressNotifier.dispose();
        }
      } else if (lessons != null) {
        snackbar(context: context, header: 'No valid data rows found in the selected file.');
      }
    } catch (e) {
      if (!context.mounted) return;
      snackbar(context: context, header: 'Upload failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);
    final projectProvider = Provider.of<Projectprovider>(context, listen: false);
    return Column(
      children: [
        const SizedBox(height: 15),
        header3(header: 'MENU:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
        const SizedBox(height: 5),
        Divider(color: localAppTheme['anchorColors']['secondaryColor']),
        Visibility(
          visible: true, //TO DO: Implement visibility logic
          child: ListTile(
            leading: Icon(Icons.edit_document, color: localAppTheme['anchorColors']['secondaryColor']),
            title: body(header: 'GENERATE UPLOAD TEMPLATE:', color: localAppTheme['anchorColors']['secondaryColor'], context: context),
            onTap: () {
              _generateLessonsLearnedTemplate();
            },
          ),
        ),
        Visibility(
          visible: projectProvider.selectedProject != null, //TO DO: Implement visibility logic
          child: ListTile(
            leading: Icon(Icons.upload_file, color: localAppTheme['anchorColors']['secondaryColor']),
            title: body(header: 'UPLOAD LESSONS LEARNED:', color: localAppTheme['anchorColors']['secondaryColor'], context: context),
            onTap: () {
              _uploadLessonsLearned();
            },
          ),
        ),
        Visibility(
          visible: projectProvider.selectedProject != null, //TO DO: Implement visibility logic
          child: ListTile(
            leading: Icon(Icons.download, color: localAppTheme['anchorColors']['secondaryColor']),
            title: body(header: 'DOWNLOAD LESSONS LEARNED:', color: localAppTheme['anchorColors']['secondaryColor'], context: context),
            onTap: () {
              _extractLessonsLearnedIntoExcel();
            },
          ),
        ),
        Expanded(child: SizedBox()),
        //Sidebar Footer
        Divider(color: localAppTheme['anchorColors']['secondaryColor']),
        ListTile(
          leading: Icon(Icons.logout, color: localAppTheme['anchorColors']['secondaryColor']),
          title: Center(child: body(header: 'BACK TO PREVIOUS:', color: localAppTheme['anchorColors']['secondaryColor'], context: context)),
          onTap: () {
            formStatusProvider.setDisplayWidget('landingPage');
          },
        ),
        SizedBox(height: 7)
      ],
    );
  }
}