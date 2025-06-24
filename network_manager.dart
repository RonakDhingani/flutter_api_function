import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkManager {
  static bool _isDialogShowing = false;

  static Future<bool> checkNetworkAndShowPopup() async {
    final connectivity = Connectivity();
    final List<ConnectivityResult> results =
        await connectivity.checkConnectivity();

    bool hasInternet = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi);

    if (!hasInternet) {
      if (!_isDialogShowing) {
        _isDialogShowing = true;
        await Utility.networkConformationDialog();
        _isDialogShowing = false;
      }
      return false;
    }
    return true;
  }
}
