import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Utilities/globalvariables.dart';
import 'package:flutter/services.dart';

//------------------------------------------------------------------------
//Page Header
Widget pageHeader({
  required BuildContext context,
  required String topText,
  required String bottomText,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  final localAppInfo = Provider.of<AppInfo>(context).appInfo;

  return Container(
    height: localAppTheme['pageHeaderHeight'],
    width: double.infinity,
    color: localAppTheme['anchorColors']['primaryColor'],
    child: Row(
      children: [
        const SizedBox(width: 50),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              localAppInfo['name'],
              style: localAppTheme['font'](
                textStyle: TextStyle(
                  fontSize: localAppTheme['bodySize'] * 2,
                  fontWeight: FontWeight.bold,
                  color: localAppTheme['anchorColors']['secondaryColor'],
                ),
              ),
            ),
            header1(
              header: topText, 
              context: context, 
              color: localAppTheme['anchorColors']['secondaryColor'],
              ),
            header1(
              header: bottomText, 
              context: context, 
              color: localAppTheme['anchorColors']['secondaryColor'],
              ),
          ],
        ),
        const Expanded(child: SizedBox(width: 50)),
        SizedBox(
          height: localAppTheme['pageHeaderHeight'] * 0.5,
          width: localAppTheme['pageHeaderHeight'] * 1.75,
          child: Center(
            child: Image.asset(
              localAppTheme['logo'],
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 50)
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Page Footer
Widget pageFooter({
  required BuildContext context,
  required String? userRole,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;

  return Container(
    height: localAppTheme['pageFooterHeight'],
    width: double.infinity,
    color: localAppTheme['anchorColors']['primaryColor'],
    child: Row(
      children: [
        const SizedBox(width: 50),
        header1(
              header: userRole ?? '', 
              context: context, 
              color: localAppTheme['anchorColors']['secondaryColor'],
              ),
        const Expanded(child: SizedBox(width: 50)),
        SizedBox(
          height: localAppTheme['pageFooterHeight'] * 0.4,
          width: localAppTheme['pageFooterHeight'] * 1,
          child: Center(
            child: Image.asset(
              localAppTheme['logo'],
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 50),
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Header 1
Widget header1({
  required String header,
  required BuildContext context,
  required Color? color,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    textAlign: TextAlign.center,
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: localAppTheme['header1Size'],
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

//------------------------------------------------------------------------
//Snackbar Widget
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackbar({
  required BuildContext context,
  required String header,
}) {
  final localAppTheme = Theme.of(context);
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          header,
          style: TextStyle(
            color: localAppTheme.colorScheme.onPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: localAppTheme.colorScheme.primary,
    ),
  );
}

//------------------------------------------------------------------------
//Header 2
Widget header2({
  required String header,
  required BuildContext context,
  required Color? color,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: localAppTheme['header2Size'],
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

//------------------------------------------------------------------------
//Header 3
Widget header3({
  required String header,
  required BuildContext context,
  required Color? color,
  TextAlign textAlign = TextAlign.center,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    textAlign: textAlign,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: localAppTheme['header3Size'],
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

//------------------------------------------------------------------------
//Body
Widget body({
  required String header,
  required Color? color,
  required BuildContext context,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: localAppTheme['bodySize'],
        color: color,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

//------------------------------------------------------------------------
//Custom Text
Widget customText({
  required String header,
  required Color? color,
  required BuildContext context,
  required double fontSize,
  required FontWeight fontWeight,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    ),
  );
}

//------------------------------------------------------------------------
//TickBoxWidget
Widget checkBox({
  required String header,
  required Color? color,
  required BuildContext context,
  required bool enabled,
  required bool value,
  required Function(bool?)? onChanged,
}) {
  return CheckboxListTile(
    enabled: enabled,
    title: body(
      header: header,
      color: color,
      context: context,
    ),
    value: value,
    onChanged: onChanged,
  );
}

//------------------------------------------------------------------------
//Form Input Field
// ignore: camel_case_types
class formInputField extends StatefulWidget {
  final String label;
  final String errorMessage;
  final TextEditingController? controller; // Made nullable
  final bool isMultiline;
  final bool isPassword;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool showLabel;
  final BuildContext context;
  final String? initialValue;
  final bool? enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color? backgroundColor; // Optional background color
  final bool? readonly;
  final double? fontSize;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const formInputField({
    super.key,
    required this.label,
    required this.errorMessage,
    this.controller, // Made nullable
    required this.isMultiline,
    required this.isPassword,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.showLabel,
    required this.context,
    required this.initialValue,
    this.enabled,
    required this.validator,
    required this.onChanged,
    this.readonly,
    this.backgroundColor,
    this.fontSize,
    this.textAlign,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  // ignore: library_private_types_in_public_api
  _formInputfieldState createState() => _formInputfieldState();
}

// ignore: camel_case_types
class _formInputfieldState extends State<formInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return TextFormField(
      style: localAppTheme['font'](
        textStyle: TextStyle(
          color: localAppTheme['anchorColors']['primaryColor'],
          fontSize: widget.fontSize ?? ResponsiveTheme(context).theme['bodySize'],
        ),
      ),
      textAlign: widget.textAlign ?? TextAlign.start,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      autocorrect: true,
      enableSuggestions: true,
      controller: widget.controller, // Nullable controller
      obscureText: _obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.backgroundColor, // Apply the optional background color
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: _toggleVisibility,
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null,
        suffixIconColor: localAppTheme['anchorColors']['primaryColor'],
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        prefixIconColor: localAppTheme['anchorColors']['primaryColor'],
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: localAppTheme['anchorColors']['primaryColor'],
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: localAppTheme['anchorColors']['primaryColor'],
            width: 1.0,
          ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: localAppTheme['anchorColors']['primaryColor'],
          ),
        ),
        hintText: !widget.showLabel ? widget.label : null,
        hintStyle: localAppTheme['font'](
          textStyle: TextStyle(
            color: localAppTheme['anchorColors']['primaryColor'],
          ),
        ),
        labelText: widget.showLabel ? widget.label : null,
        labelStyle: localAppTheme['font'](
          textStyle: TextStyle(
            fontSize: widget.fontSize ?? ResponsiveTheme(context).theme['bodySize'],
            color: localAppTheme['anchorColors']['primaryColor'],
          ),
        ),
      ),
      maxLines: !widget.isMultiline ? 1 : null,
      validator: widget.validator,
      initialValue: widget.controller == null ? widget.initialValue : null, // Use initialValue if controller is null
      enabled: widget.enabled ?? true,
      readOnly: widget.readonly ?? false,
      onChanged: widget.onChanged,
    );
  }
}

//------------------------------------------------------------------------
//Elevated Button
Widget elevatedButton({
  required String label,
  required VoidCallback? onPressed,
  required Color? backgroundColor,
  required Color labelColor,
  required IconData? leadingIcon,
  required IconData? trailingIcon,
  required BuildContext context,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: labelColor,
              width: 3,
            )),
      ),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: leadingIcon == null ? false : true,
          child: Row(
            children: [
              Icon(
                leadingIcon,
                color: labelColor,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        Text(
          textAlign: TextAlign.center,
          label,
          style: localAppTheme['font'](
            textStyle: TextStyle(
              fontSize: localAppTheme['header3Size'],
              color: labelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Visibility(
          visible: trailingIcon == null ? false : true,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(
                trailingIcon,
                color: labelColor,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Icon Button
Widget iconButton({
  required String? label,
  required Color? backgroundColor,
  required Color iconColor,
  required IconData icon,
  required double? size,
  required String? toolTip,
  required BuildContext context,
  required Function()? onPressed,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Container(
    decoration: BoxDecoration(color: backgroundColor ?? Colors.transparent, borderRadius: BorderRadius.circular(10), border: Border.all(color: backgroundColor == null ? Colors.transparent : iconColor, width: 3)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: label == null ? toolTip : null,
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: iconColor,
            size: size,
          ),
        ),
        label != null
            ? Center(
                child: Text(
                  label,
                  style: localAppTheme['font'](
                    textStyle: TextStyle(
                      fontSize: localAppTheme['header3Size'],
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Date Picker
// ignore: must_be_immutable
class DatePicker extends StatefulWidget {
  final Color buttonBackgroundColor;
  final Color buttonLabelColor;
  final Color textFieldColor;
  final String label;
  final bool buttonVisibility;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final void Function(DateTime?)? onChanged;
  final Color? backgroundColor;
  final DateTime? initialDate;
  final bool? enabled;


  const DatePicker({
    super.key,
    required this.buttonBackgroundColor,
    required this.buttonLabelColor,
    required this.textFieldColor,
    required this.label,
    required this.buttonVisibility,
    this.initialDate,
    required this.validator,
    required this.controller,
    required this.onChanged,
    this.backgroundColor,
    this.enabled
  });

  @override
  // ignore: library_private_types_in_public_api
  _DatePicker createState() => _DatePicker();
}

class _DatePicker extends State<DatePicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    // The controller's text is expected to be set by the parent widget.
    // This ensures that if the parent has a value (e.g., from a provider), it's displayed.
  }

  @override
  void didUpdateWidget(DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      setState(() {
        _selectedDate = widget.initialDate;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.controller.text = "${_selectedDate!.toLocal()}".split(' ')[0];
        if (widget.onChanged != null) {
          widget.onChanged!(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SizedBox(
              child: formInputField(
                label: widget.label,
                errorMessage: '',
                controller: widget.controller,
                isMultiline: false,
                isPassword: false,
                prefixIcon: null,
                enabled: widget.enabled,
                suffixIcon: null,
                showLabel: true,
                backgroundColor: widget.backgroundColor,
                context: context,
                initialValue: null,
                validator: widget.validator,
                onChanged: null,
                readonly: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Visibility(
            visible: widget.buttonVisibility && widget.enabled == true,
            child: iconButton(
              label: null,
              backgroundColor: null,
              iconColor: widget.buttonLabelColor,
              icon: Icons.calendar_month,
              size: 30,
              toolTip: 'Select Date:',
              context: context,
              onPressed: () => _selectDate(context),
            ),
          ),
        ],
      ),
    );
  }
}

//------------------------------------------------------------------------
//Searchable DropDowm
class SearchableDropdown extends StatefulWidget {
  final String labelText;
  final String hint;
  final Color dropdownTextColor;
  final bool searchBoxVisable;
  final List<Map<String, dynamic>> dropDownList;
  final String header;
  final dynamic initialValue;
  final Color iconColor;
  final String idField;
  final String displayField;
  final ValueChanged<Map<String, dynamic>?>? onChanged;
  final bool isEnabled;
  final Color? backgroundColor;
  final String? Function(Map<String, dynamic>?)? validator;


  const SearchableDropdown({
    super.key,
    required this.labelText,
    required this.hint,
    required this.dropdownTextColor,
    required this.searchBoxVisable,
    required this.dropDownList,
    required this.header,
    this.initialValue,
    required this.iconColor,
    required this.idField,
    required this.displayField,
    required this.onChanged,
    required this.isEnabled,
    this.backgroundColor,
    this.validator,
  });

  @override
  SearchableDropdownState createState() => SearchableDropdownState();
}

class SearchableDropdownState extends State<SearchableDropdown> {
  Map<String, dynamic>? selectedItem;
  List<Map<String, dynamic>> filteredItems = [];
  bool searchBoxVisibilityToggle = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the list of items or the initial value changes, re-initialize the state.
    if (widget.dropDownList != oldWidget.dropDownList || widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _initializeState();
      });
    }
  }

  void _initializeState() {
    filteredItems = widget.dropDownList;
    selectedItem = null; // Start fresh
    if (widget.initialValue != null && widget.dropDownList.isNotEmpty) {
      try {
        // Find the item in the list that matches the initial value.
        selectedItem = widget.dropDownList.firstWhere(
          (item) => item[widget.idField].toString() == widget.initialValue.toString(),
        );
      } catch (e) {
        // This can happen if the initialValue is not (or no longer) in the list.
        // selectedItem remains null, which is the correct behavior.
        debugPrint('Initial value ${widget.initialValue} not found in dropdown list for ${widget.header}');
      }
    }
  }
  
  void resetSelectedItem() {
    setState(() {
      if (widget.initialValue != null) {
        selectedItem = widget.dropDownList.firstWhere(
          (item) => item[widget.idField] == widget.initialValue,
          orElse: () => <String, dynamic>{},
        );
        // Check if the selectedItem is empty, if so set it to null
        if (selectedItem!.isEmpty) {
          selectedItem = null;
        }
      } else {
        selectedItem = null;
      }
    });
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = widget.dropDownList.where((item) => item[widget.displayField].toLowerCase().contains(query.toLowerCase())).toList();
      if (!filteredItems.contains(selectedItem)) {
        selectedItem = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Visibility(
          visible: widget.searchBoxVisable && searchBoxVisibilityToggle,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  labelStyle: TextStyle(
                    fontSize: ResponsiveTheme(context).theme['bodySize'],
                  ),
                  filled: widget.backgroundColor != null,
                  fillColor: widget.backgroundColor,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _filterItems,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 15, top: 0, right: 15, bottom: 0),
                  labelText: widget.header,
                  labelStyle: TextStyle(
                    fontSize: ResponsiveTheme(context).theme['bodySize'],
                    color: widget.dropdownTextColor,
                  ),
                  filled: widget.backgroundColor != null,
                  fillColor: widget.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: widget.dropdownTextColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: widget.isEnabled ? widget.dropdownTextColor : Colors.grey.shade300,
                    ),
                  ),
                ),
                isExpanded: true,
                hint: body(
                  header: widget.hint,
                  color: widget.dropdownTextColor,
                  context: context,
                ),
                value: selectedItem,
                items: filteredItems.map((item) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: body(
                      header: item[widget.displayField],
                      color: widget.dropdownTextColor,
                      context: context,
                    ),
                  );
                }).toList(),
                onChanged: widget.isEnabled
                    ? (newValue) {
                        setState(() {
                          selectedItem = newValue;
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(newValue);
                        }
                      }
                    : null,
                validator: widget.validator,
              ),
            ),
            Visibility(
              visible: widget.isEnabled && widget.searchBoxVisable,
              child: iconButton(
                label: null,
                backgroundColor: null,
                iconColor: widget.iconColor,
                icon: Icons.search,
                size: 30,
                toolTip: 'Enable Search:',
                context: context,
                onPressed: () {
                  setState(() {
                    searchBoxVisibilityToggle = !searchBoxVisibilityToggle;
                  });
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}

//------------------------------------------------------------------------
/// A reusable grid widget for displaying a list of selectable items.
/// It automatically adjusts its height to fit its content.
class SelectableGrid extends StatelessWidget {
  const SelectableGrid({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.idField,
    required this.displayBuilder,
    required this.onTap,
    required this.crossAxisCount,
    this.itemHeight = 50.0,
    this.spacing = 10.0,
  });

  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? selectedItem;
  final String idField;
  final String Function(Map<String, dynamic> item) displayBuilder;
  final void Function(Map<String, dynamic>) onTap;
  final int crossAxisCount;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    if (items.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if there are no items
    }

    return GridView.builder(
      shrinkWrap: true, // Makes the grid size itself to its content
      physics: const NeverScrollableScrollPhysics(), // Disables internal scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: itemHeight, // Sets a fixed height for each tile
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];
        final isSelected = selectedItem != null && item[idField] == selectedItem![idField];
        return Card(
          color: isSelected
              ? localAppTheme['anchorColors']['secondaryColor']
              : localAppTheme['anchorColors']['primaryColor'],
          child: InkWell(
            onTap: () => onTap(item),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Adjusted padding for better fit
                child: body(
                  header: displayBuilder(item),
                  context: context,
                  color: isSelected
                      ? localAppTheme['anchorColors']['primaryColor']
                      : localAppTheme['anchorColors']['secondaryColor'],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}