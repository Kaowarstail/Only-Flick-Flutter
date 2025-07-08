import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum NetworkStatus {
  online,
  offline,
  weak,
  connecting,
}

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  NetworkStatus _networkStatus = NetworkStatus.offline;
  ConnectivityResult _connectionType = ConnectivityResult.none;
  bool _isInitialized = false;
  
  // Getters
  NetworkStatus get networkStatus => _networkStatus;
  ConnectivityResult get connectionType => _connectionType;
  bool get isOnline => _networkStatus == NetworkStatus.online;
  bool get isOffline => _networkStatus == NetworkStatus.offline;
  bool get hasWeakConnection => _networkStatus == NetworkStatus.weak;
  bool get isInitialized => _isInitialized;
  
  // Stream pour écouter les changements de connectivité
  final StreamController<NetworkStatus> _statusController = 
      StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get statusStream => _statusController.stream;
  
  /// Initialiser le service de connectivité
  Future<void> initialize() async {
    try {
      print('ConnectivityService: Initializing...');
      
      // Vérifier la connectivité initiale
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
      
      // Écouter les changements de connectivité
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          print('ConnectivityService: Error listening to connectivity changes: $error');
        },
      );
      
      _isInitialized = true;
      print('ConnectivityService: Initialized successfully');
      
    } catch (e) {
      print('ConnectivityService: Error during initialization: $e');
      _isInitialized = false;
    }
  }
  
  /// Mettre à jour le statut de connexion
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    print('ConnectivityService: Connectivity changed to $result');
    
    _connectionType = result;
    
    // Déterminer le statut réseau
    switch (result) {
      case ConnectivityResult.wifi:
        _networkStatus = NetworkStatus.online;
        break;
      case ConnectivityResult.mobile:
        _networkStatus = NetworkStatus.online;
        break;
      case ConnectivityResult.ethernet:
        _networkStatus = NetworkStatus.online;
        break;
      case ConnectivityResult.none:
        _networkStatus = NetworkStatus.offline;
        break;
      default:
        _networkStatus = NetworkStatus.offline;
    }
    
    // Effectuer un test de connexion réel pour confirmer
    if (_networkStatus == NetworkStatus.online) {
      final hasInternet = await _testInternetConnection();
      if (!hasInternet) {
        _networkStatus = NetworkStatus.weak;
      }
    }
    
    print('ConnectivityService: Network status updated to $_networkStatus');
    
    // Notifier les écouteurs
    _statusController.add(_networkStatus);
    notifyListeners();
  }
  
  /// Tester la connexion Internet réelle
  Future<bool> _testInternetConnection() async {
    try {
      // Test simple de connexion HTTP
      final result = await _connectivity.checkConnectivity();
      
      // TODO: Implémenter un vrai test de ping vers notre serveur
      // Pour l'instant, on fait confiance au statut de connectivité
      return result != ConnectivityResult.none;
      
    } catch (e) {
      print('ConnectivityService: Internet test failed: $e');
      return false;
    }
  }
  
  /// Forcer une vérification du statut réseau
  Future<void> refreshNetworkStatus() async {
    print('ConnectivityService: Refreshing network status...');
    
    _networkStatus = NetworkStatus.connecting;
    notifyListeners();
    
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    } catch (e) {
      print('ConnectivityService: Error refreshing network status: $e');
      _networkStatus = NetworkStatus.offline;
      notifyListeners();
    }
  }
  
  /// Obtenir une description textuelle du statut
  String getStatusDescription() {
    switch (_networkStatus) {
      case NetworkStatus.online:
        return 'Connected';
      case NetworkStatus.offline:
        return 'Offline';
      case NetworkStatus.weak:
        return 'Weak connection';
      case NetworkStatus.connecting:
        return 'Connecting...';
    }
  }
  
  /// Obtenir une description du type de connexion
  String getConnectionTypeDescription() {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'No connection';
      default:
        return 'Unknown';
    }
  }
  
  /// Obtenir une couleur pour le statut
  Color getStatusColor() {
    switch (_networkStatus) {
      case NetworkStatus.online:
        return Colors.green;
      case NetworkStatus.offline:
        return Colors.red;
      case NetworkStatus.weak:
        return Colors.orange;
      case NetworkStatus.connecting:
        return Colors.blue;
    }
  }
  
  /// Obtenir une icône pour le statut
  IconData getStatusIcon() {
    switch (_networkStatus) {
      case NetworkStatus.online:
        switch (_connectionType) {
          case ConnectivityResult.wifi:
            return Icons.wifi;
          case ConnectivityResult.mobile:
            return Icons.signal_cellular_4_bar;
          case ConnectivityResult.ethernet:
            return Icons.ethernet;
          default:
            return Icons.cloud_done;
        }
      case NetworkStatus.offline:
        return Icons.cloud_off;
      case NetworkStatus.weak:
        return Icons.signal_wifi_bad;
      case NetworkStatus.connecting:
        return Icons.wifi_find;
    }
  }
  
  /// Vérifier si on doit utiliser le fallback REST
  bool shouldUseFallback() {
    return _networkStatus == NetworkStatus.offline || 
           _networkStatus == NetworkStatus.weak;
  }
  
  /// Attendre qu'une connexion stable soit disponible
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_networkStatus == NetworkStatus.online) return;
    
    print('ConnectivityService: Waiting for connection...');
    
    final completer = Completer<void>();
    late StreamSubscription<NetworkStatus> subscription;
    
    subscription = statusStream.listen((status) {
      if (status == NetworkStatus.online) {
        subscription.cancel();
        completer.complete();
      }
    });
    
    // Timeout
    Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(TimeoutException('Connection timeout', timeout));
      }
    });
    
    return completer.future;
  }
  
  @override
  void dispose() {
    print('ConnectivityService: Disposing service');
    
    _connectivitySubscription?.cancel();
    _statusController.close();
    
    super.dispose();
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration duration;
  
  TimeoutException(this.message, this.duration);
  
  @override
  String toString() => 'TimeoutException: $message after ${duration.inSeconds}s';
}
