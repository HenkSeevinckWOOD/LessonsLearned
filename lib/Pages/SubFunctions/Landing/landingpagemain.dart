import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodproposals/Provider/lessons_learned_provider.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Provider/project_provider.dart';
import 'package:woodproposals/Utilities/globalvariables.dart';
import 'package:woodproposals/Widgets/widgets.dart';

class LandingMain extends StatefulWidget {
  const LandingMain({super.key});

  State<LandingMain> createState() => _LandingMainState();
}

class _LandingMainState extends State<LandingMain> {
  late Future<void> _fetchDataFuture;
  final ScrollController _scrollController = ScrollController();

  // Controllers for the dialog
  late TextEditingController _titleController;
  late TextEditingController _eventController;
  late TextEditingController _outcomeController;
  late TextEditingController _whatIsTheLearningController;
  late TextEditingController _costSavingsController;

  /// -------------------------------------------------------------------------------------
  /// Initialize controllers and fetch data
  @override
  void initState() {
    super.initState();
    final applicationInfo = Provider.of<AppInfo>(context, listen: false);
    final projectProvider = Provider.of<Projectprovider>(context, listen: false);
    final lessonsLearnedProvider = Provider.of<LessonsLearnedProvider>(context, listen: false);

    _fetchDataFuture = fetchAppStartupInformation(applicationInfo, projectProvider, lessonsLearnedProvider);

    _titleController = TextEditingController();
    _eventController = TextEditingController();
    _outcomeController = TextEditingController();
    _whatIsTheLearningController = TextEditingController();
    _costSavingsController = TextEditingController();
  }

  /// -------------------------------------------------------------------------------------
  /// Dispose controllers
  @override
  void dispose() {
    _titleController.dispose();
    _eventController.dispose();
    _outcomeController.dispose();
    _whatIsTheLearningController.dispose();
    _costSavingsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// -------------------------------------------------------------------------------------
  /// Fetch application startup information
  Future<void> fetchAppStartupInformation(AppInfo applicationInfo, Projectprovider projectProvider, LessonsLearnedProvider lessonsLearnedProvider) async {
    // Fetch initial data in parallel without notifying listeners.
    // The FutureBuilder will handle the UI update after both futures complete.
    // Note: You must also add the {bool notify = true} parameter to your projectProvider.fetchProjects() method.
    await Future.wait([
      projectProvider.fetchProjects(notify: false),
      lessonsLearnedProvider.fetchLessonsLearned(notify: false),
    ]);
  }

  /// -------------------------------------------------------------------------------------
  /// Search Widget
  Widget _searchBar(BuildContext context) {
    final projectProvider = Provider.of<Projectprovider>(context, listen: true);
    final projects = projectProvider.projects.where((project) => project['fld_ProjectNo'] != null).toList();
    final localAppTheme = ResponsiveTheme(context).theme;
    final selectedProject = projectProvider.selectedProject;
    return SizedBox(
      width: 200,
      child: SearchableDropdown(
        labelText: 'SELECT PROJECT:',
        hint: 'SELECT PROJECT:',
        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
        searchBoxVisable: false,
        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
        dropDownList: projects,
        header: 'SELECT PROJECT:',
        iconColor: localAppTheme['anchorColors']['primaryColor'],
        idField: 'fld_ID',
        displayField: 'fld_ProjectNo',
        initialValue: selectedProject?['fld_ID'],
        onChanged: (value) {
          projectProvider.setCurrentProject(value);
        },
        isEnabled: selectedProject == null,
      ),
    );
  }

  /// -------------------------------------------------------------------------------------
  /// Unlock Project Selection
  void _unlockProjectSelection() {
    final projectProvider = Provider.of<Projectprovider>(context, listen: false);
    projectProvider.setCurrentProject(null);
  }

  /// -------------------------------------------------------------------------------------
  /// Context Window
  void _addEditLessonsLearnedContextWindow([Map<String, dynamic>? lesson]) {
    final lessonsLearnedProvider = Provider.of<LessonsLearnedProvider>(context, listen: false);
    final projectprovider = Provider.of<Projectprovider>(context, listen: false);
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);
    final applicationInfo = Provider.of<AppInfo>(context, listen: false);
    final llTypes = formStatusProvider.llTypes;
    final localAppTheme = ResponsiveTheme(context).theme;
    final formKey = GlobalKey<FormState>();
    Map<String, dynamic> newLessonsLearned = {};

    _titleController.text = lesson?['lessonTitle']?.toString() ?? '';
    _eventController.text = lesson?['event']?.toString() ?? '';
    _outcomeController.text = lesson?['outcome']?.toString() ?? '';
    _whatIsTheLearningController.text = lesson?['whatIsTheLearning']?.toString() ?? '';
    _costSavingsController.text = lesson?['costSavings']?.toString() ?? '';

    if (lesson != null) {
      newLessonsLearned['type'] = lesson['type'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lesson == null ? 'Add Lesson Learned' : 'Edit Lesson Learned'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // <-- Increase this value for wider dialog
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    formInputField(
                      controller: _titleController,
                      label: 'Lesson Title',
                      context: context,
                      isMultiline: false,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      initialValue: null,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a title.' : null,
                      onChanged: null,
                      errorMessage: '',
                    ),
                    const SizedBox(height: 10),
                    formInputField(
                      controller: _eventController,
                      label: 'Event',
                      context: context,
                      isMultiline: true,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      initialValue: null,
                      validator: (value) => value == null || value.isEmpty ? 'Please describe the event.' : null,
                      onChanged: null,
                      errorMessage: '',
                    ),
                    const SizedBox(height: 10),
                    SearchableDropdown(
                      labelText: 'Type',
                      hint: 'Type',
                      dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                      searchBoxVisable: false,
                      dropDownList: llTypes,
                      header: 'Type',
                      iconColor: localAppTheme['anchorColors']['primaryColor'],
                      idField: 'typeID',
                      validator: (value) {
                        if (newLessonsLearned['type'] == null) {
                          return 'Please select a type.';
                        }
                        return null;
                      },
                      displayField: 'type',
                      initialValue: lesson?['type'],
                      onChanged: (value) {
                        newLessonsLearned['type'] = value!['typeID'];
                      },
                      isEnabled: true,
                    ),
                    const SizedBox(height: 10),
                    formInputField(
                      controller: _outcomeController,
                      label: 'Outcome',
                      context: context,
                      isMultiline: true,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      initialValue: null,
                      validator: (value) => value == null || value.isEmpty ? 'Please describe the outcome.' : null,
                      onChanged: null,
                      errorMessage: '',
                    ),
                    const SizedBox(height: 10),
                    formInputField(
                      controller: _whatIsTheLearningController,
                      label: 'What is the Learning',
                      context: context,
                      isMultiline: true,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      initialValue: null,
                      validator: (value) => value == null || value.isEmpty ? 'Please describe the learning.' : null,
                      onChanged: null,
                      errorMessage: '',
                    ),
                    const SizedBox(height: 10),
                    formInputField(
                      controller: _costSavingsController,
                      label: 'Cost Savings',
                      context: context,
                      isMultiline: false,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      initialValue: null,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the cost savings.' : null,
                      onChanged: null,
                      errorMessage: '',
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // Validate the form
                final isFormValid = formKey.currentState?.validate() ?? false;

                if (isFormValid) {
                  if (lesson == null) {
                    // This is for adding a new lesson
                    newLessonsLearned['lessonTitle'] = _titleController.text;
                    newLessonsLearned['event'] = _eventController.text;
                    newLessonsLearned['outcome'] = _outcomeController.text;
                    newLessonsLearned['whatIsTheLearning'] = _whatIsTheLearningController.text;
                    newLessonsLearned['costSavings'] = _costSavingsController.text.isEmpty ? '\$0' : _costSavingsController.text;
                    newLessonsLearned['projectID'] = projectprovider.selectedProject?['fld_ID'];
                    newLessonsLearned['dateRaised'] = DateTime.now().toIso8601String();
                    try {
                      await lessonsLearnedProvider.addLessonsLearned(newLessonsLearned, projectprovider, applicationInfo);
                      snackbar(context: context, header: 'Lesson Learned Added Successfully');
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (e) {
                      snackbar(context: context, header: 'Failed to Add Lesson Learned: ${e.toString()}');
                    }
                  } else {
                    // This is for editing an existing lesson
                    newLessonsLearned['lessonID'] = lesson['lessonID'];
                    newLessonsLearned['lessonTitle'] = _titleController.text;
                    newLessonsLearned['event'] = _eventController.text;
                    newLessonsLearned['outcome'] = _outcomeController.text;
                    newLessonsLearned['whatIsTheLearning'] = _whatIsTheLearningController.text;
                    newLessonsLearned['costSavings'] = _costSavingsController.text.isEmpty ? '\$0' : _costSavingsController.text;
                    newLessonsLearned['projectID'] = lesson['projectID']; // Use existing projectID
                    newLessonsLearned['dateRaised'] = DateTime.now().toIso8601String();
                    try {
                      await lessonsLearnedProvider.editLessonsLearned(newLessonsLearned, projectprovider, applicationInfo);
                      if (!context.mounted) return;
                      snackbar(context: context, header: 'Lesson Learned Edited Successfully');
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (!context.mounted) return;
                      snackbar(context: context, header: 'Failed to Edit Lesson Learned: ${e.toString()}');
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );  
  }

  /// -------------------------------------------------------------------------------------
  /// Lessons Learned List View
  Widget _lessonsLearnedListView(BuildContext context) {
    final lessonsLearnedProvider = Provider.of<LessonsLearnedProvider>(context, listen: true);
    final applicationInfo = Provider.of<AppInfo>(context, listen: false);
    final projectProvider = Provider.of<Projectprovider>(context, listen: true);
    final lessonsLearned = lessonsLearnedProvider.lessonsLearned;
    final selectedProject = projectProvider.selectedProject;
    final projects = projectProvider.projects;
    final localAppTheme = ResponsiveTheme(context).theme;
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);
    final llTypes = formStatusProvider.llTypes;

    List<Map<String, dynamic>> filteredLessons;

    if (selectedProject != null) {
      filteredLessons = lessonsLearned.where((lesson) => lesson['projectID'] == selectedProject['fld_ID']).toList();
    } else {
      filteredLessons = List.from(lessonsLearned);
    }

    const double buttonsColWidth = 150;
    const double lessonTitleColWidth = 300;
    const double dateRaisedColWidth = 120;
    const double eventColWidth = 400;
    const double typeColWidth = 100;
    const double costSavingsColWidth = 120;
    const double outcomeColWidth = 400;
    const double whatIsTheLearningColWidth = 800;
    const double projectColWidth = 150;

    Widget buildHeaderCell(String title, double width) {
      return Container(width: width, height: 56, padding: const EdgeInsets.symmetric(horizontal: 16.0), alignment: Alignment.centerLeft, child: header3(header: title, color: localAppTheme['anchorColors']['primaryColor'], context: context));
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Container(
          color: localAppTheme['anchorColors']['secondaryColor'],
          width: lessonTitleColWidth + dateRaisedColWidth + eventColWidth + typeColWidth + costSavingsColWidth + outcomeColWidth + whatIsTheLearningColWidth + (selectedProject == null ? projectColWidth : 0) + (selectedProject != null ? buttonsColWidth : 0),
          child: Column(
            children: [
              // Header Row
              Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2))),
                child: Row(
                  children: [
                    if (selectedProject != null) buildHeaderCell('BUTTONS', buttonsColWidth),
                    if (selectedProject == null) buildHeaderCell('PROJECT', projectColWidth),
                    buildHeaderCell('LESSON TITLE', lessonTitleColWidth),
                    buildHeaderCell('DATE RAISED', dateRaisedColWidth),
                    buildHeaderCell('EVENT', eventColWidth),
                    buildHeaderCell('TYPE', typeColWidth),
                    buildHeaderCell('COST SAVINGS', costSavingsColWidth),
                    buildHeaderCell('OUTCOME', outcomeColWidth),
                    buildHeaderCell('WHAT IS THE LEARNING', whatIsTheLearningColWidth),
                  ],
                ),
              ),
              // Data Rows
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLessons.length,
                  itemBuilder: (context, index) {
                    final lesson = filteredLessons[index];
                    final project = projects.firstWhere((p) => p['fld_ID'] == lesson['projectID'], orElse: () => {'fld_ProjectNo': ''});
                    final type = llTypes.firstWhere((t) => t['typeID'] == lesson['type'], orElse: () => {'type': ''})['type'];

                    return Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))),
                      child: Row(
                        children: [
                          if (selectedProject != null) 
                          Container(
                            width: buttonsColWidth, 
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0
                              ), 
                              alignment: Alignment.centerLeft, 
                              child: Row(
                                children: [
                                  IconButton(
                                    tooltip: 'EDIT LESSONS LEARNED:', 
                                    onPressed: () => _addEditLessonsLearnedContextWindow(lesson), 
                                    icon: Icon(Icons.edit, color: localAppTheme['anchorColors']['primaryColor']),
                                  ),
                                  IconButton(
                                    tooltip: 'DELETE LESSONS LEARNED:', 
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          title: const Text('Confirm Deletion'),
                                          content: const Text('Are you sure you want to delete this lesson?'),
                                          actions: <Widget>[
                                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await lessonsLearnedProvider.deleteLessonsLearned(lesson, projectProvider, applicationInfo);
                                          if (!context.mounted) return;
                                          snackbar(context: context, header: 'Lesson deleted successfully.');
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          snackbar(context: context, header: 'Failed to delete lesson: ${e.toString()}');
                                        }
                                      }
                                    },
                                    icon: Icon(Icons.delete, color: localAppTheme['anchorColors']['primaryColor']),
                                  ),
                                ]
                              ),
                          ),
                          if (selectedProject == null) Container(width: projectColWidth, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), alignment: Alignment.centerLeft, child: Text(project['fld_ProjectNo'].toString())),
                          Container(width: lessonTitleColWidth, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), alignment: Alignment.centerLeft, child: Text(lesson['lessonTitle'] ?? '')),
                          Container(width: dateRaisedColWidth, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), alignment: Alignment.centerLeft, child: Text(lesson['dateRaised'].toString().split('T')[0])),
                          Container(width: eventColWidth, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), alignment: Alignment.centerLeft, child: Text(lesson['event'] ?? '')),
                          Container(width: typeColWidth, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), alignment: Alignment.centerLeft, child: Text(type)),
                          Container(width: costSavingsColWidth, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), alignment: Alignment.centerLeft, child: Text(lesson['costSavings'] ?? '')),
                          Container(width: outcomeColWidth, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), alignment: Alignment.centerLeft, child: Text(lesson['outcome'] ?? '')),
                          Container(width: whatIsTheLearningColWidth, padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), alignment: Alignment.centerLeft, child: Text(lesson['whatIsTheLearning'] ?? '')),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// -------------------------------------------------------------------------------------
  /// Build Widget
  @override
  Widget build(BuildContext context) {
    // Get Provider Variables Part 1
    final localAppTheme = ResponsiveTheme(context).theme;
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context));
        } else {
          // Get Provider Variables Part 2
          final projectProvider = Provider.of<Projectprovider>(context, listen: true);
          final selectedProject = projectProvider.selectedProject;

          return Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _searchBar(context),
                          Visibility(visible: selectedProject != null, child: IconButton(tooltip: 'UNLOCK PROJECT SELECTION:', icon: Icon(Icons.lock_open, color: localAppTheme['anchorColors']['primaryColor']), onPressed: _unlockProjectSelection)),
                        ],
                      ),
                      Visibility(
                        visible: selectedProject != null,
                        child: Row(
                          children: [
                            IconButton(tooltip: 'ADD LESSONS LEARNED:', icon: Icon(Icons.add, color: localAppTheme['anchorColors']['primaryColor']), onPressed: () => _addEditLessonsLearnedContextWindow()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  header3(header: 'LESSONS LEARNED:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                  SizedBox(height: 10),
                  Expanded(child: _lessonsLearnedListView(context)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
