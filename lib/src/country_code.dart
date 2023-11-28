import 'package:flutter/cupertino.dart';
import 'package:country_code_picker/src/country_localizations.dart';

class CountryCode {
  /// the name of the country
  String name;

  /// the country code (IT,AF..)
  final String code;

  /// the dial code (+39,+93..)
  final String dialCode;

  CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
  });

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    return CountryCode(
      name: json['name'] as String,
      code: json['code'] as String,
      dialCode: json['dial_code'] as String,
    );
  }

  String get flagUri => 'flags/${code.toLowerCase()}.png';

  Image flagImage({double width = 28}) => Image.asset(
        flagUri,
        package: 'country_code_picker',
        width: width,
      );

  CountryCode localize(BuildContext context) {
    return this..name = CountryLocalizations.of(context)?.translate(code) ?? name;
  }

  String toCountryNameWithCode() => "$dialCode ${toCountryName()}";

  String toCountryName() => name.replaceAll(RegExp(r'[[\]]'), '').split(',').first;
}
