class GoogleSheetsConfig {
  GoogleSheetsConfig._();

  static const String clientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );
  static const String sheetId = String.fromEnvironment(
    'GOOGLE_SHEET_ID',
    defaultValue: '',
  );
  static const String scope =
      'https://www.googleapis.com/auth/spreadsheets';
}
