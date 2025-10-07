## Using Google Fonts

This project uses the `google_fonts` package to manage fonts. This is the recommended way to use fonts from Google Fonts in a Flutter app, as it avoids bundling the fonts with the app, reducing the app size.

To use a font, you can apply it to all text using your app's theme, or to individual text widgets.

**To apply it to your entire app's theme:**

```dart
import 'package:google_fonts/google_fonts.dart';

final ThemeData theme = ThemeData(
  textTheme: GoogleFonts.robotoTextTheme(),
);
```

**To apply it to a specific widget:**

```dart
import 'package:google_fonts/google_fonts.dart';

Text(
  'This is Roboto font.',
  style: GoogleFonts.roboto(),
);
```

## Landing Page

The landing page, implemented in `lib/Pages/SubFunctions/Landing/landingpageMain.dart`, displays a grid of navigation options.

-   **Layout:** A `GridView.builder` is used to create a 2-column grid of buttons.
-   **Content:** The buttons are populated from the `landingButtons` list in `FormStatusProvider`.
-   **Navigation:** When a button is tapped, it navigates to the corresponding page using the `setDisplayWidget` function from `FormStatusProvider`.
-   **Styling:** The buttons are styled as `Card`s with an `InkWell` for the tap effect. The colors are derived from the application's theme.

## Capture Lessons Learned Page

**File:** `lib/Pages/SubFunctions/Landing/CaptureLessonsLearned/capturelessonslearnedmain.dart`

This page provides an interface for viewing, adding, and editing lessons learned.

-   **Structure & State Management:**
    -   Implemented as a `StatefulWidget` (`CaptureLessonsLearnedMain`).
    -   A `FutureBuilder` handles the initial asynchronous data fetching (`projects` and `lessonsLearned`).
    -   It uses `Projectprovider` to manage project selection and `LessonsLearnedProvider` to access lesson data.
-   **Filtering:**
    -   A `SearchableDropdown` in the `_searchBar` widget allows users to select a project. The dropdown is disabled once a project is chosen.
    -   An "unlock" `IconButton` allows the user to clear the current project selection, which re-enables the dropdown and shows all lessons.
    -   If a project is selected from the dropdown, the grid displays only the lessons learned for that specific project.
    -   If no project is selected, the grid shows all lessons learned and includes an additional "Project" column to identify the project for each lesson.
-   **Data Grid (`_lessonsLearnedListView`):**
    -   Displays lessons learned in a horizontally scrollable data grid, inspired by `SamplyList.md`.
    -   The layout is built with a `Column` containing a header `Row` and an `Expanded` `ListView.builder` for the data rows.
    -   Horizontal scrolling is enabled by wrapping the `Column` in a `SingleChildScrollView` and a `Scrollbar`. Both are connected to a `_scrollController` to allow the user to drag the scrollbar thumb.
    -   Column widths are defined as `const double` for a consistent, table-like appearance.
-   **Add/Edit Functionality:**
    -   An "Add" `IconButton` in the header and an "Edit" `IconButton` on each row (visible only when a project is selected) trigger the `_addEditLessonsLearnedContextWindow` function.
    -   This function shows an `AlertDialog` for creating or modifying a lesson.
    -   The dialog contains several `formInputField` widgets for the lesson's details (Title, Event, Outcome, etc.).
    -   The same dialog is used for both adding and editing; if a `lesson` object is passed to the function, it pre-populates the fields for editing.
-   **Export Functionality:**
    -   An `IconButton` to "Extract Lessons Learned into Excel" is present. The `_extractLessonsLearnedIntoExcel` function is currently a placeholder for future implementation.