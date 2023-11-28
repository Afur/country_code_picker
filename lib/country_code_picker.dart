import 'package:collection/collection.dart' show IterableExtension;
import 'package:country_code_picker/src/country_selection_mode.dart';
import 'package:flutter/material.dart';

import 'package:country_code_picker/src/country_code.dart';
import 'package:country_code_picker/src/country_codes.dart';
import 'package:country_code_picker/src/selection_dialog.dart';

export 'src/country_code.dart';
export 'src/country_codes.dart';
export 'src/country_localizations.dart';
export 'src/selection_dialog.dart';
export 'src/country_selection_mode.dart';

class CountryCodePicker extends StatefulWidget {
  final String initialSelection;
  final List<String> favorites;
  final ValueChanged<CountryCode> onChanged;
  final double flagWidth;
  final String searchHint;
  final Widget searchIcon;
  final ValueChanged<CountryCode> onInit;
  final bool shouldShowArrow;
  final bool enabled;

  const CountryCodePicker({
    required this.initialSelection,
    required this.favorites,
    required this.onChanged,
    required this.flagWidth,
    required this.searchHint,
    required this.searchIcon,
    required this.onInit,
    super.key,
    this.shouldShowArrow = true,
    this.enabled = true,
  });

  @override
  State<StatefulWidget> createState() => CountryCodePickerState();
}

class CountryCodePickerState extends State<CountryCodePicker> {
  late CountryCode selectedItem;
  late List<CountryCode> elements;
  late final List<CountryCode> favorites;

  @override
  void initState() {
    super.initState();

    elements = countryCodes.map((json) => CountryCode.fromJson(json)).toList();

    selectedItem = elements.firstWhere(
      (item) =>
          (item.code.toUpperCase() == widget.initialSelection.toUpperCase()) ||
          (item.dialCode == widget.initialSelection) ||
          (item.name.toUpperCase() == widget.initialSelection.toUpperCase()),
      orElse: () => elements[0],
    );

    favorites = elements
        .where(
          (item) =>
              widget.favorites.firstWhereOrNull(
                (criteria) =>
                    item.code.toUpperCase() == criteria.toUpperCase() ||
                    item.dialCode == criteria ||
                    item.name.toUpperCase() == criteria.toUpperCase(),
              ) !=
              null,
        )
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    elements = elements.map((element) => element.localize(context)).toList();

    widget.onInit.call(selectedItem);
  }

  @override
  void didUpdateWidget(CountryCodePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSelection != widget.initialSelection) {
      selectedItem = elements.firstWhere(
        (criteria) =>
            (criteria.code.toUpperCase() ==
                widget.initialSelection.toUpperCase()) ||
            (criteria.dialCode == widget.initialSelection) ||
            (criteria.name.toUpperCase() ==
                widget.initialSelection.toUpperCase()),
        orElse: () => elements[0],
      );

      widget.onInit.call(selectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _showCountryCodePickerDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Image.asset(
              selectedItem.flagUri,
              package: 'country_code_picker',
              width: 28,
            ),
            const SizedBox(width: 4),
            Text(
              selectedItem.dialCode,
              style: const TextStyle(
                color: Color(0xFF090A0A),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (widget.shouldShowArrow)
              const Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF090A0A),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCountryCodePickerDialog() async {
    final countryCode = await showDialog<CountryCode>(
      context: context,
      builder: (context) => Dialog(
        child: SelectionDialog(
          favorites,
          widget.flagWidth,
          widget.searchIcon,
          widget.searchHint,
          CountrySelectionMode.dialCode,
        ),
      ),
    );

    if (countryCode != null) {
      setState(() {
        selectedItem = countryCode;
      });

      widget.onChanged(countryCode);
    }
  }
}
