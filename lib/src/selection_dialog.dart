import 'package:country_code_picker/src/country_codes.dart';
import 'package:country_code_picker/src/country_selection_mode.dart';
import 'package:flutter/material.dart';

import 'package:country_code_picker/src/country_code.dart';
import 'package:country_code_picker/src/country_localizations.dart';

class SelectionDialog extends StatefulWidget {
  final double flagWidth;
  final List<CountryCode> favorites;
  final Widget searchIcon;
  final String searchHint;
  final CountrySelectionMode countrySelectionMode;

  const SelectionDialog(
    this.favorites,
    this.flagWidth,
    this.searchIcon,
    this.searchHint,
    this.countrySelectionMode,
  );

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  late List<CountryCode> _filteredElements;
  late List<CountryCode> _elements;

  @override
  void initState() {
    super.initState();
    _elements = countryCodes.map((json) => CountryCode.fromJson(json)).toList();
    _filteredElements = _elements;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Color(0xFF090A0A),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF090A0A),
              ),
              decoration: InputDecoration(
                icon: widget.searchIcon,
                hintText: widget.searchHint,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6C7072),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                ...widget.favorites.map(
                  (code) => _Option(
                    code,
                    widget.flagWidth,
                    widget.countrySelectionMode,
                  ),
                ),
                const Divider(),
                if (_filteredElements.isEmpty)
                  Center(
                    child: Text(CountryLocalizations.of(context)
                            ?.translate('no_country') ??
                        'No country found'),
                  )
                else
                  ..._filteredElements.map(
                    (code) => _Option(
                      code,
                      widget.flagWidth,
                      widget.countrySelectionMode,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQueryChanged(String query) {
    final upper = query.toUpperCase();
    setState(() {
      _filteredElements = _elements
          .where((e) =>
              e.code.contains(upper) ||
              e.dialCode.contains(upper) ||
              e.name.toUpperCase().contains(upper))
          .toList();
    });
  }
}

class _Option extends StatelessWidget {
  final CountryCode _countryCode;
  final double _flagWidth;
  final CountrySelectionMode _countrySelectionMode;

  const _Option(
    this._countryCode,
    this._flagWidth,
    this._countrySelectionMode,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context, _countryCode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          children: [
            Image.asset(
              _countryCode.flagUri,
              package: 'country_code_picker',
              width: _flagWidth,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _countrySelectionMode == CountrySelectionMode.country
                    ? _countryCode.toCountryName()
                    : _countryCode.toCountryNameWithCode(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
