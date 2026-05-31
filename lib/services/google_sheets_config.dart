class GoogleSheetsConfig {
  GoogleSheetsConfig._();

  static const String clientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '936899498559-ti45a33j5umqqn7033psk3tossgmdh6s.apps.googleusercontent.com',
  );
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '936899498559-234l9bj64rf5pv08alblkqf231voamo6.apps.googleusercontent.com',
  );
  static const String sheetId = String.fromEnvironment(
    'GOOGLE_SHEET_ID',
    defaultValue: '1Xg3WbmZHb5QxlYM6SmKIfnVP3rZvh9eqPDqp9IggB1o',
  );
  static const String scope =
      'https://www.googleapis.com/auth/spreadsheets';
}
