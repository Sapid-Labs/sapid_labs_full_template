/// Where the "Update now" button sends the user.
///
/// The manifest's own `storeUrl` wins when it is set, because only the
/// manifest knows about a listing that does not follow the usual shape. The
/// fallbacks are the two URLs that can be derived from what the running build
/// already knows:
///
///  * Android: the Play listing for the running package name. This is derived
///    rather than configured on purpose -- a hard-coded package name in a
///    template is the kind of value a child app forgets to change, and it
///    would send that app's users to a competitor's listing.
///  * iOS: `apps.apple.com/app/id<APP_STORE_ID>`. There is nothing on the
///    device to derive it from, so it comes from the `APP_STORE_ID` define
///    that `account_view.dart` already reads.
///
/// Returns an empty string when nothing can be resolved. The dialog then
/// shows no update button rather than a dead one.
String storeUrlFor({
  required String manifestUrl,
  required bool isAndroid,
  String packageName = '',
  String appStoreId = '',
}) {
  if (manifestUrl.isNotEmpty) {
    return manifestUrl;
  }

  if (isAndroid) {
    if (packageName.isEmpty) {
      return '';
    }

    return 'https://play.google.com/store/apps/details?id=$packageName';
  }

  if (appStoreId.isEmpty) {
    return '';
  }

  return 'https://apps.apple.com/app/id$appStoreId';
}
