/// Build-time configuration values exposed to the Flutter layer.
const bool kShowVersionBanner = bool.fromEnvironment(
  'SHOW_VERSION',
  defaultValue: false,
);
