/// Abstraction for network connectivity checks
abstract class NetworkInfo {
  Future<bool> get isConnected;
}
